import 'env_config.dart';

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
  /// devMode면 placeholder, 아니면 env에서 읽음
  static String get supabaseUrl =>
      devMode ? 'https://placeholder.supabase.co' : EnvConfig.supabaseUrl;
  static String get supabaseAnonKey =>
      devMode ? 'placeholder-anon-key' : EnvConfig.supabaseAnonKey;

  // -------------------------
  // API
  // -------------------------
  static String get apiBaseUrl => EnvConfig.apiBaseUrl;
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

  // -------------------------
  // Quiz
  // -------------------------
  static const double quizIdentifyProbability = 0.30;
  static const double quizDashboardProbability = 0.15;
  static const double quizDiaryProbability = 0.20;
  static const int quizDashboardCooldownHours = 4;
  static const int quizDashboardMaxPerDay = 5;
  static const int quizCorrectPoints = 10;
  static const int quizWrongPoints = 2;
  static const int emotionCheckPoints = 5;
  static const int streak3Bonus = 5;
  static const int streak5Bonus = 10;
  static const int streak10Bonus = 20;
  static const int retryCorrectBonus = 3;
}

class PetConstants {
  PetConstants._();

  // 쿨타임 (분)
  static const int careCooldownMinutes = 30;

  // 돌봄 시 게이지 회복량
  static const int careGaugeRestore = 25;

  // 돌봄 경험치
  static const int careExp = 10;

  // 외부 활동 경험치
  static const int quizCorrectPetExp = 5;
  static const int diaryWritePetExp = 8;
  static const int collectionPetExp = 15;

  // 게이지 감소율 (분당)
  static const double gaugeDecayPerMinute = 0.1;

  // 추가 돌봄 경험치
  static const int walkExp = 12;
  static const int bathExp = 8;
  static const int lullabyExp = 6;

  // 추가 돌봄 행복 회복량
  static const int walkHappinessRestore = 20;
  static const int bathHappinessRestore = 15;
  static const int lullabyHappinessRestore = 30;

  // 미니게임
  static const int miniGameTapExp = 3;
  static const int miniGameMaxTapsPerSession = 20;

  // 활동 로그
  static const int maxActivityLogSize = 50;

  // 레벨별 필요 경험치
  static int expForLevel(int level) {
    if (level <= 5) return 50;
    if (level <= 10) return 80;
    if (level <= 15) return 120;
    return 160;
  }
}

class ChallengeConstants {
  ChallengeConstants._();

  static const int completionRewardPoints = 50;
  static const int completionRewardPetExp = 30;
  static const int taskCompletionPoints = 10;
}
