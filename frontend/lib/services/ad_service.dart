import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// Google 공식 테스트 광고 ID
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  bool get isAdReady => _isAdLoaded && _rewardedAd != null;

  /// SDK 초기화
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadRewardedAd();
  }

  /// 리워드 광고 로드
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _testRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          debugPrint('[AdService] Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          debugPrint('[AdService] Rewarded ad failed to load: $error');
          // 5초 후 재시도
          Future.delayed(const Duration(seconds: 5), loadRewardedAd);
        },
      ),
    );
  }

  /// 리워드 광고 표시. 보상 콜백 실행 후 다음 광고 로드
  Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    if (!isAdReady) {
      debugPrint('[AdService] Ad not ready');
      return false;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        loadRewardedAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdService] User earned reward: ${reward.amount} ${reward.type}');
        onRewarded();
      },
    );

    return true;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
