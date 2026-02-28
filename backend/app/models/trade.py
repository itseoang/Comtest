from dataclasses import dataclass
from datetime import datetime


@dataclass
class Trade:
    id: str
    sender_id: str
    receiver_id: str
    sender_card_id: str
    receiver_card_id: str | None = None
    status: str = "pending"
    message: str | None = None
    created_at: datetime | None = None
    resolved_at: datetime | None = None

    @classmethod
    def from_dict(cls, data: dict) -> "Trade":
        return cls(
            id=data["id"],
            sender_id=data["sender_id"],
            receiver_id=data["receiver_id"],
            sender_card_id=data["sender_card_id"],
            receiver_card_id=data.get("receiver_card_id"),
            status=data.get("status", "pending"),
            message=data.get("message"),
            created_at=data.get("created_at"),
            resolved_at=data.get("resolved_at"),
        )
