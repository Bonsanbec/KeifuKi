import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:video_player/video_player.dart';

import '../../domain/response.dart';
import '../../domain/question.dart';
import '../../domain/question_registry.dart';

class ResponseViewerScreen extends StatefulWidget {
  final ResponseEntry response;

  const ResponseViewerScreen({
    super.key,
    required this.response,
  });

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

  Widget _buildContent() {
    switch (widget.response.mediaType) {
      case 'text':
        return Text(
          File(widget.response.filePath).readAsStringSync(),
          style: const TextStyle(fontSize: 17),
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
            _audioProgressSub ??=
                _audioPlayer!.onProgress!.listen((event) {
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
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
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

        return SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                child: Text(
                  _videoController!.value.isPlaying ? 'Pausar' : 'Reproducir',
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
          ),
        );

      default:
        return const Text('Tipo de respuesta desconocido');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Respuesta'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _question == null
              ? const Center(child: CupertinoActivityIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _question!.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}