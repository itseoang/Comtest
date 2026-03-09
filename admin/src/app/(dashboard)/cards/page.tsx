"use client";

import { useEffect, useState, useCallback, useMemo } from "react";
import { CreditCard, Calendar, Star, Crown } from "lucide-react";
import { adminApi } from "@/lib/api";
import type { CardItem, CardStats } from "@/lib/types";
import CardTable from "@/components/CardTable";
import type { CardSortKey } from "@/components/CardTable";
import ContentCard from "@/components/ContentCard";

type RarityFilter = "all" | "common" | "uncommon" | "rare" | "legendary";

const rarityOptions: { value: RarityFilter; label: string }[] = [
  { value: "all", label: "전체" },
  { value: "common", label: "일반 (1.0~1.9)" },
  { value: "uncommon", label: "비일반 (2.0~3.4)" },
  { value: "rare", label: "희귀 (3.5~4.4)" },
  { value: "legendary", label: "전설 (4.5+)" },
];

const sortOptions: { value: CardSortKey; label: string }[] = [
  { value: "rarity_desc", label: "희귀도 높은순" },
  { value: "rarity_asc", label: "희귀도 낮은순" },
  { value: "power_desc", label: "전투력 높은순" },
  { value: "recent", label: "최근 발견순" },
];

function rarityBucket(score: number): RarityFilter {
  if (score >= 4.5) return "legendary";
  if (score >= 3.5) return "rare";
  if (score >= 2.0) return "uncommon";
  return "common";
}

export default function CardsPage() {
  const [cards, setCards] = useState<CardItem[]>([]);
  const [stats, setStats] = useState<CardStats | null>(null);
  const [query, setQuery] = useState("");
  const [error, setError] = useState("");
  const [rarityFilter, setRarityFilter] = useState<RarityFilter>("all");
  const [sortKey, setSortKey] = useState<CardSortKey>("rarity_desc");

  const loadCards = useCallback((q?: string) => {
    adminApi
      .getCards(q)
      .then(setCards)
      .catch((err) => setError(err.message));
  }, []);

  useEffect(() => {
    loadCards();
    adminApi
      .getCardStats()
      .then(setStats)
      .catch((err) => setError(err.message));
  }, [loadCards]);

  useEffect(() => {
    const timer = setTimeout(() => {
      loadCards(query || undefined);
    }, 300);
    return () => clearTimeout(timer);
  }, [query, loadCards]);

  // 필터 + 정렬 적용
  const processedCards = useMemo(() => {
    let result = [...cards];

    // 희귀도 필터
    if (rarityFilter !== "all") {
      result = result.filter((c) => rarityBucket(c.rarity_score) === rarityFilter);
    }

    // 정렬
    switch (sortKey) {
      case "rarity_desc":
        result.sort((a, b) => b.rarity_score - a.rarity_score);
        break;
      case "rarity_asc":
        result.sort((a, b) => a.rarity_score - b.rarity_score);
        break;
      case "power_desc":
        result.sort((a, b) => {
          const pa = a.hp + a.attack + a.defense + a.speed + a.charm;
          const pb = b.hp + b.attack + b.defense + b.speed + b.charm;
          return pb - pa;
        });
        break;
      case "recent":
        result.sort((a, b) => new Date(b.discovered_at).getTime() - new Date(a.discovered_at).getTime());
        break;
    }

    return result;
  }, [cards, rarityFilter, sortKey]);

  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-bold text-nature-brown">카드 관리</h1>

      {error && (
        <div className="text-admin-red bg-red-50 p-4 rounded-lg">{error}</div>
      )}

      {/* Stats Cards */}
      {stats && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <ContentCard
            title="총 카드수"
            count={stats.total_cards}
            icon={CreditCard}
            color="bg-nature-green"
          />
          <ContentCard
            title="오늘 발급"
            count={stats.cards_today}
            icon={Calendar}
            color="bg-amber-500"
          />
          <div className="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl flex items-center justify-center bg-indigo-500">
                <Star size={24} className="text-white" />
              </div>
              <div>
                <p className="text-sm text-gray-500">가장 많이 수집된 종</p>
                <p className="text-lg font-bold text-nature-brown truncate">
                  {stats.most_collected_species || "-"}
                </p>
              </div>
            </div>
          </div>
          <div className="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl flex items-center justify-center bg-purple-500">
                <Crown size={24} className="text-white" />
              </div>
              <div>
                <p className="text-sm text-gray-500">가장 희귀 카드 소유자</p>
                <p className="text-lg font-bold text-nature-brown truncate">
                  {stats.rarest_card_owner || "-"}
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Category Breakdown */}
      {stats && Object.keys(stats.category_breakdown).length > 0 && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-lg font-semibold text-nature-brown mb-4">카테고리 분포</h2>
          <div className="space-y-3">
            {(() => {
              const entries = Object.entries(stats.category_breakdown);
              const maxVal = Math.max(...entries.map(([, v]) => v), 1);
              return entries.map(([category, count]) => (
                <div key={category} className="flex items-center gap-3">
                  <span className="text-sm text-gray-600 w-16 shrink-0">{category}</span>
                  <div className="flex-1 h-6 bg-gray-100 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-nature-green rounded-full transition-all"
                      style={{ width: `${(count / maxVal) * 100}%` }}
                    />
                  </div>
                  <span className="text-sm font-medium text-nature-brown w-10 text-right">
                    {count}
                  </span>
                </div>
              ));
            })()}
          </div>
        </div>
      )}

      {/* Search + Filters */}
      <div className="flex flex-wrap gap-3 items-center">
        <input
          type="text"
          placeholder="종 이름 또는 수집자로 검색..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="flex-1 min-w-[200px] max-w-md px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green focus:border-transparent"
        />
        <select
          value={rarityFilter}
          onChange={(e) => setRarityFilter(e.target.value as RarityFilter)}
          className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green focus:border-transparent"
        >
          {rarityOptions.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
        <select
          value={sortKey}
          onChange={(e) => setSortKey(e.target.value as CardSortKey)}
          className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green focus:border-transparent"
        >
          {sortOptions.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
        {rarityFilter !== "all" && (
          <span className="text-xs text-gray-500">
            {processedCards.length}장 표시 / 전체 {cards.length}장
          </span>
        )}
      </div>

      <CardTable cards={processedCards} sortKey={sortKey} onSortChange={setSortKey} />
    </div>
  );
}
