import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/challenge/challenge_bloc.dart';
import '../blocs/diary/diary_bloc.dart';
import '../blocs/pet/pet_bloc.dart';
import '../blocs/quiz/quiz_bloc.dart';
import '../config/constants.dart';
import '../models/challenge.dart';
import '../models/diary.dart';
import '../models/quiz.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/challenge_detail_screen.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/collection_detail_screen.dart';
import '../screens/home/pet_detail_screen.dart';
import '../screens/identify/identify_screen.dart';
import '../screens/diary/diary_screen.dart';
import '../screens/diary/diary_detail_screen.dart';
import '../screens/friends/friends_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/gifticon_exchange_screen.dart';
import '../screens/guardian/guardian_monitor_screen.dart';
import '../widgets/common/nature_bottom_nav.dart';
import '../widgets/quiz/quiz_popup.dart';
import '../widgets/quiz/emotion_check_popup.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorIdentifyKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellIdentify');
final _shellNavigatorDiaryKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellDiary');
final _shellNavigatorFriendsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellFriends');
final _shellNavigatorMonitorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellMonitor');
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
          return _ScaffoldWithNavBar(
            navigationShell: navigationShell,
            authBloc: authBloc,
          );
        },
        branches: [
          // 0: 홈 대시보드
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'collection',
                    name: 'collection',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const HomeScreen(),
                  ),
                  GoRoute(
                    path: 'collection/:id',
                    name: 'collectionDetail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => CollectionDetailScreen(
                      collectionId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'challenge',
                    name: 'challenge',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const ChallengeDetailScreen(),
                  ),
                  GoRoute(
                    path: 'pet',
                    name: 'petDetail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const PetDetailScreen(),
                  ),
                ],
              ),
            ],
          ),
          // 1: 발견
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
          // 2: 일기
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDiaryKey,
            routes: [
              GoRoute(
                path: '/diary',
                name: 'diary',
                builder: (context, state) => const DiaryScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    name: 'diaryDetail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final entry = state.extra as DiaryEntry;
                      return BlocProvider(
                        create: (_) => DiaryBloc()..add(const LoadDiaries()),
                        child: DiaryDetailScreen(entry: entry),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // 3: 친구
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
          // 4: 모니터링 (보호자 전용)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMonitorKey,
            routes: [
              GoRoute(
                path: '/monitor',
                name: 'monitor',
                builder: (context, state) => const GuardianMonitorScreen(),
              ),
            ],
          ),
          // 5: 나
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'gifticon-exchange',
                    name: 'gifticonExchange',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const GifticonExchangeScreen(),
                  ),
                ],
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

    // 보호자가 아닌 사용자가 /monitor 접근 시 /home으로 리다이렉트
    final authenticatedState = authState is Authenticated ? authState : null;
    final isGuardian =
        authenticatedState != null && authenticatedState.profile.isGuardian;
    if (!isGuardian && state.matchedLocation == '/monitor') return '/home';

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

/// 하단 네비게이션을 포함하는 쉘 스캐폴드
/// branches는 6개 고정(도감0/발견1/일기2/친구3/모니터링4/나5)이지만,
/// 일반 사용자는 모니터링(4) 탭을 건너뛰어 5탭으로 표시함.
class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final AuthBloc authBloc;

  const _ScaffoldWithNavBar({
    required this.navigationShell,
    required this.authBloc,
  });

  /// navIndex → shellBranch index 변환
  /// 일반 사용자: 탭 4(나) → branch 5(나), 모니터링(4) 건너뜀
  int _navToShell(int navIndex, bool isGuardian) {
    if (isGuardian) return navIndex;
    // 일반 사용자: navIndex 0~3 → branch 0~3, navIndex 4(나) → branch 5
    return navIndex >= 4 ? navIndex + 1 : navIndex;
  }

  /// shellBranch index → navIndex 변환
  /// 일반 사용자: branch 5(나) → 탭 4
  int _shellToNav(int shellIndex, bool isGuardian) {
    if (isGuardian) return shellIndex;
    // 일반 사용자: branch 5(나) → 탭 4, 나머지 그대로
    return shellIndex >= 5 ? shellIndex - 1 : shellIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        debugPrint('[NavBar BlocListener] Quiz state: $state');
        if (state is QuizReady) {
          debugPrint('[NavBar BlocListener] Showing quiz bottom sheet');
          _showQuizBottomSheet(context, state);
        } else if (state is QuizAnswered) {
          context.read<AuthBloc>().add(
                AddEcoPoints(points: state.points, source: 'quiz'),
              );
          // 펫 경험치 연동
          context.read<PetBloc>().add(
                const AddPetExp(exp: PetConstants.quizCorrectPetExp, source: 'quiz'),
              );
          // Challenge progress: quiz correct
          if (state.points >= AppConstants.quizCorrectPoints) {
            context.read<ChallengeBloc>().add(
              const UpdateTaskProgress(type: ChallengeTaskType.quizCorrect),
            );
          }
        } else if (state is EmotionRecorded) {
          context.read<AuthBloc>().add(
                AddEcoPoints(points: state.points, source: 'emotion'),
              );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        bloc: authBloc,
        builder: (context, authState) {
          final isGuardian =
              authState is Authenticated && authState.profile.isGuardian;

          final currentNavIndex =
              _shellToNav(navigationShell.currentIndex, isGuardian);

          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NatureBottomNav(
              currentIndex: currentNavIndex,
              isGuardian: isGuardian,
              onTap: (navIndex) {
                final shellIndex = _navToShell(navIndex, isGuardian);
                navigationShell.goBranch(
                  shellIndex,
                  initialLocation: shellIndex == navigationShell.currentIndex,
                );
                // 홈 탭 재선택 시 퀴즈 트리거
                if (shellIndex == 0) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) {
                      context.read<QuizBloc>().add(const CheckQuizTrigger(trigger: 'dashboard'));
                    }
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  static void _showQuizBottomSheet(BuildContext context, QuizReady state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<QuizBloc>(),
        child: state.isEmotion
            ? EmotionCheckPopup(
                question: state.question as EmotionQuestion,
              )
            : QuizPopup(
                question: state.question as QuizQuestion,
              ),
      ),
    );
  }
}
