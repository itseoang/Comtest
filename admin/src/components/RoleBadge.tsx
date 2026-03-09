interface RoleBadgeProps {
  role: string;
}

const roleStyles: Record<string, string> = {
  user: "bg-gray-100 text-gray-600",
  guardian: "bg-blue-100 text-blue-700",
  admin: "bg-red-100 text-admin-red",
};

const roleLabels: Record<string, string> = {
  user: "사용자",
  guardian: "보호자",
  admin: "관리자",
};

export default function RoleBadge({ role }: RoleBadgeProps) {
  return (
    <span
      className={`inline-block px-2.5 py-0.5 rounded-full text-xs font-medium ${
        roleStyles[role] || roleStyles.user
      }`}
    >
      {roleLabels[role] || role}
    </span>
  );
}
