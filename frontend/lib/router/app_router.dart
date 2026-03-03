import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/collection_detail_screen.dart';
import '../screens/identify/identify_screen.dart';
import '../screens/diary/diary_screen.dart';
import '../screens/friends/friends_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/common/nature_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorIdentifyKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellIdentify');
final _shellNavigatorDiaryKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellDiary');
final _shellNavigatorFriendsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellFriends');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

class AppRouter {
  AppRouter({required this.authBloc});

  final AuthBloc authBloc;

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: _AuthChangeNotifier(authBloc),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 도감
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'collection/:id',
                    name: 'collectionDetail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => CollectionDetailScreen(
                      collectionId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 발견
          StatefulShellBranch(
            navigatorKey: _shellNavigatorIdentifyKey,
            routes: [
              GoRoute(
                path: '/identify',
                name: 'identify',
                builder: (context, state) => const IdentifyScreen(),
              ),
            ],
          ),
          // 일기
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDiaryKey,
            routes: [
              GoRoute(
                path: '/diary',
                name: 'diary',
                builder: (context, state) => const DiaryScreen(),
              ),
            ],
          ),
          // 친구
          StatefulShellBranch(
            navigatorKey: _shellNavigatorFriendsKey,
            routes: [
              GoRoute(
                path: '/friends',
                name: 'friends',
                builder: (context, state) => const FriendsScreen(),
              ),
            ],
          ),
          // 나
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    final isLoggedIn = authState is Authenticated;
    final isOnLogin = state.matchedLocation == '/login';

    if (isLoggedIn && isOnLogin) return '/home';
    if (!isLoggedIn && !isOnLogin) return '/login';
    return null;
  }
}

/// GoRouter의 refreshListenable에서 사용하는 AuthBloc 어댑터
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    // ignore: avoid_dynamic_calls
    _subscription.cancel();
    super.dispose();
  }
}

/// 5탭 하단 네비게이션을 포함하는 쉘 스캐폴드
class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NatureBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
