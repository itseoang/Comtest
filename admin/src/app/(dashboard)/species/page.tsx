"use client";

import { useEffect, useState, useCallback } from "react";
import { Plus } from "lucide-react";
import { adminApi } from "@/lib/api";
import type { SpeciesItem, SpeciesCreateRequest } from "@/lib/types";
import SpeciesTable from "@/components/SpeciesTable";
import SpeciesDetailModal from "@/components/SpeciesDetailModal";

const categories = [
  { value: "", label: "전체" },
  { value: "식물", label: "식물" },
  { value: "곤충", label: "곤충" },
  { value: "조류", label: "조류" },
  { value: "포유류", label: "포유류" },
  { value: "양서류", label: "양서류" },
  { value: "파충류", label: "파충류" },
  { value: "어류", label: "어류" },
  { value: "기타", label: "기타" },
];

const rarities = [
  { value: "common", label: "일반" },
  { value: "uncommon", label: "비일반" },
  { value: "rare", label: "희귀" },
  { value: "legendary", label: "전설" },
];

const emptyForm: SpeciesCreateRequest = {
  name: "",
  scientific_name: "",
  category: "식물",
  description: "",
  habitat: "",
  rarity: "common",
};

export default function SpeciesPage() {
  const [species, setSpecies] = useState<SpeciesItem[]>([]);
  const [query, setQuery] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("");
  const [error, setError] = useState("");

  // Modal state
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState<SpeciesCreateRequest>(emptyForm);
  const [saving, setSaving] = useState(false);

  // Delete confirmation
  const [deleteTarget, setDeleteTarget] = useState<SpeciesItem | null>(null);

  // Detail modal
  const [detailTarget, setDetailTarget] = useState<SpeciesItem | null>(null);

  const loadSpecies = useCallback(
    (q?: string, cat?: string) => {
      adminApi
        .getSpecies(q, cat)
        .then(setSpecies)
        .catch((err) => setError(err.message));
    },
    []
  );

  useEffect(() => {
    loadSpecies();
  }, [loadSpecies]);

  useEffect(() => {
    const timer = setTimeout(() => {
      loadSpecies(query || undefined, categoryFilter || undefined);
    }, 300);
    return () => clearTimeout(timer);
  }, [query, categoryFilter, loadSpecies]);

  // Open add modal
  const handleAdd = () => {
    setEditingId(null);
    setForm(emptyForm);
    setShowModal(true);
  };

  // Open edit modal
  const handleEdit = (item: SpeciesItem) => {
    setEditingId(item.id);
    setForm({
      name: item.name,
      scientific_name: item.scientific_name,
      category: item.category,
      description: item.description,
      habitat: item.habitat,
      rarity: item.rarity,
    });
    setShowModal(true);
  };

  // Submit form
  const handleSubmit = async () => {
    setSaving(true);
    try {
      if (editingId) {
        await adminApi.updateSpecies(editingId, form);
      } else {
        await adminApi.createSpecies(form);
      }
      setShowModal(false);
      loadSpecies(query || undefined, categoryFilter || undefined);
    } catch (err) {
      setError(err instanceof Error ? err.message : "저장에 실패했습니다");
    } finally {
      setSaving(false);
    }
  };

  // Confirm delete
  const handleDelete = (item: SpeciesItem) => {
    setDeleteTarget(item);
  };

  const confirmDelete = async () => {
    if (!deleteTarget) return;
    try {
      await adminApi.deleteSpecies(deleteTarget.id);
      setDeleteTarget(null);
      loadSpecies(query || undefined, categoryFilter || undefined);
    } catch (err) {
      setError(err instanceof Error ? err.message : "삭제에 실패했습니다");
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-nature-brown">종 관리</h1>
        <button
          onClick={handleAdd}
          className="flex items-center gap-2 px-4 py-2 text-sm rounded-lg bg-nature-green text-white hover:bg-nature-green-light transition-colors"
        >
          <Plus size={18} />
          새 종 추가
        </button>
      </div>

      <div className="flex gap-3">
        <input
          type="text"
          placeholder="종 이름 또는 학명으로 검색..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="flex-1 max-w-md px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green focus:border-transparent"
        />
        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green focus:border-transparent"
        >
          {categories.map((c) => (
            <option key={c.value} value={c.value}>
              {c.label}
            </option>
          ))}
        </select>
      </div>

      {error && (
        <div className="text-admin-red bg-red-50 p-4 rounded-lg">{error}</div>
      )}

      <SpeciesTable species={species} onEdit={handleEdit} onDelete={handleDelete} onRowClick={setDetailTarget} />

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-lg shadow-xl">
            <h2 className="text-lg font-semibold text-nature-brown mb-4">
              {editingId ? "종 수정" : "새 종 추가"}
            </h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">이름</label>
                <input
                  type="text"
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green"
                  placeholder="예: 소나무"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">학명</label>
                <input
                  type="text"
                  value={form.scientific_name}
                  onChange={(e) => setForm({ ...form, scientific_name: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green"
                  placeholder="예: Pinus densiflora"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">분류</label>
                  <select
                    value={form.category}
                    onChange={(e) => setForm({ ...form, category: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green"
                  >
                    {categories
                      .filter((c) => c.value !== "")
                      .map((c) => (
                        <option key={c.value} value={c.value}>
                          {c.label}
                        </option>
                      ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">희귀도</label>
                  <select
                    value={form.rarity}
                    onChange={(e) => setForm({ ...form, rarity: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green"
                  >
                    {rarities.map((r) => (
                      <option key={r.value} value={r.value}>
                        {r.label}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">서식지</label>
                <input
                  type="text"
                  value={form.habitat ?? ""}
                  onChange={(e) => setForm({ ...form, habitat: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green"
                  placeholder="예: 산지, 도시 공원"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">설명</label>
                <textarea
                  value={form.description ?? ""}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                  rows={3}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green resize-none"
                  placeholder="종에 대한 간단한 설명..."
                />
              </div>
            </div>
            <div className="flex gap-3 justify-end mt-6">
              <button
                onClick={() => setShowModal(false)}
                className="px-4 py-2 text-sm rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors"
              >
                취소
              </button>
              <button
                onClick={handleSubmit}
                disabled={saving || !form.name || !form.scientific_name}
                className="px-4 py-2 text-sm rounded-lg bg-nature-green text-white hover:bg-nature-green-light transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {saving ? "저장 중..." : editingId ? "수정" : "추가"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deleteTarget && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-sm shadow-xl">
            <h2 className="text-lg font-semibold text-nature-brown mb-2">종 삭제 확인</h2>
            <p className="text-sm text-gray-500 mb-4">
              <strong>{deleteTarget.name}</strong> ({deleteTarget.scientific_name})을(를) 정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.
            </p>
            <div className="flex gap-3 justify-end">
              <button
                onClick={() => setDeleteTarget(null)}
                className="px-4 py-2 text-sm rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors"
              >
                취소
              </button>
              <button
                onClick={confirmDelete}
                className="px-4 py-2 text-sm rounded-lg bg-admin-red text-white hover:bg-red-600 transition-colors"
              >
                삭제
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Species Detail Modal */}
      {detailTarget && (
        <SpeciesDetailModal species={detailTarget} onClose={() => setDetailTarget(null)} />
      )}
    </div>
  );
}
