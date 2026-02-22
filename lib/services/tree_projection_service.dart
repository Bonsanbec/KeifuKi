import 'dart:math' as math;

import '../domain/response.dart';
import '../domain/tree_projection.dart';
import '../domain/tree_state.dart';

class TreeProjectionService {
  const TreeProjectionService._();

  static TreeProjection project({
    required TreeState treeState,
    required List<ResponseEntry> responses,
    required DateTime now,
  }) {
    final sortedResponses = [...responses]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final growthRatio = _computeGrowthRatio(
      now: now,
      plantedAt: treeState.plantedAt,
      responses: sortedResponses,
      structuralMarkers: treeState.structuralMarkers,
    );

    final vitality = _computeVitality(
      now: now,
      plantedAt: treeState.plantedAt,
      lastWateredAt: treeState.lastWateredAt,
      responses: sortedResponses,
    );

    final fruits = _selectFruits(
      responses: sortedResponses,
      seed: treeState.growthSeed,
      now: now,
    );

    return TreeProjection(
      isPlanted: treeState.plantedAt != null,
      identityName: treeState.identityName,
      growthRatio: growthRatio,
      vitality: vitality,
      structuralMarkers: treeState.structuralMarkers,
      growthSeed: treeState.growthSeed,
      availableFruits: fruits,
      lastWateredAt: treeState.lastWateredAt,
    );
  }

  static double _weightedResponseScore(List<ResponseEntry> responses) {
    double total = 0;

    for (final response in responses) {
      final metadata = response.growthMetadata;
      final depth = metadata?.depth ?? 1;
      final emotionalWeight = metadata?.emotionalWeight ?? 1;
      final novelty = metadata?.novelty ?? 1;
      final ageBonus = math.log(
        response.createdAt.millisecondsSinceEpoch / 86400000 + 2,
      );

      total +=
          (depth * 1.9) +
          (emotionalWeight * 1.35) +
          (novelty * 1.25) +
          ageBonus;

      if (metadata?.structuralShift == true) {
        total += 2.4;
      }
    }

    return total;
  }

  static double _computeGrowthRatio({
    required DateTime now,
    required DateTime? plantedAt,
    required List<ResponseEntry> responses,
    required List<StructuralMarker> structuralMarkers,
  }) {
    if (plantedAt == null) return 0.0;

    final elapsedDays = math.max(0, now.difference(plantedAt).inDays);
    final weightedResponses = _weightedResponseScore(responses);

    final timeTerm = math.log(elapsedDays + 1) / math.log(365 + 1);
    final responseTerm = math.sqrt(
      math.log(weightedResponses + 1) / math.log(2500 + 1),
    );

    double markerTerm = 0;
    for (final marker in structuralMarkers) {
      markerTerm += marker.intensity * 0.02;
    }

    final baseGrowth = (timeTerm * 0.55) + (responseTerm * 0.45);
    final ratio = math.sqrt(_clamp01(baseGrowth + markerTerm));

    // Keep initial growth subtle but visible once planted.
    return _clamp01(0.04 + (ratio * 0.96));
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
    required DateTime now,
  }) {
    final candidates = responses.where((response) {
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

    return withScore
        .where((entry) => entry.score >= 72)
        .take(3)
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
