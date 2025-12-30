import 'package:flutter/cupertino.dart';

class TextInputCapture extends StatelessWidget {
  final TextEditingController controller;

  const TextInputCapture({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: 'Escribe aquí con calma…',
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
    );
  }
}