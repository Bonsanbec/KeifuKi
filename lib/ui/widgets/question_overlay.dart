import 'package:flutter/cupertino.dart';

class QuestionOverlay extends StatelessWidget {
  static const double topOffset = 72;
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: 20,
  );

  final String text;

  const QuestionOverlay({super.key, required this.text});

  double _fontSizeFor(String value) {
    final int length = value.trim().length;
    if (length > 210) return 20;
    if (length > 160) return 22;
    if (length > 110) return 25;
    if (length > 70) return 28;
    return 31;
  }

  Future<void> _showExpandedQuestion(BuildContext context) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Pregunta'),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SingleChildScrollView(
              child: Text(
                text,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = _fontSizeFor(text);

    return Positioned(
      top: topOffset,
      left: horizontalPadding.left,
      right: horizontalPadding.right,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showExpandedQuestion(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            text,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: const Color(0xFFF6FAFF),
              shadows: const [
                Shadow(
                  color: Color(0xCC000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
