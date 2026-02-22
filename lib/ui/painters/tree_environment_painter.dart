import 'package:flutter/cupertino.dart';

class TreeGroundPainter extends CustomPainter {
  final double vitality;

  const TreeGroundPainter({required this.vitality});

  @override
  void paint(Canvas canvas, Size size) {
    final v = vitality.clamp(0.0, 1.0);

    final hillColor = Color.lerp(
      const Color(0xFF2D3B1E),
      const Color(0xFF3D5A2A),
      v,
    )!;

    final hillShadow = Color.lerp(
      const Color(0xFF1E2515),
      const Color(0xFF24361A),
      v,
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
    return oldDelegate.vitality != vitality;
  }
}
