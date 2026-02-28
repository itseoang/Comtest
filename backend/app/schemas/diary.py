from pydantic import BaseModel, Field
from datetime import datetime


class DiaryCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    collection_id: str | None = None
    text_content: str | None = None
    drawing_url: str | None = None
    voice_url: str | None = None
    mood: str | None = Field(
        None,
        pattern="^(happy|excited|curious|calm|surprised)$",
        description="기분 (happy, excited, curious, calm, surprised)",
    )


class DiaryResponse(BaseModel):
    id: str
    user_id: str
    title: str
    collection_id: str | None = None
    text_content: str | None = None
    drawing_url: str | None = None
    voice_url: str | None = None
    mood: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    # 조인된 컬렉션 정보 (선택)
    collection_species_name: str | None = None
    collection_photo_url: str | None = None

    model_config = {"from_attributes": True}


class DiaryUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=200)
    text_content: str | None = None
    drawing_url: str | None = None
    voice_url: str | None = None
    mood: str | None = Field(
        None,
        pattern="^(happy|excited|curious|calm|surprised)$",
    )


class DiaryListResponse(BaseModel):
    items: list[DiaryResponse]
    total: int
