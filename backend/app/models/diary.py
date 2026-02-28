from dataclasses import dataclass
from datetime import datetime

VALID_MOODS = ["happy", "excited", "curious", "calm", "surprised"]


@dataclass
class DiaryEntry:
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

    @classmethod
    def from_dict(cls, data: dict) -> "DiaryEntry":
        return cls(
            id=data["id"],
            user_id=data["user_id"],
            title=data["title"],
            collection_id=data.get("collection_id"),
            text_content=data.get("text_content"),
            drawing_url=data.get("drawing_url"),
            voice_url=data.get("voice_url"),
            mood=data.get("mood"),
            created_at=data.get("created_at"),
            updated_at=data.get("updated_at"),
        )
