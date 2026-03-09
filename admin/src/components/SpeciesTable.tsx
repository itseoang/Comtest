import type { SpeciesItem } from "@/lib/types";
import RarityBadge from "./RarityBadge";
import { Pencil, Trash2 } from "lucide-react";

interface SpeciesTableProps {
  species: SpeciesItem[];
  onEdit: (item: SpeciesItem) => void;
  onDelete: (item: SpeciesItem) => void;
  onRowClick?: (item: SpeciesItem) => void;
}

export default function SpeciesTable({ species, onEdit, onDelete, onRowClick }: SpeciesTableProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <table className="w-full">
        <thead>
          <tr className="border-b border-gray-100 bg-gray-50/50">
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">이름</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">학명</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">분류</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">서식지</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">희귀도</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">등록일</th>
            <th className="text-right px-5 py-3 text-xs font-medium text-gray-500 uppercase">작업</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-50">
          {species.map((item) => (
            <tr
              key={item.id}
              className={`hover:bg-gray-50/50 transition-colors ${onRowClick ? "cursor-pointer" : ""}`}
              onClick={() => onRowClick?.(item)}
            >
              <td className="px-5 py-3 text-sm font-medium text-nature-brown">{item.name}</td>
              <td className="px-5 py-3 text-sm text-gray-500 italic">{item.scientific_name}</td>
              <td className="px-5 py-3">
                <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                  {item.category}
                </span>
              </td>
              <td className="px-5 py-3 text-sm text-gray-500">{item.habitat}</td>
              <td className="px-5 py-3">
                <RarityBadge rarity={item.rarity} />
              </td>
              <td className="px-5 py-3 text-sm text-gray-500">
                {new Date(item.created_at).toLocaleDateString("ko-KR")}
              </td>
              <td className="px-5 py-3 text-right">
                <div className="flex items-center justify-end gap-2">
                  <button
                    onClick={(e) => { e.stopPropagation(); onEdit(item); }}
                    className="p-1.5 rounded-lg text-gray-400 hover:text-nature-green hover:bg-green-50 transition-colors"
                    title="수정"
                  >
                    <Pencil size={16} />
                  </button>
                  <button
                    onClick={(e) => { e.stopPropagation(); onDelete(item); }}
                    className="p-1.5 rounded-lg text-gray-400 hover:text-admin-red hover:bg-red-50 transition-colors"
                    title="삭제"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              </td>
            </tr>
          ))}
          {species.length === 0 && (
            <tr>
              <td colSpan={7} className="px-5 py-8 text-center text-gray-400 text-sm">
                등록된 종이 없습니다
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
