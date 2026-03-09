import type { AdminUser } from "@/lib/types";
import RoleBadge from "./RoleBadge";

interface UserTableProps {
  users: AdminUser[];
  onRoleChange: (userId: string, currentRole: string) => void;
}

export default function UserTable({ users, onRoleChange }: UserTableProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <table className="w-full">
        <thead>
          <tr className="border-b border-gray-100 bg-gray-50/50">
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">닉네임</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">이메일</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">역할</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">가입일</th>
            <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">최근 활동</th>
            <th className="text-right px-5 py-3 text-xs font-medium text-gray-500 uppercase">수집</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-50">
          {users.map((user) => (
            <tr key={user.id} className="hover:bg-gray-50/50 transition-colors">
              <td className="px-5 py-3 text-sm font-medium text-nature-brown">{user.nickname}</td>
              <td className="px-5 py-3 text-sm text-gray-500">{user.email}</td>
              <td className="px-5 py-3">
                <button onClick={() => onRoleChange(user.id, user.role)}>
                  <RoleBadge role={user.role} />
                </button>
              </td>
              <td className="px-5 py-3 text-sm text-gray-500">
                {new Date(user.joinedAt).toLocaleDateString("ko-KR")}
              </td>
              <td className="px-5 py-3 text-sm text-gray-500">
                {new Date(user.lastActive).toLocaleDateString("ko-KR")}
              </td>
              <td className="px-5 py-3 text-sm text-right text-nature-brown font-medium">
                {user.collections}
              </td>
            </tr>
          ))}
          {users.length === 0 && (
            <tr>
              <td colSpan={6} className="px-5 py-8 text-center text-gray-400 text-sm">
                사용자가 없습니다
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
