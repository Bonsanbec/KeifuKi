import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/response.dart';
import '../../services/media_store.dart';
import '../../services/question_selector.dart';
import '../../data/question_usage_dao.dart';
import '../../data/response_dao.dart';
import '../../services/response_growth_service.dart';
import '../../services/tree_state_service.dart';
import '../widgets/capture/text_input_capture.dart';
import '../widgets/capture/audio_input_capture.dart';
import '../widgets/capture/photo_input_capture.dart';
import '../widgets/capture/video_input_capture.dart';
import '../widgets/question_overlay.dart';
import 'submission_ritual_screen.dart';

class InputCaptureScreen extends StatefulWidget {
  final MediaType mediaType;
  final SelectedQuestion question;

  const InputCaptureScreen({
    super.key,
    required this.mediaType,
    required this.question,
  });

  @override
  State<InputCaptureScreen> createState() => _InputCaptureScreenState();
}

class _InputCaptureScreenState extends State<InputCaptureScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _saving = false;
  String? _mediaFilePath;
  int? _durationSeconds;

  Future<void> _persistAndExit({
    required String responseId,
    required String filePath,
    required int? durationSeconds,
    String? identityText,
    int? textLength,
  }) async {
    final now = DateTime.now();

    final metadata = ResponseGrowthService.buildMetadata(
      questionId: widget.question.id,
      questionCategory: widget.question.category,
      mediaType: widget.mediaType.name,
      durationSeconds: durationSeconds,
      textLength: textLength,
    );

    final entry = ResponseEntry(
      id: responseId,
      questionId: widget.question.id,
      createdAt: now,
      mediaType: widget.mediaType.name,
      durationSeconds: durationSeconds,
      filePath: filePath,
      growthMetadata: metadata,
    );

    await ResponseDao.insert(entry);
    await QuestionUsageDao.recordAnswer(widget.question.id);
    await TreeStateService.registerResponse(
      response: entry,
      identityText: identityText,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (_) =>
            SubmissionRitualScreen(mediaType: widget.mediaType.name),
      ),
    );
  }

  Future<void> _saveResponse() async {
    String? filePath;

    switch (widget.mediaType) {
      case MediaType.text:
        final text = _textController.text.trim();
        if (text.isEmpty) return;

        final responseId = const Uuid().v4();

        setState(() {
          _saving = true;
        });

        filePath = await MediaStore.writeText(
          responseId: responseId,
          content: text,
        );

        await _persistAndExit(
          responseId: responseId,
          filePath: filePath,
          durationSeconds: null,
          identityText: text,
          textLength: text.length,
        );
        break;

      case MediaType.audio:
        if (_mediaFilePath == null) return;

        final responseId = const Uuid().v4();

        setState(() {
          _saving = true;
        });

        final storedPath = await MediaStore.importFile(
          responseId: responseId,
          type: MediaType.audio,
          source: File(_mediaFilePath!),
        );

        await _persistAndExit(
          responseId: responseId,
          filePath: storedPath,
          durationSeconds: _durationSeconds,
        );
        break;

      case MediaType.image:
        if (_mediaFilePath == null) return;

        final responseId = const Uuid().v4();

        setState(() {
          _saving = true;
        });

        final storedPath = await MediaStore.importFile(
          responseId: responseId,
          type: MediaType.image,
          source: File(_mediaFilePath!),
        );

        await _persistAndExit(
          responseId: responseId,
          filePath: storedPath,
          durationSeconds: null,
        );
        break;
      case MediaType.video:
        if (_mediaFilePath == null) return;

        final responseId = const Uuid().v4();

        setState(() {
          _saving = true;
        });

        final storedPath = await MediaStore.importFile(
          responseId: responseId,
          type: MediaType.video,
          source: File(_mediaFilePath!),
        );

        await _persistAndExit(
          responseId: responseId,
          filePath: storedPath,
          durationSeconds: null,
        );
        break;
    }
  }

  Widget _buildCaptureWidget() {
    switch (widget.mediaType) {
      case MediaType.text:
        return TextInputCapture(controller: _textController);
      case MediaType.audio:
        return AudioInputCapture(
          onRecorded: (path, duration) {
            setState(() {
              _mediaFilePath = path;
              _durationSeconds = duration;
            });
          },
        );
      case MediaType.image:
        return PhotoInputCapture(
          onCaptured: (path) {
            setState(() {
              _mediaFilePath = path;
              _durationSeconds = null;
            });
          },
        );
      case MediaType.video:
        return VideoInputCapture(
          onCaptured: (path) {
            setState(() {
              _mediaFilePath = path;
              _durationSeconds = null; // opcional: se puede calcular después
            });
          },
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
            Positioned(
              left: 18,
              right: 18,
              top: 220,
              bottom: 112,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0x8F061125),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildCaptureWidget(),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 26,
              child: CupertinoButton(
                color: const Color(0xFF2C5141),
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: _saving ? null : _saveResponse,
                child: _saving
                    ? const CupertinoActivityIndicator(color: Color(0xFFF4FAFF))
                    : const Text(
                        'Guardar recuerdo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF4FAFF),
                        ),
                      ),
              ),
            ),
            QuestionOverlay(text: widget.question.text),
          ],
        ),
      ),
    );
  }
}
