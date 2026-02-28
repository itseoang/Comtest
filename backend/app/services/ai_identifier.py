import base64
import json
import google.generativeai as genai
from app.config import get_settings

IDENTIFICATION_PROMPT = """당신은 동식물 분류 전문가입니다. 이 사진에 있는 생물을 식별해주세요.

반드시 아래 JSON 형식으로만 응답하세요 (다른 텍스트 없이):
{
    "korean_name": "한국어 이름 (일반명)",
    "scientific_name": "학술명 (라틴어)",
    "category": "카테고리 (insect/plant/fish/bird/mammal/reptile/amphibian/mushroom/marine 중 하나)",
    "subcategory": "세부 분류 (예: 나비목, 장미과 등)",
    "description": "아이들이 이해할 수 있는 쉬운 한국어 설명 (2-3문장)",
    "habitat": "서식지 (land/freshwater/sea/mountain/forest/urban/wetland 중 하나)",
    "rarity_tier": 1에서 5 사이 숫자 (1: 매우 흔함, 5: 매우 희귀),
    "fun_fact": "아이들이 좋아할 만한 재미있는 사실 (1문장)",
    "eco_message": "생명 존중과 관련된 따뜻한 메시지 (1문장, 반말체)",
    "confidence": 0에서 1 사이 소수 (식별 확신도)
}

중요:
- 사진이 동식물이 아닌 경우에도 최대한 자연물로 식별을 시도하세요.
- 정확히 종을 알 수 없으면 가장 가까운 종으로 식별하되 confidence를 낮게 설정하세요.
- 아이 대상 서비스이므로 eco_message는 존댓말이 아닌 따뜻한 반말체로 작성하세요.
- 위험한 생물(독사, 독버섯 등)의 경우 eco_message에 안전 경고를 포함하세요.
"""


async def identify_species(image_bytes: bytes, content_type: str) -> dict:
    """Gemini Vision API로 이미지 속 생물을 식별합니다."""
    settings = get_settings()

    genai.configure(api_key=settings.gemini_api_key)
    model = genai.GenerativeModel("gemini-1.5-flash")

    image_data = base64.b64encode(image_bytes).decode("utf-8")

    response = model.generate_content(
        [
            IDENTIFICATION_PROMPT,
            {"mime_type": content_type, "data": image_data},
        ]
    )

    response_text = response.text.strip()
    # JSON 블록 추출 (마크다운 코드블록 처리)
    if "```json" in response_text:
        response_text = response_text.split("```json")[1].split("```")[0].strip()
    elif "```" in response_text:
        response_text = response_text.split("```")[1].split("```")[0].strip()

    result = json.loads(response_text)

    # 카테고리 유효성 검증
    valid_categories = [
        "insect", "plant", "fish", "bird", "mammal",
        "reptile", "amphibian", "mushroom", "marine",
    ]
    if result.get("category") not in valid_categories:
        result["category"] = "insect"  # 기본값

    valid_habitats = [
        "land", "freshwater", "sea", "mountain", "forest", "urban", "wetland",
    ]
    if result.get("habitat") not in valid_habitats:
        result["habitat"] = "land"

    # rarity_tier 범위 보정
    rarity = result.get("rarity_tier", 1)
    result["rarity_tier"] = max(1, min(5, int(rarity)))

    return result
