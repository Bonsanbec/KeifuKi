import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/response.dart';
import '../../services/media_store.dart';
import '../../data/database.dart';
import '../../services/question_selector.dart';
import '../../data/question_usage_dao.dart';
import '../widgets/capture/text_input_capture.dart';
import '../widgets/capture/audio_input_capture.dart';
import '../widgets/capture/photo_input_capture.dart';
import '../widgets/capture/video_input_capture.dart';
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

  Future<void> _saveResponse() async {
    String? filePath;

    switch (widget.mediaType) {
      case MediaType.text:
        final text = _textController.text.trim();
        if (text.isEmpty) return;

        final responseId = const Uuid().v4();
        final now = DateTime.now();

        setState(() {
          _saving = true;
        });

        filePath = await MediaStore.writeText(
          responseId: responseId,
          content: text,
        );

        final entry = ResponseEntry(
          id: responseId,
          questionId: widget.question.id,
          createdAt: now,
          mediaType: widget.mediaType.name,
          durationSeconds: null,
          filePath: filePath,
        );

        final db = await AppDatabase.instance;
        await db.insert('responses', entry.toMap());
        await QuestionUsageDao.recordAnswer(widget.question.id);

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) =>
                SubmissionRitualScreen(mediaType: widget.mediaType.name),
          ),
        );
        break;

      case MediaType.audio:
        if (_mediaFilePath == null) return;

        final responseId = const Uuid().v4();
        final now = DateTime.now();

        setState(() {
          _saving = true;
        });

        final entry = ResponseEntry(
          id: responseId,
          questionId: widget.question.id,
          createdAt: now,
          mediaType: widget.mediaType.name,
          durationSeconds: _durationSeconds,
          filePath: _mediaFilePath!,
        );

        final db = await AppDatabase.instance;
        await db.insert('responses', entry.toMap());
        await QuestionUsageDao.recordAnswer(widget.question.id);

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) =>
                SubmissionRitualScreen(mediaType: widget.mediaType.name),
          ),
        );
        break;

      case MediaType.image:
        if (_mediaFilePath == null) return;

        final responseId = const Uuid().v4();
        final now = DateTime.now();

        setState(() {
          _saving = true;
        });

        final entry = ResponseEntry(
          id: responseId,
          questionId: widget.question.id,
          createdAt: now,
          mediaType: widget.mediaType.name,
          durationSeconds: null,
          filePath: _mediaFilePath!,
        );

        final db = await AppDatabase.instance;
        await db.insert('responses', entry.toMap());
        await QuestionUsageDao.recordAnswer(widget.question.id);

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) =>
                SubmissionRitualScreen(mediaType: widget.mediaType.name),
          ),
        );
        break;
      case MediaType.video:
        if (_mediaFilePath == null) return;

        final responseId = const Uuid().v4();
        final now = DateTime.now();

        setState(() {
          _saving = true;
        });

        final entry = ResponseEntry(
          id: responseId,
          questionId: widget.question.id,
          createdAt: now,
          mediaType: widget.mediaType.name,
          durationSeconds: null,
          filePath: _mediaFilePath!,
        );

        final db = await AppDatabase.instance;
        await db.insert('responses', entry.toMap());
        await QuestionUsageDao.recordAnswer(widget.question.id);

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) =>
                SubmissionRitualScreen(mediaType: widget.mediaType.name),
          ),
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Capturar respuesta'),
        trailing: _saving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveResponse,
                child: const Text('Guardar'),
              ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildCaptureWidget(),
        ),
      ),
    );
  }
}
