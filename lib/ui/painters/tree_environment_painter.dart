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

    final yBase = size.height * 0.84;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, yBase)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.73,
        size.width * 0.48,
        yBase,
      )
      ..quadraticBezierTo(
        size.width * 0.73,
        size.height * 0.93,
        size.width,
        yBase - size.height * 0.02,
      )
      ..lineTo(size.width, size.height)
      ..close();

    final shadowPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, yBase + size.height * 0.03)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.78,
        size.width * 0.52,
        yBase + size.height * 0.05,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.97,
        size.width,
        yBase + size.height * 0.02,
      )
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
