"use client";

import { useEffect, useState, useCallback } from "react";
import { adminApi } from "@/lib/api";
import type { AdminUser, GuardianPair } from "@/lib/types";
import UserTable from "@/components/UserTable";
import GuardianPairView from "@/components/GuardianPairView";

type ViewMode = "pairs" | "all";

export default function UsersPage() {
  const [viewMode, setViewMode] = useState<ViewMode>("pairs");

  // 전체 보기 데이터
  const [users, setUsers] = useState<AdminUser[]>([]);

  // 쌍 보기 데이터
  const [pairs, setPairs] = useState<GuardianPair[]>([]);
  const [unlinkedUsers, setUnlinkedUsers] = useState<AdminUser[]>([]);

  const [query, setQuery] = useState("");
  const [error, setError] = useState("");
  const [modalUser, setModalUser] = useState<{ id: string; role: string } | null>(null);
  const [selectedRole, setSelectedRole] = useState("");

  const loadUsers = useCallback((q?: string) => {
    adminApi
      .getUsers(q)
      .then(setUsers)
      .catch((err) => setError(err.message));
  }, []);

  const loadPairs = useCallback((q?: string) => {
    adminApi
      .getGuardianPairs(q)
      .then((data) => {
        setPairs(data.pairs);
        setUnlinkedUsers(data.unlinked_users);
      })
      .catch((err) => setError(err.message));
  }, []);

  // 뷰 모드 변경 시 데이터 로드
  useEffect(() => {
    if (viewMode === "pairs") {
      loadPairs();
    } else {
      loadUsers();
    }
  }, [viewMode, loadPairs, loadUsers]);

  // 검색어 변경 시 디바운스 로드
  useEffect(() => {
    const timer = setTimeout(() => {
      if (viewMode === "pairs") {
        loadPairs(query || undefined);
      } else {
        loadUsers(query || undefined);
      }
    }, 300);
    return () => clearTimeout(timer);
  }, [query, viewMode, loadPairs, loadUsers]);

  const handleRoleChange = (userId: string, currentRole: string) => {
    setModalUser({ id: userId, role: currentRole });
    setSelectedRole(currentRole);
  };

  const confirmRoleChange = async () => {
    if (!modalUser) return;
    try {
      await adminApi.updateUserRole(modalUser.id, selectedRole);
      setModalUser(null);
      if (viewMode === "pairs") {
        loadPairs(query || undefined);
      } else {
        loadUsers(query || undefined);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "역할 변경에 실패했습니다");
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <h1 className="text-2xl font-bold text-nature-brown">사용자 관리</h1>

        {/* 뷰 전환 탭 */}
        <div className="flex bg-gray-100 rounded-lg p-0.5">
          <button
            onClick={() => setViewMode("pairs")}
            className={`px-4 py-1.5 text-sm font-medium rounded-md transition-colors ${
              viewMode === "pairs"
                ? "bg-white text-nature-brown shadow-sm"
                : "text-gray-500 hover:text-gray-700"
            }`}
          >
            쌍 보기
          </button>
          <button
            onClick={() => setViewMode("all")}
            className={`px-4 py-1.5 text-sm font-medium rounded-md transition-colors ${
              viewMode === "all"
                ? "bg-white text-nature-brown shadow-sm"
                : "text-gray-500 hover:text-gray-700"
            }`}
          >
            전체 보기
          </button>
        </div>
      </div>

      <div>
        <input
          type="text"
          placeholder="닉네임 또는 이메일로 검색..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="w-full max-w-md px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-nature-green focus:border-transparent"
        />
      </div>

      {error && (
        <div className="text-admin-red bg-red-50 p-4 rounded-lg">{error}</div>
      )}

      {viewMode === "pairs" ? (
        <GuardianPairView
          pairs={pairs}
          unlinkedUsers={unlinkedUsers}
          onRoleChange={handleRoleChange}
        />
      ) : (
        <UserTable users={users} onRoleChange={handleRoleChange} />
      )}

      {/* 역할 변경 모달 */}
      {modalUser && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-sm shadow-xl">
            <h2 className="text-lg font-semibold text-nature-brown mb-4">역할 변경</h2>
            <select
              value={selectedRole}
              onChange={(e) => setSelectedRole(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg mb-4 focus:outline-none focus:ring-2 focus:ring-nature-green"
            >
              <option value="user">사용자</option>
              <option value="guardian">보호자</option>
              <option value="admin">관리자</option>
            </select>
            <div className="flex gap-3 justify-end">
              <button
                onClick={() => setModalUser(null)}
                className="px-4 py-2 text-sm rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors"
              >
                취소
              </button>
              <button
                onClick={confirmRoleChange}
                className="px-4 py-2 text-sm rounded-lg bg-nature-green text-white hover:bg-nature-green-light transition-colors"
              >
                확인
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
