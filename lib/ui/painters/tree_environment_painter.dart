import 'package:flutter/cupertino.dart';

class TreeGroundPainter extends CustomPainter {
  final double vitality;
  final double soilMoistureLevel;

  const TreeGroundPainter({
    required this.vitality,
    this.soilMoistureLevel = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final v = vitality.clamp(0.0, 1.0);

    final moisture = soilMoistureLevel.clamp(0.0, 1.0);
    final hillColor = Color.lerp(
      const Color(0xFF202713),
      const Color(0xFF4B6A34),
      (v * 0.55) + (moisture * 0.45),
    )!;

    final hillShadow = Color.lerp(
      const Color(0xFF141A0E),
      const Color(0xFF2D4320),
      (v * 0.4) + (moisture * 0.6),
    )!;

    final yBase = size.height * 0.875;
    final moundHalfWidth = size.width * 0.5;
    final moundHeight = size.height * 0.032;
    final centerX = size.width * 0.5;
    final leftX = 0.0;
    final rightX = size.width;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(leftX, yBase)
      ..cubicTo(
        centerX - (moundHalfWidth * 0.78),
        yBase - (moundHeight * 0.2),
        centerX - (moundHalfWidth * 0.32),
        yBase - moundHeight,
        centerX,
        yBase - moundHeight,
      )
      ..cubicTo(
        centerX + (moundHalfWidth * 0.32),
        yBase - moundHeight,
        centerX + (moundHalfWidth * 0.78),
        yBase - (moundHeight * 0.2),
        rightX,
        yBase,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    final shadowPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(leftX, yBase + size.height * 0.018)
      ..cubicTo(
        centerX - (moundHalfWidth * 0.78),
        yBase + size.height * 0.012,
        centerX - (moundHalfWidth * 0.32),
        yBase - (moundHeight * 0.72),
        centerX,
        yBase - (moundHeight * 0.72),
      )
      ..cubicTo(
        centerX + (moundHalfWidth * 0.32),
        yBase - (moundHeight * 0.72),
        centerX + (moundHalfWidth * 0.78),
        yBase + size.height * 0.012,
        rightX,
        yBase + size.height * 0.018,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(shadowPath, Paint()..color = hillShadow);
    canvas.drawPath(path, Paint()..color = hillColor);
  }

  @override
  bool shouldRepaint(covariant TreeGroundPainter oldDelegate) {
    return oldDelegate.vitality != vitality ||
        oldDelegate.soilMoistureLevel != soilMoistureLevel;
  }
}
