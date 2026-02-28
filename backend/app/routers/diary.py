from fastapi import APIRouter, HTTPException, Header, Query
from app.database import get_supabase
from app.schemas.diary import DiaryCreate, DiaryResponse, DiaryUpdate, DiaryListResponse

router = APIRouter()


def _get_user_id(authorization: str) -> str:
    sb = get_supabase()
    token = authorization.replace("Bearer ", "")
    user = sb.auth.get_user(token)
    if not user or not user.user:
        raise HTTPException(status_code=401, detail="인증이 필요합니다.")
    return user.user.id


@router.post("", response_model=DiaryResponse, status_code=201)
async def create_diary(data: DiaryCreate, authorization: str = Header(...)):
    """그림일기 작성"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    # 연결된 컬렉션 존재 확인
    if data.collection_id:
        try:
            sb.table("collections").select("id").eq("id", data.collection_id).single().execute()
        except Exception:
            raise HTTPException(status_code=404, detail="연결할 컬렉션을 찾을 수 없습니다.")

    insert_data = {
        "user_id": user_id,
        "title": data.title,
        "collection_id": data.collection_id,
        "text_content": data.text_content,
        "drawing_url": data.drawing_url,
        "voice_url": data.voice_url,
        "mood": data.mood,
    }

    result = sb.table("diary_entries").insert(insert_data).execute()
    return DiaryResponse(**result.data[0])


@router.get("", response_model=DiaryListResponse)
async def list_diary(
    authorization: str = Header(...),
    mood: str | None = Query(None, description="기분 필터"),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """내 그림일기 목록"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    query = (
        sb.table("diary_entries")
        .select("*", count="exact")
        .eq("user_id", user_id)
    )

    if mood:
        query = query.eq("mood", mood)

    result = query.order("created_at", desc=True).range(offset, offset + limit - 1).execute()

    return DiaryListResponse(
        items=[DiaryResponse(**item) for item in result.data],
        total=result.count or len(result.data),
    )


@router.get("/{diary_id}", response_model=DiaryResponse)
async def get_diary(diary_id: str, authorization: str = Header(...)):
    """그림일기 상세 조회"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    try:
        result = (
            sb.table("diary_entries")
            .select("*")
            .eq("id", diary_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(status_code=404, detail="일기를 찾을 수 없습니다.")

    if result.data["user_id"] != user_id:
        raise HTTPException(status_code=403, detail="접근 권한이 없습니다.")

    return DiaryResponse(**result.data)


@router.put("/{diary_id}", response_model=DiaryResponse)
async def update_diary(
    diary_id: str, data: DiaryUpdate, authorization: str = Header(...)
):
    """그림일기 수정"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    try:
        existing = (
            sb.table("diary_entries")
            .select("user_id")
            .eq("id", diary_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(status_code=404, detail="일기를 찾을 수 없습니다.")

    if existing.data["user_id"] != user_id:
        raise HTTPException(status_code=403, detail="본인의 일기만 수정할 수 있습니다.")

    update_data = data.model_dump(exclude_none=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="수정할 데이터가 없습니다.")

    sb.table("diary_entries").update(update_data).eq("id", diary_id).execute()

    updated = (
        sb.table("diary_entries")
        .select("*")
        .eq("id", diary_id)
        .single()
        .execute()
    )
    return DiaryResponse(**updated.data)


@router.delete("/{diary_id}")
async def delete_diary(diary_id: str, authorization: str = Header(...)):
    """그림일기 삭제"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    try:
        existing = (
            sb.table("diary_entries")
            .select("user_id")
            .eq("id", diary_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(status_code=404, detail="일기를 찾을 수 없습니다.")

    if existing.data["user_id"] != user_id:
        raise HTTPException(status_code=403, detail="본인의 일기만 삭제할 수 있습니다.")

    sb.table("diary_entries").delete().eq("id", diary_id).execute()
    return {"message": "일기가 삭제되었습니다."}
