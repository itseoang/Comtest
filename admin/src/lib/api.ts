import { getToken, removeToken } from "./auth";
import type {
  AdminLoginResponse,
  AdminUser,
  ContentItem,
  ContentSummary,
  DashboardData,
  SpeciesItem,
  SpeciesCreateRequest,
  CardItem,
  CardStats,
  SpeciesDetail,
  GuardianPairList,
} from "./types";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8003";
const BASE = `${API_URL}/api/v1`;

async function fetchWithAuth(
  url: string,
  options: RequestInit = {}
): Promise<Response> {
  const token = getToken();
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const response = await fetch(`${BASE}${url}`, {
    ...options,
    headers,
  });

  if (response.status === 401) {
    removeToken();
    if (typeof window !== "undefined") {
      window.location.href = "/login";
    }
  }

  return response;
}

export const adminApi = {
  async login(
    email: string,
    password: string
  ): Promise<AdminLoginResponse> {
    const response = await fetch(`${BASE}/admin/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      throw new Error(error.detail || "로그인에 실패했습니다");
    }

    return response.json();
  },

  async getDashboard(): Promise<DashboardData> {
    const response = await fetchWithAuth("/admin/dashboard");
    if (!response.ok) throw new Error("대시보드 데이터를 불러올 수 없습니다");
    return response.json();
  },

  async getUsers(query?: string): Promise<AdminUser[]> {
    const params = query ? `?q=${encodeURIComponent(query)}` : "";
    const response = await fetchWithAuth(`/admin/users${params}`);
    if (!response.ok) throw new Error("사용자 목록을 불러올 수 없습니다");
    const data = await response.json();
    return data.users;
  },

  async getGuardianPairs(query?: string): Promise<GuardianPairList> {
    const params = query ? `?q=${encodeURIComponent(query)}` : "";
    const response = await fetchWithAuth(`/admin/users/pairs${params}`);
    if (!response.ok) throw new Error("보호자 쌍 목록을 불러올 수 없습니다");
    return response.json();
  },

  async updateUserRole(
    userId: string,
    role: string
  ): Promise<{ message: string }> {
    const response = await fetchWithAuth(`/admin/users/${userId}/role`, {
      method: "PUT",
      body: JSON.stringify({ role }),
    });
    if (!response.ok) throw new Error("역할 변경에 실패했습니다");
    return response.json();
  },

  async getContentSummary(): Promise<ContentSummary> {
    const response = await fetchWithAuth("/admin/content");
    if (!response.ok)
      throw new Error("콘텐츠 요약을 불러올 수 없습니다");
    return response.json();
  },

  async getRecentContent(): Promise<ContentItem[]> {
    const response = await fetchWithAuth("/admin/content/recent");
    if (!response.ok)
      throw new Error("최근 콘텐츠를 불러올 수 없습니다");
    return response.json();
  },

  // 종 관리
  async getSpecies(query?: string, category?: string): Promise<SpeciesItem[]> {
    const params = new URLSearchParams();
    if (query) params.set("q", query);
    if (category) params.set("category", category);
    const qs = params.toString();
    const response = await fetchWithAuth(`/admin/species${qs ? `?${qs}` : ""}`);
    if (!response.ok) throw new Error("종 목록을 불러올 수 없습니다");
    const data = await response.json();
    return data.species;
  },

  async createSpecies(species: SpeciesCreateRequest): Promise<SpeciesItem> {
    const response = await fetchWithAuth("/admin/species", {
      method: "POST",
      body: JSON.stringify(species),
    });
    if (!response.ok) throw new Error("종 추가에 실패했습니다");
    return response.json();
  },

  async updateSpecies(id: string, species: SpeciesCreateRequest): Promise<SpeciesItem> {
    const response = await fetchWithAuth(`/admin/species/${id}`, {
      method: "PUT",
      body: JSON.stringify(species),
    });
    if (!response.ok) throw new Error("종 수정에 실패했습니다");
    return response.json();
  },

  async deleteSpecies(id: string): Promise<void> {
    const response = await fetchWithAuth(`/admin/species/${id}`, { method: "DELETE" });
    if (!response.ok) throw new Error("종 삭제에 실패했습니다");
  },

  async getSpeciesDetail(speciesId: string): Promise<SpeciesDetail> {
    const response = await fetchWithAuth(`/admin/species/${speciesId}/owners`);
    if (!response.ok) throw new Error("종 상세 정보를 불러올 수 없습니다");
    return response.json();
  },

  // 카드 관리
  async getCards(query?: string): Promise<CardItem[]> {
    const params = query ? `?q=${encodeURIComponent(query)}` : "";
    const response = await fetchWithAuth(`/admin/cards${params}`);
    if (!response.ok) throw new Error("카드 목록을 불러올 수 없습니다");
    const data = await response.json();
    return data.cards;
  },

  async getCardStats(): Promise<CardStats> {
    const response = await fetchWithAuth("/admin/cards/stats");
    if (!response.ok) throw new Error("카드 통계를 불러올 수 없습니다");
    return response.json();
  },
};
