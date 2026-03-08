import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  /// 네이버 지도 앱으로 장소 마커를 표시합니다.
  /// 좌표가 있으면 좌표로, 없으면 장소명 검색으로 열립니다.
  static Future<bool> openNaverMap({
    required String placeName,
    double? latitude,
    double? longitude,
  }) async {
    // 1. 좌표가 있으면 네이버 지도 앱으로 마커 표시
    if (latitude != null && longitude != null) {
      final nMapAppUri = Uri.parse(
        'nmap://place?lat=$latitude&lng=$longitude&name=${Uri.encodeComponent(placeName)}&appname=nature_collection',
      );

      if (await canLaunchUrl(nMapAppUri)) {
        return launchUrl(nMapAppUri);
      }

      // 앱 없으면 네이버 지도 웹으로 폴백
      final webUri = Uri.parse(
        'https://map.naver.com/v5/?c=$longitude,$latitude,15,0,0,0,dh',
      );
      return launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    // 2. 좌표 없으면 장소명으로 검색
    final searchAppUri = Uri.parse(
      'nmap://search?query=${Uri.encodeComponent(placeName)}&appname=nature_collection',
    );

    if (await canLaunchUrl(searchAppUri)) {
      return launchUrl(searchAppUri);
    }

    // 앱 없으면 웹 검색으로 폴백
    final webSearchUri = Uri.parse(
      'https://map.naver.com/v5/search/${Uri.encodeComponent(placeName)}',
    );
    return launchUrl(webSearchUri, mode: LaunchMode.externalApplication);
  }
}
