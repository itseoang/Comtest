"use client";

import { useEffect, useState } from "react";
import { Users, Activity, Camera, BookOpen, Brain, Trophy, UserPlus, TrendingUp } from "lucide-react";
import { adminApi } from "@/lib/api";
import type { DashboardData } from "@/lib/types";
import StatCard from "@/components/StatCard";
import RecentActivity from "@/components/RecentActivity";

export default function DashboardPage() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    adminApi
      .getDashboard()
      .then(setData)
      .catch((err) => setError(err.message));
  }, []);

  if (error) {
    return (
      <div className="text-admin-red bg-red-50 p-4 rounded-lg">{error}</div>
    );
  }

  if (!data) {
    return <p className="text-gray-400">로딩 중...</p>;
  }

  const stats = data.stats;

  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-bold text-nature-brown">대시보드</h1>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <StatCard title="전체 사용자" value={stats.totalUsers} icon={Users} />
        <StatCard title="오늘 활동" value={stats.activeToday} icon={Activity} color="text-blue-500" />
        <StatCard title="총 수집" value={stats.totalCollections} icon={Camera} color="text-amber-500" />
        <StatCard title="총 일기" value={stats.totalDiaries} icon={BookOpen} color="text-purple-500" />
        <StatCard title="총 퀴즈" value={stats.totalQuizzes} icon={Brain} color="text-indigo-500" />
        <StatCard title="총 챌린지" value={stats.totalChallenges} icon={Trophy} color="text-orange-500" />
        <StatCard title="이번 주 신규" value={stats.newUsersThisWeek} icon={UserPlus} color="text-teal-500" />
        <StatCard title="완료율" value={`${stats.completionRate}%`} icon={TrendingUp} color="text-emerald-500" />
      </div>

      <RecentActivity items={data.recent_content} />
    </div>
  );
}
