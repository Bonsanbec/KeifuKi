import 'dart:convert';

class StructuralMarker {
  final String id;
  final DateTime createdAt;
  final String reason;
  final int intensity;

  const StructuralMarker({
    required this.id,
    required this.createdAt,
    required this.reason,
    this.intensity = 1,
  }) : assert(intensity >= 1);

  Map<String, Object?> toMap() => {
    'id': id,
    'created_at': createdAt.millisecondsSinceEpoch,
    'reason': reason,
    'intensity': intensity,
  };

  static StructuralMarker fromMap(Map<String, Object?> map) {
    return StructuralMarker(
      id: map['id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      reason: map['reason'] as String,
      intensity: (map['intensity'] as int?) ?? 1,
    );
  }
}

class TreeState {
  final DateTime? plantedAt;
  final String? identityName;
  final int growthSeed;
  final List<StructuralMarker> structuralMarkers;
  final DateTime? lastWateredAt;

  const TreeState({
    required this.plantedAt,
    required this.identityName,
    required this.growthSeed,
    required this.structuralMarkers,
    required this.lastWateredAt,
  });

  bool get hasIdentity => (identityName ?? '').trim().isNotEmpty;

  TreeState copyWith({
    DateTime? plantedAt,
    String? identityName,
    int? growthSeed,
    List<StructuralMarker>? structuralMarkers,
    DateTime? lastWateredAt,
    bool clearPlantedAt = false,
    bool clearIdentityName = false,
    bool clearLastWateredAt = false,
  }) {
    return TreeState(
      plantedAt: clearPlantedAt ? null : (plantedAt ?? this.plantedAt),
      identityName: clearIdentityName
          ? null
          : (identityName ?? this.identityName),
      growthSeed: growthSeed ?? this.growthSeed,
      structuralMarkers: structuralMarkers ?? this.structuralMarkers,
      lastWateredAt: clearLastWateredAt
          ? null
          : (lastWateredAt ?? this.lastWateredAt),
    );
  }

  static String encodeMarkers(List<StructuralMarker> markers) {
    return jsonEncode(markers.map((m) => m.toMap()).toList(growable: false));
  }

  static List<StructuralMarker> decodeMarkers(String? raw) {
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map((e) => e.cast<String, Object?>())
        .map(StructuralMarker.fromMap)
        .toList(growable: false);
  }
}
