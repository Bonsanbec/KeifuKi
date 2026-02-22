import 'tree_state.dart';

class TreeFruit {
  final String responseId;
  final String questionId;
  final DateTime sourceCreatedAt;
  final DateTime surfacedAt;
  final int intensity;

  const TreeFruit({
    required this.responseId,
    required this.questionId,
    required this.sourceCreatedAt,
    required this.surfacedAt,
    required this.intensity,
  });
}

class TreeProjection {
  final bool isPlanted;
  final String? identityName;
  final double growthRatio;
  final double absorptionCapacity;
  final double effectiveGrowth;
  final double soilMoistureLevel;
  final double lastAbsorptionAtWatering;
  final double vitality;
  final List<StructuralMarker> structuralMarkers;
  final int growthSeed;
  final List<TreeFruit> availableFruits;
  final DateTime? plantedAt;
  final DateTime? lastWateredAt;

  const TreeProjection({
    required this.isPlanted,
    required this.identityName,
    required this.growthRatio,
    required this.absorptionCapacity,
    required this.effectiveGrowth,
    required this.soilMoistureLevel,
    required this.lastAbsorptionAtWatering,
    required this.vitality,
    required this.structuralMarkers,
    required this.growthSeed,
    required this.availableFruits,
    required this.plantedAt,
    required this.lastWateredAt,
  });

  String get vitalityLabel {
    if (vitality >= 0.8) return 'Vigoroso';
    if (vitality >= 0.55) return 'Estable';
    if (vitality >= 0.3) return 'Reposo';
    return 'Latente';
  }
}
