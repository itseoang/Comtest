import 'package:dio/dio.dart';
import '../config/env_config.dart';

class NaverMapApi {
  static final _dio = Dio(BaseOptions(
    baseUrl: 'https://naveropenapi.apigw.ntruss.com',
    headers: {
      'X-NCP-APIGW-API-KEY-ID': EnvConfig.naverMapClientId,
      'X-NCP-APIGW-API-KEY': EnvConfig.naverMapClientSecret,
    },
  ));

  /// 주소 → 좌표 (Geocoding)
  static Future<({double lat, double lng})?> geocode(String address) async {
    try {
      final response = await _dio.get(
        '/map-geocode/v2/geocode',
        queryParameters: {'query': address},
      );
      final addresses = response.data['addresses'] as List;
      if (addresses.isEmpty) return null;
      final first = addresses[0];
      return (
        lat: double.parse(first['y']),
        lng: double.parse(first['x']),
      );
    } catch (_) {
      return null;
    }
  }

  /// 좌표 → 주소 (Reverse Geocoding)
  static Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '/map-reversegeocode/v2/gc',
        queryParameters: {
          'coords': '$lng,$lat',
          'output': 'json',
          'orders': 'roadaddr,addr',
        },
      );
      final results = response.data['results'] as List;
      if (results.isEmpty) return null;
      final region = results[0]['region'];
      final area1 = region['area1']['name'] ?? '';
      final area2 = region['area2']['name'] ?? '';
      final area3 = region['area3']['name'] ?? '';
      return '$area1 $area2 $area3'.trim();
    } catch (_) {
      return null;
    }
  }

  /// 주변 장소 검색
  static Future<List<({String name, String category, double lat, double lng})>>
      searchNearby({
    required double lat,
    required double lng,
    required String query,
    int radius = 2000,
  }) async {
    try {
      final response = await _dio.get(
        '/map-place/v1/search',
        queryParameters: {
          'query': query,
          'coordinate': '$lng,$lat',
          'radius': radius,
        },
      );
      final places = response.data['places'] as List? ?? [];
      return places
          .map((p) => (
                name: p['name'] as String,
                category: p['category'] as String? ?? '',
                lat: double.parse(p['y']),
                lng: double.parse(p['x']),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
