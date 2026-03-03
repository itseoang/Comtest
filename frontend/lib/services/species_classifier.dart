import 'dart:io';
import 'dart:math';
import '../data/species_encyclopedia.dart';

class ClassificationResult {
  const ClassificationResult({
    required this.speciesName,
    required this.confidence,
    required this.category,
    this.info,
  });

  final String speciesName;
  final double confidence; // 0.0 ~ 1.0
  final String category;
  final SpeciesInfo? info;
}

/// Species classifier service.
/// Currently uses mock data. Replace with TFLite inference later:
///   1. Add tflite_flutter package
///   2. Load .tflite model in init()
///   3. Replace classifyImage() with real inference
class SpeciesClassifier {
  static final _random = Random();

  static final _mockSpecies = [
    ('진달래', 'plant'),
    ('청딱따구리', 'bird'),
    ('무당벌레', 'insect'),
    ('다람쥐', 'mammal'),
    ('도롱뇽', 'amphibian'),
    ('은행나무', 'plant'),
  ];

  /// Initialize classifier. Load TFLite model here later.
  Future<void> init() async {
    // TODO: Load TFLite model
    // _interpreter = await Interpreter.fromAsset('assets/models/species_model.tflite');
  }

  /// Classify an image file and return top results.
  Future<List<ClassificationResult>> classifyImage(File imageFile) async {
    // Simulate inference delay
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // TODO: Replace with real TFLite inference:
    // 1. Read image bytes
    // 2. Resize to model input size (e.g., 224x224)
    // 3. Normalize pixel values
    // 4. Run inference
    // 5. Map output indices to species names

    // Mock: return random species with realistic confidence scores
    final shuffled = List.of(_mockSpecies)..shuffle(_random);
    final topN = shuffled.take(3).toList();

    final confidences = [
      0.75 + _random.nextDouble() * 0.2, // 75~95%
      0.15 + _random.nextDouble() * 0.15, // 15~30%
      0.02 + _random.nextDouble() * 0.08, // 2~10%
    ];

    return List.generate(topN.length, (i) {
      final name = topN[i].$1;
      final category = topN[i].$2;
      return ClassificationResult(
        speciesName: name,
        confidence: confidences[i],
        category: category,
        info: SpeciesEncyclopedia.getInfo(name),
      );
    });
  }

  void dispose() {
    // TODO: Close TFLite interpreter
    // _interpreter?.close();
  }
}
