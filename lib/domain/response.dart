import 'dart:convert';

import '../services/app_data_runtime.dart';
import '../services/media_store.dart';

class ResponseGrowthMetadata {
  final int depth;
  final int emotionalWeight;
  final int novelty;
  final bool structuralShift;
  final List<String> tags;

  const ResponseGrowthMetadata({
    required this.depth,
    required this.emotionalWeight,
    required this.novelty,
    this.structuralShift = false,
    this.tags = const [],
  }) : assert(depth >= 0),
       assert(emotionalWeight >= 0),
       assert(novelty >= 0);

  Map<String, Object?> toMap() => {
    'depth': depth,
    'emotional_weight': emotionalWeight,
    'novelty': novelty,
    'structural_shift': structuralShift ? 1 : 0,
    'tags': tags,
  };

  String toJsonString() => jsonEncode(toMap());

  static ResponseGrowthMetadata? fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final map = decoded.cast<String, Object?>();

    final tagsRaw = map['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.whereType<String>().toList(growable: false)
        : const <String>[];

    return ResponseGrowthMetadata(
      depth: (map['depth'] as int?) ?? 0,
      emotionalWeight: (map['emotional_weight'] as int?) ?? 0,
      novelty: (map['novelty'] as int?) ?? 0,
      structuralShift: ((map['structural_shift'] as int?) ?? 0) == 1,
      tags: tags,
    );
  }
}

class ResponseEntry {
  final String id;
  final String questionId;
  final DateTime createdAt;
  final String mediaType;
  final int? durationSeconds;
  final String filePath;
  final ResponseGrowthMetadata? growthMetadata;
  final DateTime? lastReviewedAt;

  const ResponseEntry({
    required this.id,
    required this.questionId,
    required this.createdAt,
    required this.mediaType,
    this.durationSeconds,
    required this.filePath,
    this.growthMetadata,
    this.lastReviewedAt,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'question_id': questionId,
    'created_at': createdAt.millisecondsSinceEpoch,
    'media_type': mediaType,
    'duration_seconds': durationSeconds,
    'file_path': filePath,
    'growth_metadata_json': growthMetadata?.toJsonString(),
    'last_reviewed_at': lastReviewedAt?.millisecondsSinceEpoch,
  };

  static ResponseEntry fromMap(Map<String, Object?> map) {
    return ResponseEntry(
      id: map['id'] as String,
      questionId: map['question_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      mediaType: map['media_type'] as String,
      durationSeconds: map['duration_seconds'] as int?,
      filePath: MediaStore.resolveStoredPathForSource(
        storedPath: map['file_path'] as String,
        mediaRootPath: AppDataRuntime.requireCurrentSource().mediaRootPath,
      ),
      growthMetadata: ResponseGrowthMetadata.fromJsonString(
        map['growth_metadata_json'] as String?,
      ),
      lastReviewedAt: (map['last_reviewed_at'] as int?) != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_reviewed_at'] as int)
          : null,
    );
  }
}
