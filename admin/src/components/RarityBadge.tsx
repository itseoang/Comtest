const rarityConfig: Record<string, { label: string; className: string }> = {
  common: { label: "일반", className: "bg-gray-100 text-gray-700" },
  uncommon: { label: "비일반", className: "bg-green-100 text-green-700" },
  rare: { label: "희귀", className: "bg-blue-100 text-blue-700" },
  legendary: { label: "전설", className: "bg-purple-100 text-purple-700" },
};

interface RarityBadgeProps {
  rarity: string;
}

export default function RarityBadge({ rarity }: RarityBadgeProps) {
  const config = rarityConfig[rarity] || rarityConfig.common;
  return (
    <span className={`text-xs px-2 py-1 rounded font-medium ${config.className}`}>
      {config.label}
    </span>
  );
}
