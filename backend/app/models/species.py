from dataclasses import dataclass
from datetime import datetime

VALID_CATEGORIES = [
    "insect", "plant", "fish", "bird", "mammal",
    "reptile", "amphibian", "mushroom", "marine",
]

VALID_HABITATS = [
    "land", "freshwater", "sea", "mountain", "forest", "urban", "wetland",
]

CATEGORY_NAMES_KR = {
    "insect": "곤충",
    "plant": "식물",
    "fish": "어류",
    "bird": "조류",
    "mammal": "포유류",
    "reptile": "파충류",
    "amphibian": "양서류",
    "mushroom": "버섯",
    "marine": "해양생물",
}

CATEGORY_COLORS = {
    "insect": "#2E7D32",
    "plant": "#66BB6A",
    "fish": "#1565C0",
    "bird": "#FF8F00",
    "mammal": "#8D6E63",
    "reptile": "#7B1FA2",
    "amphibian": "#00897B",
    "mushroom": "#D84315",
    "marine": "#0277BD",
}


@dataclass
class Species:
    id: int
    korean_name: str
    scientific_name: str | None
    category: str
    subcategory: str | None = None
    description: str | None = None
    habitat: str | None = None
    rarity_tier: int = 1
    color_code: str | None = None
    fun_fact: str | None = None
    eco_message: str | None = None
    image_url: str | None = None
    created_at: datetime | None = None

    @classmethod
    def from_dict(cls, data: dict) -> "Species":
        return cls(
            id=data["id"],
            korean_name=data["korean_name"],
            scientific_name=data.get("scientific_name"),
            category=data["category"],
            subcategory=data.get("subcategory"),
            description=data.get("description"),
            habitat=data.get("habitat"),
            rarity_tier=data.get("rarity_tier", 1),
            color_code=data.get("color_code"),
            fun_fact=data.get("fun_fact"),
            eco_message=data.get("eco_message"),
            image_url=data.get("image_url"),
            created_at=data.get("created_at"),
        )
