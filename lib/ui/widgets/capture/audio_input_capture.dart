import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

typedef AudioRecordedCallback = void Function(String path, int durationSeconds);

class AudioInputCapture extends StatefulWidget {
  final AudioRecordedCallback onRecorded;

  const AudioInputCapture({super.key, required this.onRecorded});

  @override
  State<AudioInputCapture> createState() => _AudioInputCaptureState();
}

class _AudioInputCaptureState extends State<AudioInputCapture>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  late final AnimationController _waveController;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  Timer? _timer;
  int _recordSeconds = 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();

    _initialize();
  }

  Future<void> _initialize() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
    await Permission.microphone.request();
  }

  Future<String> _generateFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final id = const Uuid().v4();
    return '${dir.path}/$id.m4a';
  }

  Future<void> _startRecording() async {
    final filePath = await _generateFilePath();

    _recordedPath = null;
    _recordSeconds = 0;
    setState(() {
      _isRecording = true;
      _isPlaying = false;
    });

    await _recorder.startRecorder(toFile: filePath, codec: Codec.aacMP4);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _recordSeconds++;
      });
    });

    _recordedPath = filePath;
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _timer?.cancel();

    setState(() {
      _isRecording = false;
    });

    final path = _recordedPath;
    if (path != null) {
      widget.onRecorded(path, _recordSeconds);
    }
  }

  Future<void> _togglePlayback() async {
    if (_recordedPath == null) return;

    if (_isPlaying) {
      await _player.stopPlayer();
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    await _player.startPlayer(
      fromURI: _recordedPath,
      whenFinished: () {
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _isPlaying = true;
    });
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        final t = _waveController.value;

        return SizedBox(
          height: 78,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(24, (index) {
              final phase = (t * 2 * 3.1415926) + (index * 0.42);
              final amp = (_isRecording
                  ? (0.4 + (0.6 * (math.sin(phase).abs())))
                  : 0.22);
              final h = 10 + (amp * 46);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.8),
                child: Container(
                  width: 5,
                  height: h,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? const Color(0xFFFF7A59)
                        : const Color(0x88D7E4FF),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRecording = _recordedPath != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isRecording
              ? 'Grabando… $_recordSeconds s'
              : (_recordedPath == null
                    ? 'Toca para grabar audio'
                    : 'Audio capturado'),
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF2F8FF),
          ),
        ),
        const SizedBox(height: 16),
        _buildWaveform(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!hasRecording || _isRecording)
              CupertinoButton.filled(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child: Icon(
                  _isRecording
                      ? CupertinoIcons.stop_circle
                      : CupertinoIcons.mic,
                  size: 28,
                ),
              ),
            if (hasRecording && !_isRecording) ...[
              CupertinoButton(
                color: const Color(0xAA15345C),
                onPressed: _togglePlayback,
                child: Row(
                  children: [
                    Icon(
                      _isPlaying ? CupertinoIcons.pause : CupertinoIcons.play,
                      size: 22,
                      color: const Color(0xFFF3FAFF),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Previsualizar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF3FAFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
