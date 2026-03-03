import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/collection/collection_bloc.dart';
import 'config/constants.dart';
import 'config/theme.dart';
import 'router/app_router.dart';
import 'services/api/dio_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  late final CollectionBloc _collectionBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(dioClient: DioClient());
    _collectionBloc = CollectionBloc();
    _appRouter = AppRouter(authBloc: _authBloc);

    // 앱 시작 시 인증 상태 확인
    _authBloc.add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    _collectionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _collectionBloc),
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
