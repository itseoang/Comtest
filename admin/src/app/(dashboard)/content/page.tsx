"use client";

import { useEffect, useState } from "react";
import { Camera, BookOpen, Brain, Trophy } from "lucide-react";
import { adminApi } from "@/lib/api";
import type { ContentSummary, ContentItem } from "@/lib/types";
import ContentCard from "@/components/ContentCard";

export default function ContentPage() {
  const [summary, setSummary] = useState<ContentSummary | null>(null);
  const [recentContent, setRecentContent] = useState<ContentItem[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    Promise.all([adminApi.getContentSummary(), adminApi.getRecentContent()])
      .then(([s, c]) => {
        setSummary(s);
        setRecentContent(c);
      })
      .catch((err) => setError(err.message));
  }, []);

  if (error) {
    return (
      <div className="text-admin-red bg-red-50 p-4 rounded-lg">{error}</div>
    );
  }

  if (!summary) {
    return <p className="text-gray-400">로딩 중...</p>;
  }

  const typeLabels: Record<string, string> = {
    discovery: "발견",
    diary: "일기",
    quiz: "퀴즈",
    challenge: "챌린지",
  };

  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-bold text-nature-brown">콘텐츠 관리</h1>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <ContentCard title="발견" count={summary.discoveries} icon={Camera} color="bg-amber-500" />
        <ContentCard title="일기" count={summary.diaries} icon={BookOpen} color="bg-purple-500" />
        <ContentCard title="퀴즈" count={summary.quizzes} icon={Brain} color="bg-indigo-500" />
        <ContentCard title="챌린지" count={summary.challenges} icon={Trophy} color="bg-orange-500" />
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-5 border-b border-gray-100">
          <h2 className="text-lg font-semibold text-nature-brown">최근 콘텐츠</h2>
        </div>
        <table className="w-full">
          <thead>
            <tr className="border-b border-gray-100 bg-gray-50/50">
              <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">유형</th>
              <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">제목</th>
              <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">작성자</th>
              <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">상태</th>
              <th className="text-left px-5 py-3 text-xs font-medium text-gray-500 uppercase">날짜</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {recentContent.map((item) => (
              <tr key={item.id} className="hover:bg-gray-50/50 transition-colors">
                <td className="px-5 py-3">
                  <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                    {typeLabels[item.type] || item.type}
                  </span>
                </td>
                <td className="px-5 py-3 text-sm font-medium text-nature-brown">{item.title}</td>
                <td className="px-5 py-3 text-sm text-gray-500">{item.author}</td>
                <td className="px-5 py-3">
                  <span className={`text-xs px-2 py-1 rounded ${
                    item.status === "published"
                      ? "bg-green-100 text-green-700"
                      : "bg-yellow-100 text-yellow-700"
                  }`}>
                    {item.status === "published" ? "게시됨" : "대기"}
                  </span>
                </td>
                <td className="px-5 py-3 text-sm text-gray-500">
                  {new Date(item.createdAt).toLocaleDateString("ko-KR")}
                </td>
              </tr>
            ))}
            {recentContent.length === 0 && (
              <tr>
                <td colSpan={5} className="px-5 py-8 text-center text-gray-400 text-sm">
                  콘텐츠가 없습니다
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
