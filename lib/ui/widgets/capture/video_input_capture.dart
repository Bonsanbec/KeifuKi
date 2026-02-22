import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

typedef VideoCapturedCallback = void Function(String path);

class VideoInputCapture extends StatefulWidget {
  final VideoCapturedCallback onCaptured;

  const VideoInputCapture({super.key, required this.onCaptured});

  @override
  State<VideoInputCapture> createState() => _VideoInputCaptureState();
}

class _VideoInputCaptureState extends State<VideoInputCapture> {
  final ImagePicker _picker = ImagePicker();
  XFile? _video;
  VideoPlayerController? _controller;

  Future<void> _recordVideo() async {
    final result = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );

    if (result == null) return;

    await _controller?.dispose();
    final controller = VideoPlayerController.file(File(result.path));
    await controller.initialize();

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      _video = result;
      _controller = controller;
    });

    widget.onCaptured(result.path);
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller != null && controller.value.isInitialized)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoPlayer(controller),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          minimumSize: const Size(40, 40),
                          color: const Color(0xAA0C1B33),
                          onPressed: _togglePlayback,
                          child: Icon(
                            controller.value.isPlaying
                                ? CupertinoIcons.pause
                                : CupertinoIcons.play,
                            color: const Color(0xFFF4FAFF),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        CupertinoButton.filled(
          onPressed: _recordVideo,
          child: Text(_video == null ? 'Grabar video' : 'Regrabar video'),
        ),
      ],
    );
  }
}
