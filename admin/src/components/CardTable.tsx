import type { CardItem } from "@/lib/types";
import { ArrowUpDown } from "lucide-react";

export type CardSortKey = "rarity_desc" | "rarity_asc" | "power_desc" | "recent";

interface CardTableProps {
  cards: CardItem[];
  sortKey?: CardSortKey;
  onSortChange?: (key: CardSortKey) => void;
}

function StatBar({ value, max = 100 }: { value: number; max?: number }) {
  const pct = Math.min((value / max) * 100, 100);
  return (
    <div className="flex items-center gap-1.5">
      <div className="w-12 h-1.5 bg-gray-100 rounded-full overflow-hidden">
        <div
          className="h-full bg-nature-green rounded-full"
          style={{ width: `${pct}%` }}
        />
      </div>
      <span className="text-xs text-gray-500 w-6 text-right">{value}</span>
    </div>
  );
}

function rarityColor(score: number): string {
  if (score >= 4.5) return "text-purple-600 font-bold";
  if (score >= 3.5) return "text-blue-600 font-bold";
  if (score >= 2.0) return "text-green-600 font-semibold";
  return "text-gray-500";
}

function SortableHeader({
  label,
  sortKey,
  currentSort,
  onSort,
}: {
  label: string;
  sortKey: CardSortKey;
  currentSort?: CardSortKey;
  onSort?: (key: CardSortKey) => void;
}) {
  const active = currentSort === sortKey;
  return (
    <th
      className={`text-center px-5 py-3 text-xs font-medium uppercase cursor-pointer select-none hover:text-nature-green transition-colors ${active ? "text-nature-green" : "text-gray-500"}`}
      onClick={() => onSort?.(sortKey)}
    >
      <span className="inline-flex items-center gap-1">
        {label}
        <ArrowUpDown size={12} />
      </span>
    </th>
  );
}

export default function CardTable({ cards, sortKey, onSortChange }: CardTableProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <table className="w-full">
        <thead>
          <tr className="border-b border-gray-100 bg-gray-50/50">
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">종 이름</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">수집자</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">발견일</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">위치</th>
            <SortableHeader label="희귀도" sortKey={sortKey === "rarity_asc" ? "rarity_desc" : "rarity_asc"} currentSort={sortKey} onSort={onSortChange} />
            <th className="text-center px-3 py-3 text-xs font-medium text-gray-500 uppercase">HP</th>
            <th className="text-center px-3 py-3 text-xs font-medium text-gray-500 uppercase">ATK</th>
            <th className="text-center px-3 py-3 text-xs font-medium text-gray-500 uppercase">DEF</th>
            <th className="text-center px-3 py-3 text-xs font-medium text-gray-500 uppercase">SPD</th>
            <th className="text-center px-3 py-3 text-xs font-medium text-gray-500 uppercase">CHM</th>
            <SortableHeader label="전투력" sortKey="power_desc" currentSort={sortKey} onSort={onSortChange} />
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-50">
          {cards.map((card) => {
            const totalPower = card.hp + card.attack + card.defense + card.speed + card.charm;
            return (
              <tr key={card.id} className="hover:bg-gray-50/50 transition-colors">
                <td className="px-5 py-3 text-sm font-medium text-nature-brown">{card.species_name}</td>
                <td className="px-5 py-3 text-sm text-gray-500">{card.collector_nickname}</td>
                <td className="px-5 py-3 text-sm text-gray-500">
                  {new Date(card.discovered_at).toLocaleDateString("ko-KR")}
                </td>
                <td className="px-5 py-3 text-sm text-gray-500">{card.location}</td>
                <td className="px-5 py-3 text-center">
                  <span className={`text-xs ${rarityColor(card.rarity_score)}`}>{card.rarity_score}</span>
                </td>
                <td className="px-3 py-3"><StatBar value={card.hp} /></td>
                <td className="px-3 py-3"><StatBar value={card.attack} /></td>
                <td className="px-3 py-3"><StatBar value={card.defense} /></td>
                <td className="px-3 py-3"><StatBar value={card.speed} /></td>
                <td className="px-3 py-3"><StatBar value={card.charm} /></td>
                <td className="px-3 py-3 text-center">
                  <span className="text-xs font-bold text-indigo-600">{totalPower}</span>
                </td>
              </tr>
            );
          })}
          {cards.length === 0 && (
            <tr>
              <td colSpan={11} className="px-5 py-8 text-center text-gray-400 text-sm">
                카드가 없습니다
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
