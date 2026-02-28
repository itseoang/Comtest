from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class CardStats:
    hp: int = 0
    attack: int = 0
    defense: int = 0
    speed: int = 0
    charm: int = 0
    rarity_score: int = 0

    def to_dict(self) -> dict:
        return {
            "hp": self.hp,
            "attack": self.attack,
            "defense": self.defense,
            "speed": self.speed,
            "charm": self.charm,
            "rarity_score": self.rarity_score,
        }

    @classmethod
    def from_dict(cls, data: dict) -> "CardStats":
        return cls(
            hp=data.get("hp", 0),
            attack=data.get("attack", 0),
            defense=data.get("defense", 0),
            speed=data.get("speed", 0),
            charm=data.get("charm", 0),
            rarity_score=data.get("rarity_score", 0),
        )


@dataclass
class Collection:
    id: str
    card_number: str
    user_id: str
    species_id: int
    photo_url: str
    thumbnail_url: str | None = None
    gps_latitude: float | None = None
    gps_longitude: float | None = None
    location_name: str | None = None
    stats: dict = field(default_factory=dict)
    original_owner_id: str = ""
    co_discoverers: list[str] = field(default_factory=list)
    discovered_at: datetime | None = None
    is_public: bool = False
    is_synced: bool = False
    notes: str | None = None
    created_at: datetime | None = None

    @classmethod
    def from_dict(cls, data: dict) -> "Collection":
        return cls(
            id=data["id"],
            card_number=data["card_number"],
            user_id=data["user_id"],
            species_id=data["species_id"],
            photo_url=data["photo_url"],
            thumbnail_url=data.get("thumbnail_url"),
            gps_latitude=data.get("gps_latitude"),
            gps_longitude=data.get("gps_longitude"),
            location_name=data.get("location_name"),
            stats=data.get("stats", {}),
            original_owner_id=data.get("original_owner_id", ""),
            co_discoverers=data.get("co_discoverers", []),
            discovered_at=data.get("discovered_at"),
            is_public=data.get("is_public", False),
            is_synced=data.get("is_synced", False),
            notes=data.get("notes"),
            created_at=data.get("created_at"),
        )


@dataclass
class OwnershipHistory:
    id: int
    collection_id: str
    from_user_id: str | None
    to_user_id: str
    transfer_type: str  # 'discovery', 'trade', 'gift'
    transferred_at: datetime | None = None

    @classmethod
    def from_dict(cls, data: dict) -> "OwnershipHistory":
        return cls(
            id=data["id"],
            collection_id=data["collection_id"],
            from_user_id=data.get("from_user_id"),
            to_user_id=data["to_user_id"],
            transfer_type=data["transfer_type"],
            transferred_at=data.get("transferred_at"),
        )
