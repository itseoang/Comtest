import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/collection_detail_screen.dart';
import '../screens/home/home_screen.dart';

class AppRouter {
  AppRouter({required this.authBloc});

  final AuthBloc authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthChangeNotifier(authBloc),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/collection/:id',
        name: 'collectionDetail',
        builder: (context, state) => CollectionDetailScreen(
          collectionId: state.pathParameters['id']!,
        ),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    final isLoggedIn = authState is Authenticated;
    final isOnLogin = state.matchedLocation == '/login';

    if (isLoggedIn && isOnLogin) {
      // 로그인 완료 (devMode 포함) → 홈으로 이동
      return '/home';
    }

    if (!isLoggedIn && !isOnLogin) {
      // 미로그인 상태에서 보호된 페이지 접근 → 로그인으로
      return '/login';
    }

    return null; // 리다이렉트 불필요
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
