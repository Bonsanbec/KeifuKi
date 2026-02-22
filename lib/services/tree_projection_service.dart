import 'dart:math' as math;

import '../domain/response.dart';
import '../domain/tree_projection.dart';
import '../domain/tree_state.dart';

class _AbsorptionOutcome {
  final double capacityNow;
  final double effectiveGrowth;
  final double lastAbsorptionAtWatering;

  const _AbsorptionOutcome({
    required this.capacityNow,
    required this.effectiveGrowth,
    required this.lastAbsorptionAtWatering,
  });
}

class TreeProjectionService {
  const TreeProjectionService._();

  static const double _absorptionRecoveryK = 0.14;
  static const double _consumptionFactor = 0.6;

  static TreeProjection project({
    required TreeState treeState,
    required List<ResponseEntry> responses,
    required Set<String> harvestedResponseIds,
    required int harvestedCount,
    required DateTime now,
  }) {
    final sortedResponses = [...responses]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final absorption = _simulateAbsorption(
      responses: sortedResponses,
      now: now,
      plantedAt: treeState.plantedAt,
    );

    final growthRatio = _computeGrowthRatio(
      now: now,
      plantedAt: treeState.plantedAt,
      effectiveGrowth: absorption.effectiveGrowth,
      structuralMarkers: treeState.structuralMarkers,
    );

    final vitality = _computeVitality(
      now: now,
      plantedAt: treeState.plantedAt,
      lastWateredAt: treeState.lastWateredAt,
      responses: sortedResponses,
    );

    final soilMoistureLevel = _computeSoilMoisture(
      absorptionCapacity: absorption.capacityNow,
      vitality: vitality,
    );

    final fruits = _selectFruits(
      responses: sortedResponses,
      seed: treeState.growthSeed,
      harvestedResponseIds: harvestedResponseIds,
      harvestedCount: harvestedCount,
      now: now,
    );

    return TreeProjection(
      isPlanted: treeState.plantedAt != null,
      identityName: treeState.identityName,
      growthRatio: growthRatio,
      absorptionCapacity: absorption.capacityNow,
      effectiveGrowth: absorption.effectiveGrowth,
      soilMoistureLevel: soilMoistureLevel,
      lastAbsorptionAtWatering: absorption.lastAbsorptionAtWatering,
      vitality: vitality,
      structuralMarkers: treeState.structuralMarkers,
      growthSeed: treeState.growthSeed,
      availableFruits: fruits,
      plantedAt: treeState.plantedAt,
      lastWateredAt: treeState.lastWateredAt,
    );
  }

  static _AbsorptionOutcome _simulateAbsorption({
    required List<ResponseEntry> responses,
    required DateTime now,
    required DateTime? plantedAt,
  }) {
    if (plantedAt == null) {
      return const _AbsorptionOutcome(
        capacityNow: 0.0,
        effectiveGrowth: 0.0,
        lastAbsorptionAtWatering: 1.0,
      );
    }

    if (responses.isEmpty) {
      final hoursSincePlanted =
          math.max(0, now.difference(plantedAt).inMinutes) / 60.0;
      final regenerated = _regenToFull(
        currentCapacity: 1.0,
        hoursElapsed: hoursSincePlanted,
      );

      return _AbsorptionOutcome(
        capacityNow: regenerated,
        effectiveGrowth: 0.0,
        lastAbsorptionAtWatering: regenerated,
      );
    }

    double currentCapacity = 1.0;
    double totalEffectiveGrowth = 0.0;
    double lastAbsorptionAtWatering = 1.0;
    DateTime anchor = plantedAt;

    for (final response in responses) {
      final elapsedHours =
          math.max(0, response.createdAt.difference(anchor).inMinutes) / 60.0;
      currentCapacity = _regenToFull(
        currentCapacity: currentCapacity,
        hoursElapsed: elapsedHours,
      );

      final basePulse = _responsePulse(response);
      final effective = basePulse * currentCapacity;
      totalEffectiveGrowth += effective;

      lastAbsorptionAtWatering = currentCapacity;

      final consumption = _consumptionFromPulse(basePulse);
      currentCapacity = (currentCapacity - consumption).clamp(0.0, 1.0);
      anchor = response.createdAt;
    }

    final hoursSinceLast = math.max(0, now.difference(anchor).inMinutes) / 60.0;
    currentCapacity = _regenToFull(
      currentCapacity: currentCapacity,
      hoursElapsed: hoursSinceLast,
    );

    return _AbsorptionOutcome(
      capacityNow: currentCapacity,
      effectiveGrowth: totalEffectiveGrowth,
      lastAbsorptionAtWatering: lastAbsorptionAtWatering,
    );
  }

  static double _regenToFull({
    required double currentCapacity,
    required double hoursElapsed,
  }) {
    if (hoursElapsed <= 0) return currentCapacity;

    final regen = 1 - math.exp(-_absorptionRecoveryK * hoursElapsed);
    return _clamp01(currentCapacity + ((1 - currentCapacity) * regen));
  }

