from dataclasses import dataclass
from datetime import datetime


@dataclass
class Profile:
    id: str
    nickname: str
    avatar_url: str | None = None
    birth_year: int | None = None
    is_parent: bool = False
    total_collections: int = 0
    eco_points: int = 0
    created_at: datetime | None = None
    updated_at: datetime | None = None

    @classmethod
    def from_dict(cls, data: dict) -> "Profile":
        return cls(
            id=data["id"],
            nickname=data["nickname"],
            avatar_url=data.get("avatar_url"),
            birth_year=data.get("birth_year"),
            is_parent=data.get("is_parent", False),
            total_collections=data.get("total_collections", 0),
            eco_points=data.get("eco_points", 0),
            created_at=data.get("created_at"),
            updated_at=data.get("updated_at"),
        )
