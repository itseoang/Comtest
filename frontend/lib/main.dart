import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'blocs/auth/auth_bloc.dart';
import 'blocs/challenge/challenge_bloc.dart';
import 'blocs/child_management/child_management_bloc.dart';
import 'blocs/collection/collection_bloc.dart';
import 'blocs/friend/friend_bloc.dart';
import 'blocs/gift/gift_bloc.dart';
import 'blocs/pet/pet_bloc.dart';
import 'blocs/achievement/achievement_bloc.dart';
import 'blocs/quiz/quiz_bloc.dart';
import 'config/constants.dart';
import 'config/env_config.dart';
import 'config/theme.dart';
import 'models/profile.dart';
import 'router/app_router.dart';
import 'services/ad_service.dart';
import 'widgets/common/badge_celebration_dialog.dart';
import 'services/api/dio_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: '.env');

  // 네이버 지도 SDK 초기화 (웹에서는 스킵)
  if (!kIsWeb) {
    await FlutterNaverMap().init(
      clientId: EnvConfig.naverMapClientId,
    );
  }

  // devMode가 아닐 때만 Supabase 초기화
  // (플레이스홀더 URL로 초기화하면 크래시 발생할 수 있음)
  if (!AppConstants.devMode) {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  runApp(const NatureApp());
}

class NatureApp extends StatefulWidget {
  const NatureApp({super.key});

  @override
  State<NatureApp> createState() => _NatureAppState();
}

class _NatureAppState extends State<NatureApp> {
  late final AuthBloc _authBloc;
  late final ChallengeBloc _challengeBloc;
  late final ChildManagementBloc _childManagementBloc;
  late final CollectionBloc _collectionBloc;
  late final FriendBloc _friendBloc;
  late final GiftBloc _giftBloc;
  late final QuizBloc _quizBloc;
  late final PetBloc _petBloc;
  late final AchievementBloc _achievementBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(dioClient: DioClient());
    _challengeBloc = ChallengeBloc();
    _childManagementBloc = ChildManagementBloc();
    _collectionBloc = CollectionBloc();
    _friendBloc = FriendBloc()..add(const LoadFriends());
    _giftBloc = GiftBloc();
    _quizBloc = QuizBloc();
    _petBloc = PetBloc();
    _achievementBloc = AchievementBloc();
    _appRouter = AppRouter(authBloc: _authBloc);

    // 앱 시작 시 인증 상태 확인
    _authBloc.add(const AuthCheckRequested());
    _challengeBloc.add(const LoadChallenge());

    // 광고 SDK 초기화
    AdService.instance.initialize();
  }

  @override
  void dispose() {
    _authBloc.close();
    _challengeBloc.close();
    _childManagementBloc.close();
    _collectionBloc.close();
    _friendBloc.close();
    _giftBloc.close();
    _quizBloc.close();
    _petBloc.close();
    _achievementBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _challengeBloc),
        BlocProvider.value(value: _childManagementBloc),
        BlocProvider.value(value: _collectionBloc),
        BlocProvider.value(value: _friendBloc),
        BlocProvider.value(value: _giftBloc),
        BlocProvider.value(value: _quizBloc),
        BlocProvider.value(value: _petBloc),
        BlocProvider.value(value: _achievementBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          // AuthBloc → Authenticated 되면 RecordLogin + InitAchievements
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) =>
                prev is! Authenticated && curr is Authenticated,
            listener: (context, state) {
              if (state is Authenticated) {
                _authBloc.add(const RecordLogin());
                _achievementBloc.add(InitAchievements(
                  earnedBadgeIds: state.profile.earnedBadgeIds,
                ));
                // 초기 뱃지 체크
                _dispatchBadgeCheck(state.profile);
              }
            },
          ),
          // AuthBloc → 프로필 변경 시 뱃지 체크
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) =>
                prev is Authenticated && curr is Authenticated,
            listener: (context, state) {
              if (state is Authenticated) {
                _dispatchBadgeCheck(state.profile);
              }
            },
          ),
          // CollectionBloc → 아이템 변경 시 뱃지 체크
          BlocListener<CollectionBloc, CollectionState>(
            listener: (context, state) {
              final authState = _authBloc.state;
              if (authState is Authenticated) {
                _dispatchBadgeCheck(authState.profile);
              }
            },
          ),
          // AchievementBloc → 새 뱃지 획득 시 축하 팝업
          BlocListener<AchievementBloc, AchievementState>(
            listenWhen: (prev, curr) =>
                curr is AchievementLoaded && curr.newlyEarnedBadge != null,
            listener: (context, state) {
              if (state is AchievementLoaded && state.newlyEarnedBadge != null) {
                // 뱃지 ID 목록 갱신
                _authBloc.add(UpdateEarnedBadges(
                  badgeIds: state.earnedBadgeIds,
                ));
                // 축하 팝업
                final nav = _appRouter.router.routerDelegate.navigatorKey;
                final ctx = nav.currentContext;
                if (ctx != null) {
                  BadgeCelebrationDialog.show(ctx, state.newlyEarnedBadge!);
                }
              }
            },
          ),
        ],
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: AppConstants.devMode,
          theme: NatureTheme.lightTheme,
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }

  void _dispatchBadgeCheck(Profile profile) {
    final collectionCount = _collectionBloc.state is CollectionLoaded
        ? (_collectionBloc.state as CollectionLoaded).items.length
        : 0;
    final quizCount = _quizBloc.history.results.length;

    _achievementBloc.add(CheckBadgeProgress(
      stats: {
        'loginCount': profile.loginCount,
        'loginStreak': profile.loginStreak,
        'quizCount': quizCount,
        'collectionCount': collectionCount,
        'ecoPoints': profile.ecoPoints,
      },
    ));
  }
}
