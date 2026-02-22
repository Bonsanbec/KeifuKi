import 'package:flutter/cupertino.dart';

class QuestionOverlay extends StatelessWidget {
  static const double topOffset = 56;
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: 20,
  );

  final String text;

  const QuestionOverlay({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset,
      left: horizontalPadding.left,
      right: horizontalPadding.right,
      child: IgnorePointer(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 31,
            height: 1.22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Color(0xFFF6FAFF),
            shadows: [
              Shadow(
                color: Color(0xCC000000),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
