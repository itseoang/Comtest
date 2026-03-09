import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/ranch_decoration.dart';

class RanchSaveData {
  const RanchSaveData({
    required this.placedDecorations,
    required this.ownedItemIds,
    required this.activeThemeId,
  });

  final List<PlacedDecoration> placedDecorations;
  final Set<String> ownedItemIds;
  final String activeThemeId;

  factory RanchSaveData.fromJson(Map<String, dynamic> json) {
    return RanchSaveData(
      placedDecorations: (json['placedDecorations'] as List<dynamic>?)
              ?.map((e) =>
                  PlacedDecoration.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ownedItemIds:
          (json['ownedItemIds'] as List<dynamic>?)?.cast<String>().toSet() ??
              {},
      activeThemeId: json['activeThemeId'] as String? ?? 'theme_summer',
    );
  }

  Map<String, dynamic> toJson() => {
        'placedDecorations': placedDecorations.map((d) => d.toJson()).toList(),
        'ownedItemIds': ownedItemIds.toList(),
        'activeThemeId': activeThemeId,
      };
}

class RanchStorageService {
  static const String _fileName = 'ranch_data.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<RanchSaveData?> load() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return null;
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return RanchSaveData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save({
    required List<PlacedDecoration> decorations,
    required Set<String> ownedItemIds,
    required String activeThemeId,
  }) async {
    final data = RanchSaveData(
      placedDecorations: decorations,
      ownedItemIds: ownedItemIds,
      activeThemeId: activeThemeId,
    );
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data.toJson()));
  }
}
