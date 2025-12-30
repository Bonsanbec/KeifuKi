import 'package:flutter/cupertino.dart';

class LargeText extends StatelessWidget {
  final String text;

  const LargeText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final Color labelColor =
        CupertinoTheme.of(context).textTheme.textStyle.color ??
            CupertinoColors.label;

    return Text(
      text,
      style: TextStyle(
        fontSize: 26,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: labelColor,
      ),
      textAlign: TextAlign.center,
    );
  }
}