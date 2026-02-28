from pydantic import BaseModel, Field


class SpeciesResponse(BaseModel):
    id: int
    korean_name: str
    scientific_name: str | None = None
    category: str
    subcategory: str | None = None
    description: str | None = None
    habitat: str | None = None
    rarity_tier: int = 1
    color_code: str | None = None
    fun_fact: str | None = None
    eco_message: str | None = None
    image_url: str | None = None

    model_config = {"from_attributes": True}


class SpeciesIdentifyResponse(BaseModel):
    species: SpeciesResponse
    confidence: float = Field(..., ge=0.0, le=1.0, description="식별 신뢰도")
    suggested_stats: dict = Field(default_factory=dict, description="추천 스탯")
    is_new_species: bool = Field(False, description="DB에 없던 신규 종 여부")


class SpeciesListResponse(BaseModel):
    items: list[SpeciesResponse]
    total: int
    category: str | None = None
