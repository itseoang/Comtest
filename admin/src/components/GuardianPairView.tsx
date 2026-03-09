import type { GuardianPair, AdminUser } from "@/lib/types";
import RoleBadge from "./RoleBadge";

interface GuardianPairViewProps {
  pairs: GuardianPair[];
  unlinkedUsers: AdminUser[];
  onRoleChange: (userId: string, currentRole: string) => void;
}

function UserRow({
  user,
  onRoleChange,
  isChild,
}: {
  user: AdminUser;
  onRoleChange: (userId: string, currentRole: string) => void;
  isChild?: boolean;
}) {
  return (
    <div
      className={`flex items-center justify-between py-2.5 px-3 rounded-lg hover:bg-gray-50/80 transition-colors ${
        isChild ? "ml-6" : ""
      }`}
    >
      <div className="flex items-center gap-3 min-w-0 flex-1">
        {isChild && (
          <span className="text-gray-300 text-sm font-mono flex-shrink-0">
            └─
          </span>
        )}
        {!isChild && (
          <span className="text-base flex-shrink-0" title="보호자">
            🛡️
          </span>
        )}
        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <span
              className={`text-sm text-nature-brown truncate ${
                !isChild ? "font-semibold" : "font-medium"
              }`}
            >
              {user.nickname}
            </span>
            <button onClick={() => onRoleChange(user.id, user.role)}>
              <RoleBadge role={user.role} />
            </button>
          </div>
          <p className="text-xs text-gray-400 truncate">{user.email}</p>
        </div>
      </div>
      <div className="flex items-center gap-6 flex-shrink-0 text-xs text-gray-500">
        <span>
          최근{" "}
          {new Date(user.lastActive).toLocaleDateString("ko-KR", {
            month: "short",
            day: "numeric",
          })}
        </span>
        <span className="font-medium text-nature-brown">
          {user.collections}종
        </span>
      </div>
    </div>
  );
}

export default function GuardianPairView({
  pairs,
  unlinkedUsers,
  onRoleChange,
}: GuardianPairViewProps) {
  return (
    <div className="space-y-4">
      {/* 보호자-자녀 쌍 카드 */}
      {pairs.map((pair) => (
        <div
          key={pair.guardian.id}
          className="bg-white rounded-2xl shadow-sm border border-gray-100 border-l-4 border-l-nature-green overflow-hidden"
        >
          <div className="p-4 space-y-1">
            {/* 보호자 행 */}
            <UserRow
              user={pair.guardian}
              onRoleChange={onRoleChange}
              isChild={false}
            />
            {/* 구분선 */}
            <div className="ml-6 border-t border-dashed border-gray-200" />
            {/* 자녀 행들 */}
            {pair.children.map((child) => (
              <UserRow
                key={child.id}
                user={child}
                onRoleChange={onRoleChange}
                isChild={true}
              />
            ))}
          </div>
          <div className="bg-gray-50/50 px-4 py-2 text-xs text-gray-400">
            연결된 자녀 {pair.children.length}명
          </div>
        </div>
      ))}

      {pairs.length === 0 && unlinkedUsers.length === 0 && (
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 text-center text-gray-400 text-sm">
          검색 결과가 없습니다
        </div>
      )}

      {/* 보호자 미연결 사용자 섹션 */}
      {unlinkedUsers.length > 0 && (
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 border-l-4 border-l-orange-400 overflow-hidden">
          <div className="px-4 py-3 bg-orange-50/50 flex items-center gap-2">
            <span className="text-orange-500 text-base">⚠️</span>
            <h3 className="text-sm font-semibold text-orange-700">
              보호자 미연결 사용자
            </h3>
            <span className="text-xs text-orange-400 ml-auto">
              {unlinkedUsers.length}명
            </span>
          </div>
          <div className="p-4 space-y-1">
            {unlinkedUsers.map((user) => (
              <div
                key={user.id}
                className="flex items-center justify-between py-2.5 px-3 rounded-lg hover:bg-gray-50/80 transition-colors"
              >
                <div className="flex items-center gap-3 min-w-0 flex-1">
                  <span className="text-gray-300 text-sm">●</span>
                  <div className="min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-sm font-medium text-nature-brown truncate">
                        {user.nickname}
                      </span>
                      <button
                        onClick={() => onRoleChange(user.id, user.role)}
                      >
                        <RoleBadge role={user.role} />
                      </button>
                    </div>
                    <p className="text-xs text-gray-400 truncate">
                      {user.email}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-6 flex-shrink-0 text-xs text-gray-500">
                  <span>
                    최근{" "}
                    {new Date(user.lastActive).toLocaleDateString("ko-KR", {
                      month: "short",
                      day: "numeric",
                    })}
                  </span>
                  <span className="font-medium text-nature-brown">
                    {user.collections}종
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
