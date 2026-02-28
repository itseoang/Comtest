import random

# 희귀도별 스탯 범위 (최소, 최대)
RARITY_RANGES = {
    1: (10, 50),   # 흔함
    2: (20, 65),   # 보통
    3: (35, 80),   # 희귀
    4: (50, 90),   # 매우 희귀
    5: (70, 100),  # 전설급
}

# 카테고리별 스탯 보정 (비율)
# (hp, attack, defense, speed, charm)
CATEGORY_MODIFIERS = {
    "insect": {
        "hp": 0.8, "attack": 0.9, "defense": 0.7,
        "speed": 1.3, "charm": 1.1,
    },
    "plant": {
        "hp": 1.2, "attack": 0.5, "defense": 1.4,
        "speed": 0.3, "charm": 1.2,
    },
    "fish": {
        "hp": 0.9, "attack": 0.8, "defense": 0.8,
        "speed": 1.2, "charm": 0.9,
    },
    "bird": {
        "hp": 0.8, "attack": 0.9, "defense": 0.7,
        "speed": 1.5, "charm": 1.2,
    },
    "mammal": {
        "hp": 1.2, "attack": 1.1, "defense": 1.1,
        "speed": 1.0, "charm": 1.0,
    },
    "reptile": {
        "hp": 1.0, "attack": 1.2, "defense": 1.3,
        "speed": 0.7, "charm": 0.8,
    },
    "amphibian": {
        "hp": 0.9, "attack": 0.7, "defense": 0.8,
        "speed": 0.9, "charm": 1.1,
    },
    "mushroom": {
        "hp": 0.7, "attack": 0.4, "defense": 1.0,
        "speed": 0.1, "charm": 1.3,
    },
    "marine": {
        "hp": 1.1, "attack": 1.0, "defense": 1.0,
        "speed": 1.1, "charm": 1.0,
    },
}


def generate_random_stats(rarity_tier: int, category: str) -> dict:
    """희귀도와 카테고리 기반으로 랜덤 스탯을 생성합니다.

    Args:
        rarity_tier: 1-5 희귀도
        category: 종 카테고리

    Returns:
        {'hp': int, 'attack': int, 'defense': int, 'speed': int, 'charm': int, 'rarity_score': int}
    """
    rarity_tier = max(1, min(5, rarity_tier))
    stat_min, stat_max = RARITY_RANGES[rarity_tier]
    modifiers = CATEGORY_MODIFIERS.get(category, {
        "hp": 1.0, "attack": 1.0, "defense": 1.0,
        "speed": 1.0, "charm": 1.0,
    })

    stats = {}
    for stat_name in ["hp", "attack", "defense", "speed", "charm"]:
        base = random.randint(stat_min, stat_max)
        modifier = modifiers.get(stat_name, 1.0)
        value = int(base * modifier)
        stats[stat_name] = max(1, min(100, value))

    # 희귀 점수: 모든 스탯의 가중 평균 + 희귀도 보너스
    total = sum(stats.values())
    rarity_bonus = rarity_tier * 8
    stats["rarity_score"] = max(1, min(100, total // 5 + rarity_bonus))

    return stats
