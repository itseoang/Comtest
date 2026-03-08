import 'dart:io';
import 'package:native_exif/native_exif.dart';
import 'package:geolocator/geolocator.dart';

class ImageValidationResult {
  const ImageValidationResult({
    required this.hasExifCamera,
    this.cameraMake,
    this.cameraModel,
    this.originalDate,
    this.currentPosition,
  });

  final bool hasExifCamera;
  final String? cameraMake;
  final String? cameraModel;
  final DateTime? originalDate;
  final Position? currentPosition;

  bool get isLikelyDirectPhoto => hasExifCamera;
}

class ImageValidator {
  /// EXIF 카메라 정보 확인
  static Future<ImageValidationResult> validate(File imageFile) async {
    String? cameraMake;
    String? cameraModel;
    DateTime? originalDate;
    bool hasExifCamera = false;

    try {
      final exif = await Exif.fromPath(imageFile.path);
      final attributes = await exif.getAttributes();

      if (attributes != null) {
        final makeVal = attributes['Make'];
        final modelVal = attributes['Model'];
        cameraMake = makeVal is String ? makeVal : null;
        cameraModel = modelVal is String ? modelVal : null;

        final dateVal =
            attributes['DateTimeOriginal'] ?? attributes['DateTime'];
        final dateStr = dateVal is String ? dateVal : null;
        if (dateStr != null && dateStr.isNotEmpty) {
          // EXIF date format: "2026:03:04 12:30:00"
          try {
            final parts = dateStr.split(' ');
            if (parts.length == 2) {
              final datePart = parts[0].replaceAll(':', '-');
              originalDate = DateTime.tryParse('$datePart ${parts[1]}');
            }
          } catch (_) {}
        }
      }

      hasExifCamera = (cameraMake != null && cameraMake.isNotEmpty) ||
          (cameraModel != null && cameraModel.isNotEmpty);

      await exif.close();
    } catch (_) {
      // EXIF 읽기 실패 = 카메라 정보 없음
      hasExifCamera = false;
    }

    // GPS 위치 기록
    Position? currentPosition;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
      } else if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.always ||
            requested == LocationPermission.whileInUse) {
          currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 5),
          );
        }
      }
    } catch (_) {
      // GPS 실패해도 진행 가능
    }

    return ImageValidationResult(
      hasExifCamera: hasExifCamera,
      cameraMake: cameraMake,
      cameraModel: cameraModel,
      originalDate: originalDate,
      currentPosition: currentPosition,
    );
  }
}
