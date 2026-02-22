import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class TimeSkyStyle {
  final List<Color> colors;
  final double celestialProgress;
  final bool isNight;

  const TimeSkyStyle({
    required this.colors,
    required this.celestialProgress,
    required this.isNight,
  });

  static TimeSkyStyle fromLocalTime(DateTime now) {
    final hour = now.hour + (now.minute / 60.0);

    if (hour >= 5 && hour < 8) {
      final t = ((hour - 5) / 3).clamp(0.0, 1.0);
      return TimeSkyStyle(
        colors: [
          Color.lerp(const Color(0xFF201029), const Color(0xFF3B3A7A), t)!,
          Color.lerp(const Color(0xFF8D4A3A), const Color(0xFFDB8A55), t)!,
          Color.lerp(const Color(0xFF503C28), const Color(0xFF6D5A33), t)!,
        ],
        celestialProgress: (hour - 5) / 14,
        isNight: false,
      );
    }

    if (hour >= 8 && hour < 17) {
      final t = ((hour - 8) / 9).clamp(0.0, 1.0);
      return TimeSkyStyle(
        colors: [
          Color.lerp(const Color(0xFF1A4AA2), const Color(0xFF2765C8), t)!,
          Color.lerp(const Color(0xFF2A7ADB), const Color(0xFF4A9AE8), t)!,
          Color.lerp(const Color(0xFF3A6A36), const Color(0xFF4F7E43), t)!,
        ],
        celestialProgress: (hour - 5) / 14,
        isNight: false,
      );
    }

    if (hour >= 17 && hour < 20) {
      final t = ((hour - 17) / 3).clamp(0.0, 1.0);
      return TimeSkyStyle(
        colors: [
          Color.lerp(const Color(0xFF1D2E6D), const Color(0xFF2A1B44), t)!,
          Color.lerp(const Color(0xFFE06534), const Color(0xFFB93C26), t)!,
          Color.lerp(const Color(0xFF4E4C28), const Color(0xFF382D1F), t)!,
        ],
        celestialProgress: (hour - 5) / 14,
        isNight: false,
      );
    }

    final normalizedNightHour = hour >= 20 ? hour - 20 : hour + 4;
    final tNight = (normalizedNightHour / 9).clamp(0.0, 1.0);
    return TimeSkyStyle(
      colors: [
        Color.lerp(const Color(0xFF040612), const Color(0xFF070A18), tNight)!,
        Color.lerp(const Color(0xFF0B1841), const Color(0xFF090E2B), tNight)!,
        Color.lerp(const Color(0xFF17261E), const Color(0xFF131D17), tNight)!,
      ],
      celestialProgress: ((hour + 4) % 24) / 24,
      isNight: true,
    );
  }
}

class TimeSkyPainter extends CustomPainter {
  final DateTime now;

  const TimeSkyPainter({required this.now});

  @override
  void paint(Canvas canvas, Size size) {
    final style = TimeSkyStyle.fromLocalTime(now);

    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.5, 1.0],
      colors: style.colors,
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final center = _celestialPosition(
      size,
      style.celestialProgress,
      style.isNight,
    );
    final radius = size.shortestSide * 0.075;

    final bodyColor = style.isNight
        ? const Color(0xFFE6ECFF)
        : const Color(0xFFFFE9A8);
    final haloColor = style.isNight
        ? const Color(0x556D7BB8)
        : const Color(0x66FFC76A);

    canvas.drawCircle(center, radius * 1.8, Paint()..color = haloColor);
    canvas.drawCircle(center, radius, Paint()..color = bodyColor);

    if (style.isNight) {
      final crater = Paint()..color = const Color(0x66B8C5E8);
      canvas.drawCircle(
        center.translate(-radius * 0.2, -radius * 0.15),
        radius * 0.17,
        crater,
      );
      canvas.drawCircle(
        center.translate(radius * 0.25, radius * 0.1),
        radius * 0.12,
        crater,
      );
    }
  }

  Offset _celestialPosition(Size size, double progress, bool isNight) {
    final x = size.width * progress.clamp(0.0, 1.0);

    final arcBase = isNight ? size.height * 0.36 : size.height * 0.42;
    final arcAmp = size.height * 0.2;
    final theta = progress * math.pi;
    final y = arcBase - (math.sin(theta) * arcAmp);

    return Offset(x, y.clamp(size.height * 0.08, size.height * 0.62));
  }

  @override
  bool shouldRepaint(covariant TimeSkyPainter oldDelegate) {
    final oldMinutes = oldDelegate.now.hour * 60 + oldDelegate.now.minute;
    final newMinutes = now.hour * 60 + now.minute;
    return oldMinutes != newMinutes;
  }
}
