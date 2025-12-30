import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

typedef VideoCapturedCallback = void Function(String path);

class VideoInputCapture extends StatefulWidget {
  final VideoCapturedCallback onCaptured;

  const VideoInputCapture({
    super.key,
    required this.onCaptured,
  });

  @override
  State<VideoInputCapture> createState() => _VideoInputCaptureState();
}

class _VideoInputCaptureState extends State<VideoInputCapture> {
  final ImagePicker _picker = ImagePicker();
  XFile? _video;

  Future<void> _recordVideo() async {
    final result = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );

    if (result == null) return;

    setState(() {
      _video = result;
    });

    widget.onCaptured(result.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_video != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: const [
                Icon(
                  CupertinoIcons.film,
                  size: 64,
                  color: CupertinoColors.systemGrey,
                ),
                SizedBox(height: 8),
                Text(
                  'Video listo para guardar',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
              ],
            ),
          ),
        CupertinoButton.filled(
          onPressed: _recordVideo,
          child: const Text('Grabar video'),
        ),
      ],
    );
  }
}