import 'package:flutter/cupertino.dart';

import '../../domain/enums.dart';
import '../../domain/question_registry.dart';
import '../../services/question_selector.dart';
import '../widgets/big_button.dart';
import '../widgets/question_overlay.dart';
import 'input_capture_screen.dart';

class CaptureScreen extends StatelessWidget {
  final SelectedQuestion question;
  const CaptureScreen({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final isIdentityQuestion =
        question.id == QuestionRegistry.identityQuestionId;

    return CupertinoPageScaffold(
      child: SafeArea(
        top: false,
        bottom: false,
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
              left: 24,
              right: 24,
              top: 220,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BigButton(
                    label: 'Escribir',
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => InputCaptureScreen(
                            mediaType: MediaType.text,
                            question: question,
                          ),
                        ),
                      );
                    },
                  ),
                  if (!isIdentityQuestion) ...[
                    const SizedBox(height: 16),
                    BigButton(
                      label: 'Grabar audio',
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => InputCaptureScreen(
                              mediaType: MediaType.audio,
                              question: question,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BigButton(
                      label: 'Tomar foto',
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => InputCaptureScreen(
                              mediaType: MediaType.image,
                              question: question,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BigButton(
                      label: 'Grabar video',
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => InputCaptureScreen(
                              mediaType: MediaType.video,
                              question: question,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            QuestionOverlay(text: question.text),
          ],
        ),
      ),
    );
  }
}
