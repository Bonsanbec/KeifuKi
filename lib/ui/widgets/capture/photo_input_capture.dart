import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

typedef PhotoCapturedCallback = void Function(String path);

class PhotoInputCapture extends StatefulWidget {
  final PhotoCapturedCallback onCaptured;

  const PhotoInputCapture({
    super.key,
    required this.onCaptured,
  });

  @override
  State<PhotoInputCapture> createState() => _PhotoInputCaptureState();
}

class _PhotoInputCaptureState extends State<PhotoInputCapture> {
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;

  Future<void> _takePhoto() async {
    final result = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // buena calidad, tamaño razonable
    );

    if (result == null) return;

    setState(() {
      _photo = result;
    });

    widget.onCaptured(result.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_photo != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_photo!.path),
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
          ),
        CupertinoButton.filled(
          onPressed: _takePhoto,
          child: const Text('Tomar foto'),
        ),
      ],
    );
  }
}