  static double _responsePulse(ResponseEntry response) {
    final metadata = response.growthMetadata;
    final depth = (metadata?.depth ?? 1).toDouble();
    final emotional = (metadata?.emotionalWeight ?? 1).toDouble();
    final novelty = (metadata?.novelty ?? 1).toDouble();

    final raw = (depth * 0.42) + (emotional * 0.34) + (novelty * 0.24);
    return _clamp01(raw / 2.8);
  }

  static double _consumptionFromPulse(double basePulse) {
    return _clamp01((0.22 + (basePulse * _consumptionFactor * 0.9)));
  }

  static double _computeGrowthRatio({
    required DateTime now,
    required DateTime? plantedAt,
    required double effectiveGrowth,
    required List<StructuralMarker> structuralMarkers,
  }) {
    if (plantedAt == null) return 0.0;

    final elapsedDays = math.max(0, now.difference(plantedAt).inDays);
    final timeTerm = math.log(elapsedDays + 1) / math.log(365 + 1);

    final effectiveTerm = math.sqrt(
      math.log(effectiveGrowth + 1) / math.log(160 + 1),
    );

    double markerTerm = 0;
    for (final marker in structuralMarkers) {
      markerTerm += marker.intensity * 0.016;
    }

    final baseGrowth = (timeTerm * 0.52) + (effectiveTerm * 0.48);
    final ratio = math.sqrt(_clamp01(baseGrowth + markerTerm));

    return _clamp01(0.035 + (ratio * 0.965));
  }

  static double _computeSoilMoisture({
    required double absorptionCapacity,
    required double vitality,
  }) {
    return _clamp01((absorptionCapacity * 0.68) + (vitality * 0.32));
  }

  static double _computeVitality({
    required DateTime now,
    required DateTime? plantedAt,
    required DateTime? lastWateredAt,
    required List<ResponseEntry> responses,
  }) {
    if (plantedAt == null) {
      return 0.18;
    }

    final baseline = responses.isEmpty ? 0.25 : 0.45;
    if (lastWateredAt == null) return baseline;

    final hoursWithoutWater = now.difference(lastWateredAt).inHours;
    final decay = math.exp(-hoursWithoutWater / 240.0);

    final cadenceBoost = responses.length < 2
        ? 0.0
        : _recentCadenceBoost(now, responses);

    return _clamp01((baseline * decay) + cadenceBoost + 0.15);
  }

  static double _recentCadenceBoost(
    DateTime now,
    List<ResponseEntry> responses,
  ) {
    final recent = responses
        .where((r) => now.difference(r.createdAt).inDays <= 21)
        .length;
    return math.min(0.25, recent * 0.035);
  }

  static List<TreeFruit> _selectFruits({
    required List<ResponseEntry> responses,
    required int seed,
    required Set<String> harvestedResponseIds,
    required int harvestedCount,
    required DateTime now,
  }) {
    final candidates = responses.where((response) {
      if (harvestedResponseIds.contains(response.id)) {
        return false;
      }

      final ageDays = now.difference(response.createdAt).inDays;
      if (ageDays < 45) return false;

      final lastReviewedAt = response.lastReviewedAt;
      if (lastReviewedAt == null) return true;

      return now.difference(lastReviewedAt).inDays >= 30;
    });

    final withScore =
        candidates
            .map((response) {
              final cycle =
                  now.millisecondsSinceEpoch ~/
                  const Duration(days: 7).inMilliseconds;
              final raw = _stableHash(
                '$seed|${response.id}|$cycle|${response.questionId}',
              );

              final ageFactor = math.min(
                40,
                now.difference(response.createdAt).inDays ~/ 5,
              );
              final depthFactor = (response.growthMetadata?.depth ?? 1) * 3;
              final score = (raw % 100) + ageFactor + depthFactor;

              return (response: response, score: score);
            })
            .toList(growable: false)
          ..sort((a, b) => b.score.compareTo(a.score));

    final growthBoost = 1 - math.exp(-(harvestedCount / 8.0));
    final dynamicThreshold = (78 - (growthBoost * 20)).clamp(56, 78).toInt();
    final maxPending = (2 + (growthBoost * 3)).clamp(2, 5).toInt();

    return withScore
        .where((entry) => entry.score >= dynamicThreshold)
        .take(maxPending)
        .map(
          (entry) => TreeFruit(
            responseId: entry.response.id,
            questionId: entry.response.questionId,
            sourceCreatedAt: entry.response.createdAt,
            surfacedAt: now,
            intensity: math.min(5, (entry.score / 25).floor() + 1),
          ),
        )
        .toList(growable: false);
  }

  static int _stableHash(String input) {
    int hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  static double _clamp01(double value) {
    if (value <= 0) return 0;
    if (value >= 1) return 1;
    return value;
  }
}
