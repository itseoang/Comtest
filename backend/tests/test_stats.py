import pytest
from app.utils.stats import generate_random_stats, RARITY_RANGES, CATEGORY_MODIFIERS


class TestGenerateRandomStats:
    def test_returns_all_stat_keys(self):
        stats = generate_random_stats(1, "insect")
        expected_keys = {"hp", "attack", "defense", "speed", "charm", "rarity_score"}
        assert set(stats.keys()) == expected_keys

    def test_stats_within_valid_range(self):
        for rarity in range(1, 6):
            for category in CATEGORY_MODIFIERS:
                stats = generate_random_stats(rarity, category)
                for key, value in stats.items():
                    assert 1 <= value <= 100, (
                        f"Stat {key}={value} out of range for "
                        f"rarity={rarity}, category={category}"
                    )

    def test_higher_rarity_tends_higher_stats(self):
        """높은 희귀도가 평균적으로 높은 스탯을 생성하는지 확인"""
        samples = 100
        avg_low = 0
        avg_high = 0

        for _ in range(samples):
            low = generate_random_stats(1, "mammal")
            high = generate_random_stats(5, "mammal")
            avg_low += sum(v for k, v in low.items() if k != "rarity_score")
            avg_high += sum(v for k, v in high.items() if k != "rarity_score")

        avg_low /= samples
        avg_high /= samples
        assert avg_high > avg_low

    def test_category_modifiers_affect_stats(self):
        """카테고리 보정이 스탯에 영향을 미치는지 확인"""
        samples = 200
        bird_speed_total = 0
        plant_speed_total = 0

        for _ in range(samples):
            bird = generate_random_stats(3, "bird")
            plant = generate_random_stats(3, "plant")
            bird_speed_total += bird["speed"]
            plant_speed_total += plant["speed"]

        # 새가 식물보다 속도가 높아야 함
        assert bird_speed_total / samples > plant_speed_total / samples

    def test_invalid_rarity_clamped(self):
        stats = generate_random_stats(0, "insect")
        assert all(1 <= v <= 100 for v in stats.values())

        stats = generate_random_stats(10, "insect")
        assert all(1 <= v <= 100 for v in stats.values())

    def test_unknown_category_uses_defaults(self):
        stats = generate_random_stats(3, "unknown_category")
        assert set(stats.keys()) == {"hp", "attack", "defense", "speed", "charm", "rarity_score"}
        assert all(1 <= v <= 100 for v in stats.values())

    def test_rarity_score_increases_with_tier(self):
        samples = 100
        scores = {}
        for rarity in [1, 3, 5]:
            total = 0
            for _ in range(samples):
                stats = generate_random_stats(rarity, "mammal")
                total += stats["rarity_score"]
            scores[rarity] = total / samples

        assert scores[5] > scores[3] > scores[1]
