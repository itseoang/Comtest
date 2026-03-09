export interface AdminLoginRequest {
  email: string;
  password: string;
}

export interface AdminLoginResponse {
  access_token: string;
  admin_name: string;
  role: string;
}

export interface AdminStats {
  totalUsers: number;
  activeToday: number;
  totalCollections: number;
  totalDiaries: number;
  totalQuizzes: number;
  totalChallenges: number;
  newUsersThisWeek: number;
  completionRate: number;
}

export interface AdminUser {
  id: string;
  nickname: string;
  email: string;
  role: string;
  joinedAt: string;
  lastActive: string;
  collections: number;
}

export interface ContentItem {
  id: string;
  type: string;
  title: string;
  author: string;
  createdAt: string;
  status: string;
}

export interface ContentSummary {
  discoveries: number;
  diaries: number;
  quizzes: number;
  challenges: number;
}

export interface DashboardData {
  stats: AdminStats;
  recent_content: ContentItem[];
}

// 종 관리
export interface SpeciesItem {
  id: string;
  name: string;
  scientific_name: string;
  category: string;
  description: string;
  habitat: string;
  rarity: string;
  image_url: string;
  created_at: string;
}

export interface SpeciesCreateRequest {
  name: string;
  scientific_name: string;
  category: string;
  description?: string;
  habitat?: string;
  rarity?: string;
}

// 카드 관리
export interface CardItem {
  id: string;
  species_name: string;
  collector_nickname: string;
  discovered_at: string;
  location: string;
  rarity_score: number;
  hp: number;
  attack: number;
  defense: number;
  speed: number;
  charm: number;
  image_url: string;
}

export interface CardStats {
  total_cards: number;
  cards_today: number;
  most_collected_species: string;
  rarest_card_owner: string;
  category_breakdown: Record<string, number>;
}

// 종 상세 - 카드 소유자 순위
export interface SpeciesCardOwner {
  rank: number;
  user_id: string;
  nickname: string;
  email: string;
  cards_count: number;
  best_rarity_score: number;
  first_discovered: string;
  total_power: number;
}

export interface SpeciesDetail {
  species: SpeciesItem;
  total_cards: number;
  unique_owners: number;
  owners: SpeciesCardOwner[];
}

// 보호자-사용자 쌍
export interface GuardianPair {
  guardian: AdminUser;
  children: AdminUser[];
}

export interface GuardianPairList {
  pairs: GuardianPair[];
  unlinked_users: AdminUser[];
  total_pairs: number;
  total_unlinked: number;
}
