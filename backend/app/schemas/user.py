from pydantic import BaseModel, Field


class UserSignup(BaseModel):
    email: str = Field(..., description="이메일")
    password: str = Field(..., min_length=6, description="비밀번호 (6자 이상)")
    nickname: str = Field(..., min_length=1, max_length=50, description="닉네임")


class UserLogin(BaseModel):
    email: str
    password: str


class ProfileResponse(BaseModel):
    id: str
    nickname: str
    avatar_url: str | None = None
    birth_year: int | None = None
    is_parent: bool = False
    total_collections: int = 0
    eco_points: int = 0

    model_config = {"from_attributes": True}


class ProfileUpdate(BaseModel):
    nickname: str | None = Field(None, min_length=1, max_length=50)
    avatar_url: str | None = None
    birth_year: int | None = None


class AuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    user: ProfileResponse
