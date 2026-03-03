class AppConstants {
  AppConstants._();

  // -------------------------
  // Dev Mode
  // -------------------------
  /// true이면 Supabase 초기화를 skip하고 mock 데이터로 로그인함
  static const bool devMode = true;

  // -------------------------
  // Supabase
  // -------------------------
  static const String supabaseUrl = 'https://placeholder.supabase.co';
  static const String supabaseAnonKey = 'placeholder-anon-key';

  // -------------------------
  // API
  // -------------------------
  static const String apiBaseUrl = 'http://localhost:8003';
  static const Duration apiTimeout = Duration(seconds: 30);

  // -------------------------
  // App
  // -------------------------
  static const String appName = '자연도감';
  static const String appVersion = '0.1.0';

  // Pet types
  static const Map<String, Map<String, String>> petTypes = {
    'plant': {'name': '새싹이', 'emoji': '🌱', 'color': '#4CAF50'},
    'water': {'name': '물방울이', 'emoji': '💧', 'color': '#2196F3'},
    'rock': {'name': '돌멩이', 'emoji': '🪨', 'color': '#795548'},
    'electric': {'name': '번개', 'emoji': '⚡', 'color': '#FFC107'},
    'wind': {'name': '바람이', 'emoji': '🌬️', 'color': '#00BCD4'},
  };
}
