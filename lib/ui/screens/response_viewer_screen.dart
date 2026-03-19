import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:video_player/video_player.dart';

import '../../data/response_dao.dart';
import '../../domain/question.dart';
import '../../domain/question_registry.dart';
import '../../domain/response.dart';
import '../../services/app_data_runtime.dart';

class ResponseViewerScreen extends StatefulWidget {
  final ResponseEntry response;

  const ResponseViewerScreen({super.key, required this.response});

  @override
  State<ResponseViewerScreen> createState() => _ResponseViewerScreenState();
}

class _ResponseViewerScreenState extends State<ResponseViewerScreen> {
  Question? _question;
  FlutterSoundPlayer? _audioPlayer;
  VideoPlayerController? _videoController;

  StreamSubscription? _audioProgressSub;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
    _markReviewed();
  }

  @override
  void dispose() {
    _audioProgressSub?.cancel();
    _audioPlayer?.closePlayer();
    _audioPlayer = null;
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadQuestion() async {
    final q = QuestionRegistry.byId[widget.response.questionId];
    if (!mounted) return;
    setState(() => _question = q);
  }

  Future<void> _markReviewed() async {
    if (AppDataRuntime.isReadOnlySync()) {
      return;
    }
    await ResponseDao.markReviewed(
      responseId: widget.response.id,
      reviewedAt: DateTime.now(),
    );
  }

  Widget _buildContent() {
    switch (widget.response.mediaType) {
      case 'text':
        return SingleChildScrollView(
          child: Text(
            File(widget.response.filePath).readAsStringSync(),
            style: const TextStyle(
              fontSize: 19,
              color: Color(0xFFF3F9FF),
              height: 1.35,
            ),
          ),
        );

      case 'image':
        return InteractiveViewer(
          child: Center(
            child: Image.file(
              File(widget.response.filePath),
              fit: BoxFit.contain,
            ),
          ),
        );

      case 'audio':
        _audioPlayer ??= FlutterSoundPlayer()
          ..openPlayer().then((_) {
            _audioDuration = Duration(
              milliseconds: widget.response.durationSeconds != null
                  ? widget.response.durationSeconds! * 1000
                  : 0,
            );
            _audioProgressSub ??= _audioPlayer!.onProgress!.listen((event) {
              if (!mounted) return;
              setState(() {
                _audioPosition = event.position;
                _audioDuration = event.duration;
              });
            });
          });

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoSlider(
              value: _audioDuration.inMilliseconds == 0
                  ? 0
                  : _audioPosition.inMilliseconds /
                        _audioDuration.inMilliseconds,
              onChanged: (v) async {
                final pos = _audioDuration * v;
                await _audioPlayer!.seekToPlayer(pos);
              },
            ),
            Text(
              '${_audioPosition.inSeconds}s / ${_audioDuration.inSeconds}s',
              style: const TextStyle(color: Color(0xFFD5E6FF), fontSize: 15),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              child: const Text('Reproducir'),
              onPressed: () async {
                await _audioPlayer!.startPlayer(
                  fromURI: widget.response.filePath,
                );
              },
            ),
          ],
        );

      case 'video':
        _videoController ??=
            VideoPlayerController.file(File(widget.response.filePath))
              ..initialize().then((_) {
                if (mounted) setState(() {});
              });

        if (!_videoController!.value.isInitialized) {
          return const Center(child: CupertinoActivityIndicator());
        }

        return Column(
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              color: const Color(0xAA15345C),
              child: Text(
                _videoController!.value.isPlaying ? 'Pausar' : 'Reproducir',
                style: const TextStyle(color: Color(0xFFF4FAFF)),
              ),
              onPressed: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
            ),
          ],
        );

      default:
        return const Text(
          'Tipo de respuesta desconocido',
          style: TextStyle(color: Color(0xFFF4FAFF)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A1023),
                      Color(0xFF102A5A),
                      Color(0xFF1A3529),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 10,
              child: CupertinoButton(
                padding: const EdgeInsets.all(10),
                minimumSize: const Size(44, 44),
                color: const Color(0xAA0D1A2D),
                borderRadius: BorderRadius.circular(22),
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(
                  CupertinoIcons.back,
                  color: Color(0xFFF4FAFF),
                  size: 26,
                ),
              ),
            ),
            Positioned.fill(
              top: 80,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: _question == null
                    ? const Center(child: CupertinoActivityIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _question!.text,
                            style: const TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF5FAFF),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(child: _buildContent()),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
