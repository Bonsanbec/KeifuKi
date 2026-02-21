import '../domain/response.dart';

class ResponseGrowthService {
  const ResponseGrowthService._();

  static ResponseGrowthMetadata buildMetadata({
    required String questionId,
    String? questionCategory,
    required String mediaType,
    int? durationSeconds,
    int? textLength,
  }) {
    final category = (questionCategory ?? '').toLowerCase();

    final depthByCategory = <String, int>{
      'system': 3,
      'childhood': 4,
      'family': 4,
      'relationships': 4,
      'values': 5,
      'legacy': 5,
      'life': 4,
      'meta': 4,
      'present': 2,
      'work': 3,
      'education': 3,
    };

    final depth = depthByCategory[category] ?? 3;

    final emotionalWeight = _emotionalWeight(
      mediaType: mediaType,
      durationSeconds: durationSeconds,
      textLength: textLength,
    );

    final novelty = _noveltyFromQuestion(questionId, category);
    final structuralShift = category == 'system' || depth >= 5 || novelty >= 4;

    final tags = <String>{
      if (category.isNotEmpty) category,
      mediaType,
      if (structuralShift) 'shift',
    }.toList(growable: false);

    return ResponseGrowthMetadata(
      depth: depth,
      emotionalWeight: emotionalWeight,
      novelty: novelty,
      structuralShift: structuralShift,
      tags: tags,
    );
  }

  static int _emotionalWeight({
    required String mediaType,
    int? durationSeconds,
    int? textLength,
  }) {
    final baseByMedia = <String, int>{
      'text': 2,
      'audio': 3,
      'image': 3,
      'video': 4,
    };

    int value = baseByMedia[mediaType] ?? 2;

    if ((durationSeconds ?? 0) >= 120) {
      value += 1;
    }

    if ((textLength ?? 0) >= 220) {
      value += 1;
    }

    return value.clamp(1, 5);
  }

  static int _noveltyFromQuestion(String questionId, String category) {
    final hash = _stableHash('$questionId|$category');
    return (hash % 4) + 1;
  }

  static int _stableHash(String input) {
    int hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }
}
