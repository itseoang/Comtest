"use client";

import { useEffect, useState } from "react";
import { X, Users, CreditCard, Loader2 } from "lucide-react";
import { adminApi } from "@/lib/api";
import type { SpeciesItem, SpeciesDetail, SpeciesCardOwner } from "@/lib/types";
import RarityBadge from "./RarityBadge";

interface SpeciesDetailModalProps {
  species: SpeciesItem;
  onClose: () => void;
}

function RankDisplay({ rank }: { rank: number }) {
  if (rank === 1) return <span className="text-lg">&#x1F947;</span>;
  if (rank === 2) return <span className="text-lg">&#x1F948;</span>;
  if (rank === 3) return <span className="text-lg">&#x1F949;</span>;
  return <span className="text-sm text-gray-500 font-medium">{rank}</span>;
}

function rankRowClass(rank: number): string {
  if (rank === 1) return "bg-yellow-50/80";
  if (rank === 2) return "bg-gray-50/80";
  if (rank === 3) return "bg-orange-50/60";
  return "";
}

function rarityScoreLabel(score: number): string {
  if (score >= 4.5) return "전설급";
  if (score >= 3.5) return "희귀";
  if (score >= 2.0) return "비일반";
  return "일반";
}

export default function SpeciesDetailModal({ species, onClose }: SpeciesDetailModalProps) {
  const [detail, setDetail] = useState<SpeciesDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    setLoading(true);
    setError("");
    adminApi
      .getSpeciesDetail(species.id)
      .then(setDetail)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [species.id]);

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-3xl max-h-[85vh] overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-start justify-between p-6 border-b border-gray-100">
          <div>
            <div className="flex items-center gap-3 mb-1">
              <h2 className="text-xl font-bold text-nature-brown">{species.name}</h2>
              <RarityBadge rarity={species.rarity} />
              <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                {species.category}
              </span>
            </div>
            <p className="text-sm text-gray-500 italic">{species.scientific_name}</p>
            {species.habitat && (
              <p className="text-xs text-gray-400 mt-1">서식지: {species.habitat}</p>
            )}
            {species.description && (
              <p className="text-sm text-gray-600 mt-2">{species.description}</p>
            )}
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto p-6">
          {loading && (
            <div className="flex items-center justify-center py-16">
              <Loader2 size={32} className="text-nature-green animate-spin" />
              <span className="ml-3 text-gray-500">로딩 중...</span>
            </div>
          )}

          {error && (
            <div className="text-admin-red bg-red-50 p-4 rounded-lg">{error}</div>
          )}

          {detail && !loading && (
            <>
              {/* Stats summary */}
              <div className="grid grid-cols-2 gap-4 mb-6">
                <div className="bg-cream rounded-xl p-4 flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg flex items-center justify-center bg-nature-green">
                    <CreditCard size={20} className="text-white" />
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">전체 카드</p>
                    <p className="text-xl font-bold text-nature-brown">{detail.total_cards}장</p>
                  </div>
                </div>
                <div className="bg-cream rounded-xl p-4 flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg flex items-center justify-center bg-amber-500">
                    <Users size={20} className="text-white" />
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">보유 회원</p>
                    <p className="text-xl font-bold text-nature-brown">{detail.unique_owners}명</p>
                  </div>
                </div>
              </div>

              {/* Owner ranking table */}
              <h3 className="text-lg font-semibold text-nature-brown mb-3">보유자 순위</h3>
              {detail.owners.length === 0 ? (
                <p className="text-sm text-gray-400 text-center py-8">
                  이 종의 카드를 보유한 회원이 없습니다.
                </p>
              ) : (
                <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-gray-100 bg-gray-50/50">
                        <th className="text-center px-3 py-3 text-xs font-medium text-gray-500 uppercase w-14">순위</th>
                        <th className="text-left px-4 py-3 text-xs font-medium text-gray-500 uppercase">닉네임</th>
                        <th className="text-center px-3 py-3 text-xs font-medium text-gray-500 uppercase">보유 카드</th>
                        <th className="text-center px-3 py-3 text-xs font-medium text-gray-500 uppercase">최고 희귀도</th>
                        <th className="text-center px-3 py-3 text-xs font-medium text-gray-500 uppercase">총 전투력</th>
                        <th className="text-left px-4 py-3 text-xs font-medium text-gray-500 uppercase">최초 발견</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-50">
                      {detail.owners.map((owner: SpeciesCardOwner) => (
                        <tr key={owner.user_id} className={`${rankRowClass(owner.rank)} transition-colors`}>
                          <td className="px-3 py-3 text-center">
                            <RankDisplay rank={owner.rank} />
                          </td>
                          <td className="px-4 py-3">
                            <div>
                              <span className="text-sm font-medium text-nature-brown">{owner.nickname}</span>
                              <p className="text-xs text-gray-400">{owner.email}</p>
                            </div>
                          </td>
                          <td className="px-3 py-3 text-center">
                            <span className="text-sm font-bold text-nature-brown">{owner.cards_count}</span>
                          </td>
                          <td className="px-3 py-3 text-center">
                            <div className="flex flex-col items-center">
                              <span className="text-sm font-bold text-nature-green">{owner.best_rarity_score}</span>
                              <span className="text-[10px] text-gray-400">{rarityScoreLabel(owner.best_rarity_score)}</span>
                            </div>
                          </td>
                          <td className="px-3 py-3 text-center">
                            <span className="text-sm font-bold text-indigo-600">{owner.total_power}</span>
                          </td>
                          <td className="px-4 py-3 text-sm text-gray-500">
                            {new Date(owner.first_discovered).toLocaleDateString("ko-KR")}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
