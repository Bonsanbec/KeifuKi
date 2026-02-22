import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

import '../../domain/tree_state.dart';

class ProceduralTreeNode {
  final Offset start;
  final Offset end;
  final double maxLength;
  final double maxThickness;
  final int depth;
  final double growthIndex;
  final bool isTerminal;

  const ProceduralTreeNode({
    required this.start,
    required this.end,
    required this.maxLength,
    required this.maxThickness,
    required this.depth,
    required this.growthIndex,
    required this.isTerminal,
  });

  Offset pointAt(double t) => Offset.lerp(start, end, t.clamp(0.0, 1.0)) ?? end;
}

class _DraftNode {
  final Offset start;
  final Offset end;
  final double maxLength;
  final double maxThickness;
  final int depth;
  final bool isTerminal;

  _DraftNode({
    required this.start,
    required this.end,
    required this.maxLength,
    required this.maxThickness,
    required this.depth,
    required this.isTerminal,
  });
}

class ProceduralTreePainter extends CustomPainter {
  static const int maxDepth = 10;

  final int growthSeed;
  final double growthRatio;
  final double vitality;
  final List<StructuralMarker> structuralMarkers;

  late final List<ProceduralTreeNode> _nodes = _generateNodes(
    seed: growthSeed,
    maxDepth: maxDepth,
  );

  ProceduralTreePainter({
    required this.growthSeed,
    required this.growthRatio,
    required this.vitality,
    required this.structuralMarkers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final trunkColor = Color.lerp(
      const Color(0xFF4E342E),
      const Color(0xFF6D4C41),
      vitality.clamp(0.0, 1.0),
    )!;

    final minSide = math.min(size.width, size.height);
    final visible = _nodes
        .where((n) => n.growthIndex <= growthRatio)
        .toList(growable: false);

    for (final node in visible) {
      final start = Offset(
        node.start.dx * size.width,
        node.start.dy * size.height,
      );
      final end = Offset(node.end.dx * size.width, node.end.dy * size.height);

      final depthScale = math.pow(0.9, node.depth).toDouble();
      final strokeWidth = (node.maxThickness * minSide * depthScale)
          .clamp(0.7, 14.0)
          .toDouble();

      final branchPaint = Paint()
        ..color = trunkColor.withValues(
          alpha: ((0.92 - (node.depth * 0.03)).clamp(0.35, 0.92)).toDouble(),
        )
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, branchPaint);
    }

    _paintLeaves(canvas, size, visible);
    _paintFruits(canvas, size, visible);
  }

  void _paintLeaves(
    Canvas canvas,
    Size size,
    List<ProceduralTreeNode> visible,
  ) {
    final terminals = visible
        .where((n) => n.isTerminal)
        .toList(growable: false);
    if (terminals.isEmpty) return;

    final leafSaturation = (0.35 + (vitality * 0.65)).clamp(0.0, 1.0);
    final leafCountJitter = _seededRandom(growthSeed ^ 0x55AA).nextDouble();
    final desiredLeaves = (terminals.length * (0.55 + (leafCountJitter * 0.35)))
        .floor();

    int drawn = 0;
    for (final node in terminals) {
      if (drawn >= desiredLeaves) break;

      final leafProgress = ((growthRatio - node.growthIndex) / 0.08).clamp(
        0.0,
        1.0,
      );
      if (leafProgress <= 0) continue;

      final end = Offset(node.end.dx * size.width, node.end.dy * size.height);
      final localSeed = _stableHash(
        '$growthSeed|leaf|${node.depth}|${node.growthIndex}',
      );
      final r = _seededRandom(localSeed);

      final radius = (2.8 + r.nextDouble() * 3.6) * leafProgress;
      final dx = (r.nextDouble() - 0.5) * 8;
      final dy = (r.nextDouble() - 0.5) * 8;

      final hue = 105 + (r.nextDouble() * 16);
      final sat = 0.45 + (leafSaturation * 0.4);
      final light = 0.34 + (leafSaturation * 0.18);
      final color = HSLColor.fromAHSL(0.85, hue, sat, light).toColor();

      final paint = Paint()
        ..color = color.withValues(alpha: (leafProgress * 0.9));
      canvas.drawCircle(end.translate(dx, dy), radius, paint);
      drawn += 1;
    }
  }

