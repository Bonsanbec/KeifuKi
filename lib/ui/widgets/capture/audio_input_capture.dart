import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

typedef AudioRecordedCallback = void Function(String path, int durationSeconds);

class AudioInputCapture extends StatefulWidget {
  final AudioRecordedCallback onRecorded;

  const AudioInputCapture({
    super.key,
    required this.onRecorded,
  });

  @override
  _AudioInputCaptureState createState() => _AudioInputCaptureState();
}

class _AudioInputCaptureState extends State<AudioInputCapture> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  late String _currentFilePath;
  Timer? _timer;
  int _recordSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
  }

  Future<String> _generateFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final id = const Uuid().v4();
    return '${dir.path}/$id.m4a';
  }

  void _startRecording() async {
    _currentFilePath = await _generateFilePath();
    _recordSeconds = 0;
    setState(() => _isRecording = true);

    // Starts the recorder
    await _recorder.startRecorder(
      toFile: _currentFilePath,
      codec: Codec.aacMP4,
    );

    // Simple timer for duration
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  void _stopRecording() async {
    await _recorder.stopRecorder();
    _timer?.cancel();

    setState(() => _isRecording = false);

    widget.onRecorded(_currentFilePath, _recordSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isRecording
              ? 'Grabando… $_recordSeconds s'
              : 'Toca para grabar audio',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        CupertinoButton.filled(
          child: Icon(
            _isRecording ? CupertinoIcons.stop_circle : CupertinoIcons.mic,
          ),
          onPressed: () {
            if (_isRecording) {
              _stopRecording();
            } else {
              _startRecording();
            }
          },
        ),
      ],
    );
  }
}