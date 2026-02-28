from app.utils.stats import generate_random_stats


def generate_stats(rarity_tier: int, category: str) -> dict:
    """종의 희귀도와 카테고리를 기반으로 카드 스탯을 생성합니다."""
    return generate_random_stats(rarity_tier, category)


def generate_card_number_local() -> str:
    """로컬에서 임시 카드 번호를 생성합니다.
    실제 카드 번호는 서버(DB 트리거)에서 부여됩니다.
    """
    import uuid
    return f"NC-LOCAL-{uuid.uuid4().hex[:8].upper()}"
