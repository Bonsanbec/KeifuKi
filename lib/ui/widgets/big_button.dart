import 'package:flutter/cupertino.dart';

class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}