import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get naverMapClientId =>
      dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '';

  static String get naverMapClientSecret =>
      dotenv.env['NAVER_MAP_CLIENT_SECRET'] ?? '';

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-anon-key';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8003';
}
