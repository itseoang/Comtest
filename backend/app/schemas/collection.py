from pydantic import BaseModel, Field
from datetime import datetime


class CardStatsSchema(BaseModel):
    hp: int = Field(0, ge=0, le=100)
    attack: int = Field(0, ge=0, le=100)
    defense: int = Field(0, ge=0, le=100)
    speed: int = Field(0, ge=0, le=100)
    charm: int = Field(0, ge=0, le=100)
    rarity_score: int = Field(0, ge=0, le=100)


class CollectionCreate(BaseModel):
    species_id: int
    photo_url: str
    thumbnail_url: str | None = None
    gps_latitude: float | None = None
    gps_longitude: float | None = None
    location_name: str | None = None
    stats: CardStatsSchema | None = None
    co_discoverers: list[str] = Field(default_factory=list)
    notes: str | None = None


class CollectionResponse(BaseModel):
    id: str
    card_number: str
    user_id: str
    species_id: int
    photo_url: str
    thumbnail_url: str | None = None
    gps_latitude: float | None = None
    gps_longitude: float | None = None
    location_name: str | None = None
    stats: dict = Field(default_factory=dict)
    original_owner_id: str
    co_discoverers: list[str] = Field(default_factory=list)
    discovered_at: datetime | None = None
    is_public: bool = False
    notes: str | None = None

    # 조인된 종 정보 (선택)
    species_name: str | None = None
    species_category: str | None = None
    species_color: str | None = None

    model_config = {"from_attributes": True}


class CollectionUpdate(BaseModel):
    notes: str | None = None
    is_public: bool | None = None
    location_name: str | None = None


class CollectionListResponse(BaseModel):
    items: list[CollectionResponse]
    total: int


class OwnershipHistoryResponse(BaseModel):
    id: int
    collection_id: str
    from_user_id: str | None = None
    to_user_id: str
    transfer_type: str
    transferred_at: datetime | None = None

    model_config = {"from_attributes": True}
