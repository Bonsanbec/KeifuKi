import 'package:flutter/cupertino.dart';

import '../../domain/enums.dart';
import '../../services/question_selector.dart';
import '../widgets/big_button.dart';
import 'input_capture_screen.dart';

class CaptureScreen extends StatelessWidget {
  final SelectedQuestion question;
  const CaptureScreen({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Responder')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BigButton(
                  label: 'Escribir ✍️',
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
                const SizedBox(height: 20),
                BigButton(
                  label: 'Grabar audio 🎙️',
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
                const SizedBox(height: 20),
                BigButton(
                  label: 'Tomar foto 📷',
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
                const SizedBox(height: 20),
                BigButton(
                  label: 'Grabar video 🎥',
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
            ),
          ),
        ),
      ),
    );
  }
}
