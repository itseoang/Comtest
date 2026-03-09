"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { LayoutDashboard, Users, FileText, Leaf, CreditCard, LogOut } from "lucide-react";
import { removeToken } from "@/lib/auth";

const menuItems = [
  { href: "/", label: "대시보드", icon: LayoutDashboard },
  { href: "/users", label: "사용자 관리", icon: Users },
  { href: "/content", label: "콘텐츠 관리", icon: FileText },
  { href: "/species", label: "종 관리", icon: Leaf },
  { href: "/cards", label: "카드 관리", icon: CreditCard },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  const handleLogout = () => {
    removeToken();
    router.push("/login");
  };

  return (
    <aside className="fixed left-0 top-0 h-full w-64 bg-white border-r border-gray-200 flex flex-col">
      <div className="p-6 border-b border-gray-200">
        <h1 className="text-lg font-bold text-nature-green">자연도감 관리자</h1>
      </div>

      <nav className="flex-1 p-4 space-y-1">
        {menuItems.map((item) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium transition-colors ${
                isActive
                  ? "bg-nature-green text-white"
                  : "text-nature-brown hover:bg-gray-100"
              }`}
            >
              <Icon size={20} />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t border-gray-200">
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-nature-brown hover:bg-gray-100 w-full transition-colors"
        >
          <LogOut size={20} />
          로그아웃
        </button>
      </div>
    </aside>
  );
}
