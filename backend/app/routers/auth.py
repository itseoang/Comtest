from fastapi import APIRouter, HTTPException, Header
from app.database import get_supabase
from app.schemas.user import (
    UserSignup,
    UserLogin,
    AuthResponse,
    ProfileResponse,
    ProfileUpdate,
)

router = APIRouter()


@router.post("/signup", response_model=AuthResponse)
async def signup(data: UserSignup):
    """회원가입"""
    sb = get_supabase()
    try:
        result = sb.auth.sign_up(
            {
                "email": data.email,
                "password": data.password,
                "options": {"data": {"nickname": data.nickname}},
            }
        )

        if not result.user:
            raise HTTPException(status_code=400, detail="회원가입에 실패했습니다.")

        profile = (
            sb.table("profiles").select("*").eq("id", result.user.id).single().execute()
        )

        return AuthResponse(
            access_token=result.session.access_token,
            refresh_token=result.session.refresh_token,
            user=ProfileResponse(**profile.data),
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/login", response_model=AuthResponse)
async def login(data: UserLogin):
    """로그인"""
    sb = get_supabase()
    try:
        result = sb.auth.sign_in_with_password(
            {"email": data.email, "password": data.password}
        )

        if not result.user:
            raise HTTPException(status_code=401, detail="로그인에 실패했습니다.")

        profile = (
            sb.table("profiles").select("*").eq("id", result.user.id).single().execute()
        )

        return AuthResponse(
            access_token=result.session.access_token,
            refresh_token=result.session.refresh_token,
            user=ProfileResponse(**profile.data),
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=401, detail="이메일 또는 비밀번호가 올바르지 않습니다.")


@router.post("/logout")
async def logout(authorization: str = Header(...)):
    """로그아웃"""
    sb = get_supabase()
    try:
        token = authorization.replace("Bearer ", "")
        sb.auth.sign_out(token)
        return {"message": "로그아웃 되었습니다."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/me", response_model=ProfileResponse)
async def get_me(authorization: str = Header(...)):
    """현재 사용자 정보 조회"""
    sb = get_supabase()
    try:
        token = authorization.replace("Bearer ", "")
        user = sb.auth.get_user(token)

        if not user or not user.user:
            raise HTTPException(status_code=401, detail="인증이 필요합니다.")

        profile = (
            sb.table("profiles").select("*").eq("id", user.user.id).single().execute()
        )
        return ProfileResponse(**profile.data)
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=401, detail="인증이 필요합니다.")


@router.put("/me", response_model=ProfileResponse)
async def update_profile(data: ProfileUpdate, authorization: str = Header(...)):
    """프로필 수정"""
    sb = get_supabase()
    try:
        token = authorization.replace("Bearer ", "")
        user = sb.auth.get_user(token)

        if not user or not user.user:
            raise HTTPException(status_code=401, detail="인증이 필요합니다.")

        update_data = data.model_dump(exclude_none=True)
        if not update_data:
            raise HTTPException(status_code=400, detail="수정할 데이터가 없습니다.")

        result = (
            sb.table("profiles")
            .update(update_data)
            .eq("id", user.user.id)
            .execute()
        )

        profile = (
            sb.table("profiles").select("*").eq("id", user.user.id).single().execute()
        )
        return ProfileResponse(**profile.data)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
