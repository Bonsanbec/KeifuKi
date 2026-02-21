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
  final int height;
  final int branchCount;
  final double density;
  final double vitality;
  final List<TreeFruit> availableFruits;
  final DateTime? lastWateredAt;

  const TreeProjection({
    required this.isPlanted,
    required this.identityName,
    required this.height,
    required this.branchCount,
    required this.density,
    required this.vitality,
    required this.availableFruits,
    required this.lastWateredAt,
  });

  String get vitalityLabel {
    if (vitality >= 0.8) return 'Vigoroso';
    if (vitality >= 0.55) return 'Estable';
    if (vitality >= 0.3) return 'Reposo';
    return 'Latente';
  }
}
