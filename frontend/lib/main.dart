import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/challenge/challenge_bloc.dart';
import 'blocs/collection/collection_bloc.dart';
import 'blocs/pet/pet_bloc.dart';
import 'blocs/quiz/quiz_bloc.dart';
import 'config/constants.dart';
import 'config/env_config.dart';
import 'config/theme.dart';
import 'router/app_router.dart';
import 'services/ad_service.dart';
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
  late final CollectionBloc _collectionBloc;
  late final QuizBloc _quizBloc;
  late final PetBloc _petBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(dioClient: DioClient());
    _challengeBloc = ChallengeBloc();
    _collectionBloc = CollectionBloc();
    _quizBloc = QuizBloc();
    _petBloc = PetBloc();
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
    _collectionBloc.close();
    _quizBloc.close();
    _petBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _challengeBloc),
        BlocProvider.value(value: _collectionBloc),
        BlocProvider.value(value: _quizBloc),
        BlocProvider.value(value: _petBloc),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: AppConstants.devMode,
        theme: NatureTheme.lightTheme,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
