import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../domain/tree_projection.dart';

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
}

class ProceduralFruitPlacement {
  final String responseId;
  final Offset center;
  final double radius;

  const ProceduralFruitPlacement({
    required this.responseId,
    required this.center,
    required this.radius,
  });
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
  final double absorptionCapacity;
  final List<TreeFruit> fruits;

  late final List<ProceduralTreeNode> _nodes = _generateNodes(
    seed: growthSeed,
    maxDepth: maxDepth,
  );

  ProceduralTreePainter({
    required this.growthSeed,
    required this.growthRatio,
    required this.vitality,
    required this.absorptionCapacity,
    required this.fruits,
  });

  List<ProceduralTreeNode> _visibleNodes() {
    return _nodes
        .where((n) => n.growthIndex <= growthRatio)
        .toList(growable: false);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final trunkColor = Color.lerp(
      const Color(0xFF5A3B30),
      const Color(0xFF7A4E3C),
      vitality.clamp(0.0, 1.0),
    )!;

    final visible = _visibleNodes();
    final minSide = math.min(size.width, size.height);

    if (absorptionCapacity > 0.7) {
      final glow = ((absorptionCapacity - 0.7) / 0.3).clamp(0.0, 1.0);
      final glowPaint = Paint()
        ..color = const Color(
          0x99EAD7B0,
        ).withValues(alpha: 0.08 + (glow * 0.18))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.82),
        minSide * (0.14 + (glow * 0.05)),
        glowPaint,
      );
    }

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
          alpha: ((0.94 - (node.depth * 0.03)).clamp(0.38, 0.94)).toDouble(),
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

    final leafSaturation = (0.3 + (vitality * 0.7)).clamp(0.0, 1.0);
    final leafCountJitter = _seededRandom(growthSeed ^ 0x55AA).nextDouble();
    final desiredLeaves = (terminals.length * (0.5 + (leafCountJitter * 0.4)))
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

      final radius = (2.6 + r.nextDouble() * 3.8) * leafProgress;
      final dx = (r.nextDouble() - 0.5) * 10;
      final dy = (r.nextDouble() - 0.5) * 10;

      // Procedural green scale: mixes depth + growth index + seeded jitter.
      final depthFactor = (node.depth / maxDepth).clamp(0.0, 1.0);
      final growthFactor = node.growthIndex.clamp(0.0, 1.0);
      final toneJitter = r.nextDouble();

      final hue = 100 + (depthFactor * 9) + (toneJitter * 16);
      final sat = (0.34 + (leafSaturation * 0.36) + (growthFactor * 0.12))
          .clamp(0.2, 1.0);
      final light =
          (0.24 + (leafSaturation * 0.18) + ((1 - depthFactor) * 0.09)).clamp(
            0.14,
            0.82,
          );
      final color = HSLColor.fromAHSL(0.88, hue, sat, light).toColor();
      final outlineColor = HSLColor.fromColor(color)
          .withLightness(
            (HSLColor.fromColor(color).lightness - 0.08).clamp(0.0, 1.0),
          )
          .withSaturation(
            (HSLColor.fromColor(color).saturation + 0.04).clamp(0.0, 1.0),
          )
          .toColor();

      final fillPaint = Paint()
        ..color = color.withValues(alpha: (leafProgress * 0.9));
      final strokePaint = Paint()
        ..color = outlineColor.withValues(alpha: (leafProgress * 0.86))
        ..style = PaintingStyle.stroke
        ..strokeWidth = (0.7 + (radius * 0.12)).clamp(0.6, 1.3);

      final center = end.translate(dx, dy);
      canvas.drawCircle(center, radius, fillPaint);
      canvas.drawCircle(center, radius, strokePaint);
      drawn += 1;
    }
  }

  void _paintFruits(
    Canvas canvas,
    Size size,
    List<ProceduralTreeNode> visible,
  ) {
    final placements = computeFruitPlacements(
      growthSeed: growthSeed,
      growthRatio: growthRatio,
      vitality: vitality,
      fruits: fruits,
      size: size,
      precomputedVisibleNodes: visible,
    );

    final fruitColor = Color.lerp(
      const Color(0xFFC2B458),
      const Color(0xFFF24A2E),
      (0.35 + (vitality * 0.65)).clamp(0.0, 1.0),
    )!;

    final paint = Paint()..color = fruitColor.withValues(alpha: 0.94);
    for (final placement in placements) {
      canvas.drawCircle(placement.center, placement.radius, paint);
    }
  }

  static List<ProceduralFruitPlacement> computeFruitPlacements({
    required int growthSeed,
    required double growthRatio,
    required double vitality,
    required List<TreeFruit> fruits,
    required Size size,
    List<ProceduralTreeNode>? precomputedVisibleNodes,
  }) {
    final visible =
        precomputedVisibleNodes ??
        _generateNodes(
          seed: growthSeed,
          maxDepth: maxDepth,
        ).where((n) => n.growthIndex <= growthRatio).toList(growable: false);

    if (visible.isEmpty || fruits.isEmpty) return const [];

    final candidates = visible
        .where((n) => n.depth >= 3)
        .toList(growable: false);
    if (candidates.isEmpty) return const [];

    final placements = <ProceduralFruitPlacement>[];
    for (final fruit in fruits) {
      final key = '$growthSeed|fruit|${fruit.responseId}|${fruit.questionId}';
      final index = _stableHash(key) % candidates.length;
      final node = candidates[index];

      final maturity = ((growthRatio - node.growthIndex) / 0.16).clamp(
        0.0,
        1.0,
      );
      if (maturity <= 0) continue;

      final center = Offset(
        node.end.dx * size.width,
        node.end.dy * size.height,
      );
      final radius =
          (3.4 + fruit.intensity.toDouble()).clamp(3.2, 7.4) * maturity;

      placements.add(
        ProceduralFruitPlacement(
          responseId: fruit.responseId,
          center: center,
          radius: radius,
        ),
      );
    }

    return placements;
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

      final childLengthFactor = 0.7 + (random.nextDouble() * 0.1);
      final childThicknessFactor = 0.7 + (random.nextDouble() * 0.08);

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
      start: const Offset(0.5, 0.95),
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
    final oldFingerprint = oldDelegate.fruits.fold<int>(
      0,
      (sum, fruit) => sum ^ fruit.responseId.hashCode ^ fruit.intensity,
    );
    final newFingerprint = fruits.fold<int>(
      0,
      (sum, fruit) => sum ^ fruit.responseId.hashCode ^ fruit.intensity,
    );

    return oldDelegate.growthSeed != growthSeed ||
        oldDelegate.growthRatio != growthRatio ||
        oldDelegate.vitality != vitality ||
        oldDelegate.absorptionCapacity != absorptionCapacity ||
        oldFingerprint != newFingerprint;
  }
}