  void _paintFruits(
    Canvas canvas,
    Size size,
    List<ProceduralTreeNode> visible,
  ) {
    if (structuralMarkers.isEmpty || visible.isEmpty) return;

    final candidates = visible
        .where((n) => n.depth >= 3)
        .toList(growable: false);
    if (candidates.isEmpty) return;

    for (final marker in structuralMarkers) {
      final key =
          '$growthSeed|fruit|${marker.id}|${marker.createdAt.millisecondsSinceEpoch}';
      final index = _stableHash(key) % candidates.length;
      final node = candidates[index];

      final maturity = ((growthRatio - node.growthIndex) / 0.16).clamp(
        0.0,
        1.0,
      );
      if (maturity <= 0) continue;

      final end = Offset(node.end.dx * size.width, node.end.dy * size.height);
      final fruitRadius =
          (3.2 + marker.intensity.toDouble()).clamp(3.0, 7.0) * maturity;

      final fruitColor = Color.lerp(
        const Color(0xFFBDB76B),
        const Color(0xFFE53935),
        (0.35 + (vitality * 0.65)).clamp(0.0, 1.0),
      )!;

      final paint = Paint()
        ..color = fruitColor.withValues(
          alpha: ((0.45 + maturity * 0.55).clamp(0.0, 1.0)).toDouble(),
        );
      canvas.drawCircle(end, fruitRadius, paint);
    }
  }

  static List<ProceduralTreeNode> _generateNodes({
    required int seed,
    required int maxDepth,
  }) {
    final random = _seededRandom(seed);
    final draft = <_DraftNode>[];

    void build({
      required Offset start,
      required double angle,
      required double length,
      required double thickness,
      required int depth,
    }) {
      if (depth > maxDepth) return;

      final effectiveLength =
          length * (0.98 - (depth * 0.015)).clamp(0.72, 1.0);
      final end = Offset(
        start.dx + (math.cos(angle) * effectiveLength),
        start.dy - (math.sin(angle) * effectiveLength),
      );

      final isTerminal = depth == maxDepth;
      draft.add(
        _DraftNode(
          start: start,
          end: end,
          maxLength: effectiveLength,
          maxThickness: thickness,
          depth: depth,
          isTerminal: isTerminal,
        ),
      );

      if (isTerminal) return;

      final remaining = maxDepth - depth;
      final spreadBase = 0.24 + (random.nextDouble() * 0.22);
      final jitterA = (random.nextDouble() - 0.5) * 0.14;
      final jitterB = (random.nextDouble() - 0.5) * 0.14;

      final childLengthFactor = (0.7 + (random.nextDouble() * 0.1));
      final childThicknessFactor = (0.7 + (random.nextDouble() * 0.08));

      int childCount = 2;
      final branchingChance = (0.18 + (remaining * 0.02)).clamp(0.0, 0.38);
      if (remaining > 2 && random.nextDouble() < branchingChance) {
        childCount = 3;
      }

      final leftAngle = angle + spreadBase + jitterA;
      final rightAngle = angle - spreadBase + jitterB;

      build(
        start: end,
        angle: leftAngle,
        length: effectiveLength * childLengthFactor,
        thickness: thickness * childThicknessFactor,
        depth: depth + 1,
      );

      build(
        start: end,
        angle: rightAngle,
        length: effectiveLength * childLengthFactor,
        thickness: thickness * childThicknessFactor,
        depth: depth + 1,
      );

      if (childCount == 3) {
        final centerJitter = (random.nextDouble() - 0.5) * 0.18;
        build(
          start: end,
          angle: angle + centerJitter,
          length: effectiveLength * (childLengthFactor * 0.88),
          thickness: thickness * (childThicknessFactor * 0.82),
          depth: depth + 1,
        );
      }
    }

    build(
      start: const Offset(0.5, 0.96),
      angle: math.pi / 2,
      length: 0.19,
      thickness: 0.03,
      depth: 0,
    );

    final total = draft.length;
    if (total == 0) return const [];

    return List<ProceduralTreeNode>.generate(total, (i) {
      final node = draft[i];
      final growthIndex = total == 1 ? 1.0 : i / (total - 1);
      return ProceduralTreeNode(
        start: node.start,
        end: node.end,
        maxLength: node.maxLength,
        maxThickness: node.maxThickness,
        depth: node.depth,
        growthIndex: growthIndex,
        isTerminal: node.isTerminal,
      );
    }, growable: false);
  }

  static math.Random _seededRandom(int seed) => math.Random(seed & 0x7fffffff);

  static int _stableHash(String input) {
    int hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  @override
  bool shouldRepaint(covariant ProceduralTreePainter oldDelegate) {
    return oldDelegate.growthSeed != growthSeed ||
        oldDelegate.growthRatio != growthRatio ||
        oldDelegate.vitality != vitality ||
        oldDelegate.structuralMarkers.length != structuralMarkers.length ||
        oldDelegate.structuralMarkers.fold<int>(
              0,
              (sum, marker) => sum ^ marker.id.hashCode ^ marker.intensity,
            ) !=
            structuralMarkers.fold<int>(
              0,
              (sum, marker) => sum ^ marker.id.hashCode ^ marker.intensity,
            );
  }
}
