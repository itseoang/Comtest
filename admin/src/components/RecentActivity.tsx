import { Camera, BookOpen, Brain, Trophy } from "lucide-react";
import type { ContentItem } from "@/lib/types";

const typeIcons: Record<string, typeof Camera> = {
  discovery: Camera,
  diary: BookOpen,
  quiz: Brain,
  challenge: Trophy,
};

const typeLabels: Record<string, string> = {
  discovery: "발견",
  diary: "일기",
  quiz: "퀴즈",
  challenge: "챌린지",
};

interface RecentActivityProps {
  items: ContentItem[];
}

export default function RecentActivity({ items }: RecentActivityProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100">
      <div className="p-5 border-b border-gray-100">
        <h2 className="text-lg font-semibold text-nature-brown">최근 활동</h2>
      </div>
      <div className="divide-y divide-gray-50">
        {items.map((item) => {
          const Icon = typeIcons[item.type] || Camera;
          return (
            <div key={item.id} className="flex items-center gap-4 p-4">
              <div className="w-9 h-9 rounded-lg bg-green-50 flex items-center justify-center">
                <Icon size={18} className="text-nature-green" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-nature-brown truncate">{item.title}</p>
                <p className="text-xs text-gray-400">{item.author}</p>
              </div>
              <div className="text-right">
                <span className="text-xs text-gray-400 bg-gray-50 px-2 py-1 rounded">
                  {typeLabels[item.type] || item.type}
                </span>
                <p className="text-xs text-gray-400 mt-1">
                  {new Date(item.createdAt).toLocaleDateString("ko-KR")}
                </p>
              </div>
            </div>
          );
        })}
        {items.length === 0 && (
          <div className="p-8 text-center text-gray-400 text-sm">
            최근 활동이 없습니다
          </div>
        )}
      </div>
    </div>
  );
}
