import 'package:dio/dio.dart';

import '../../config/constants.dart';

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // devMode일 때 플레이스홀더 토큰 사용
          if (AppConstants.devMode)
            'Authorization': 'Bearer dev-token-test',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // devMode가 아닐 때 실제 토큰 주입 (추후 구현)
          if (!AppConstants.devMode) {
            // TODO: SharedPreferences 등에서 토큰 읽어서 설정
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;

  /// Authorization 헤더 갱신 (실제 로그인 후 호출)
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Authorization 헤더 제거 (로그아웃 시 호출)
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
