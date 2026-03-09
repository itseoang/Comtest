import type { LucideIcon } from "lucide-react";

interface ContentCardProps {
  title: string;
  count: number;
  icon: LucideIcon;
  color: string;
}

export default function ContentCard({ title, count, icon: Icon, color }: ContentCardProps) {
  return (
    <div className="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
      <div className="flex items-center gap-4">
        <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${color}`}>
          <Icon size={24} className="text-white" />
        </div>
        <div>
          <p className="text-sm text-gray-500">{title}</p>
          <p className="text-2xl font-bold text-nature-brown">{count}</p>
        </div>
      </div>
    </div>
  );
}
