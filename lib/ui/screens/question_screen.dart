import 'dart:io';

import 'package:Keifu/services/backup_service.dart';
import 'package:Keifu/services/drive_backup_service.dart';
import 'package:flutter/cupertino.dart';

import '../../services/question_selector.dart';
import '../widgets/large_text.dart';
import '../widgets/big_button.dart';
import 'capture_screen.dart';
import 'responses_archive_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late Future<SelectedQuestion?> _questionFuture;

  @override
  void initState() {
    super.initState();
    _questionFuture = QuestionSelector.next();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('KeifuKi')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder<SelectedQuestion?>(
                future: _questionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CupertinoActivityIndicator();
                  } else if (snapshot.hasData) {
                    if (snapshot.data != null) {
                      return LargeText(snapshot.data!.text);
                    } else {
                      return const LargeText(
                        'No hay preguntas disponibles por ahora.',
                      );
                    }
                  } else {
                    return const LargeText('Error loading question');
                  }
                },
              ),
              Column(
                children: [
                  FutureBuilder<SelectedQuestion?>(
                    future: _questionFuture,
                    builder: (context, snapshot) {
                      return BigButton(
                        label: 'Responder',
                        onPressed: (snapshot.hasData && snapshot.data != null)
                            ? () async {
                                await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) =>
                                        CaptureScreen(question: snapshot.data!),
                                  ),
                                );
                                setState(() {
                                  _questionFuture = QuestionSelector.next();
                                });
                              }
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Respuestas anteriores',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => const ResponsesArchiveScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Respaldar en Google Drive',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                    onPressed: () async {
                      try {
                        final path = await BackupService.createSnapshot();
                        await DriveBackupService.uploadSnapshot(File(path));

                        if (!context.mounted) return;

                        showCupertinoDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text('Respaldo completado'),
                            content: const Text(
                              'Tu memoria fue guardada en Google Drive.',
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('Aceptar'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        // Manejo sobrio de error / cancelación
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
