import 'package:flutter/cupertino.dart';

import '../../data/response_dao.dart';
import '../../services/app_data_runtime.dart';
import '../../services/snapshot_service.dart';
import '../../domain/question_registry.dart';
import '../../domain/response.dart';
import 'tree_home_screen.dart';
import 'response_viewer_screen.dart';

class ResponsesArchiveScreen extends StatefulWidget {
  const ResponsesArchiveScreen({super.key});

  @override
  State<ResponsesArchiveScreen> createState() => _ResponsesArchiveScreenState();
}

class _ResponsesArchiveScreenState extends State<ResponsesArchiveScreen> {
  bool get _isReadOnlyMode => AppDataRuntime.isReadOnlySync();

  IconData _iconForMediaType(String mediaType) {
    switch (mediaType) {
      case 'audio':
        return CupertinoIcons.mic;
      case 'image':
        return CupertinoIcons.photo;
      case 'video':
        return CupertinoIcons.film;
      case 'text':
      default:
        return CupertinoIcons.pencil;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} · '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openBackupViewer() async {
    final selection = await SnapshotService.pickSnapshotZip();
    if (selection == null || !mounted) return;

    _showBlockingProgress('Abriendo respaldo…');

    SnapshotPackage? snapshot;
    final AppDataSource previousSource = await AppDataRuntime.currentSource();

    try {
      snapshot = await SnapshotService.extractSnapshot(selection.zipPath);
      await AppDataRuntime.switchTo(snapshot.toViewerDataSource());
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await Navigator.of(
        context,
      ).push(CupertinoPageRoute(builder: (_) => const TreeHomeScreen()));
    } on SnapshotFormatException catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        await _showMessage(title: 'Archivo inválido', message: error.message);
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        await _showMessage(
          title: 'No pudimos abrir el respaldo',
          message: 'Revisa el archivo e inténtalo de nuevo.',
        );
      }
    } finally {
      await AppDataRuntime.switchTo(previousSource);
      if (snapshot != null && await snapshot.rootDirectory.exists()) {
        await snapshot.rootDirectory.delete(recursive: true);
      }
    }
  }

  Future<void> _replaceDataFromFile() async {
    final selection = await SnapshotService.pickSnapshotZip();
    if (selection == null || !mounted) return;

    final bool confirmed = await _confirmReplaceData();
    if (!confirmed || !mounted) return;

    _showBlockingProgress('Reemplazando datos…');

    try {
      await SnapshotService.importSnapshot(selection.zipPath);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {});
      await _showMessage(
        title: 'Datos reemplazados',
        message: 'La memoria actual fue reemplazada con el archivo elegido.',
      );
    } on SnapshotFormatException catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        await _showMessage(title: 'Archivo inválido', message: error.message);
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        await _showMessage(
          title: 'No pudimos reemplazar los datos',
          message:
              'La memoria actual se conservó y puedes intentarlo nuevamente.',
        );
      }
    }
  }

  void _showBlockingProgress(String message) {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                const CupertinoActivityIndicator(radius: 14),
                const SizedBox(height: 14),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmReplaceData() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Reemplazar datos'),
          content: const Text(
            'Esto borrará la memoria actual y la cambiará por la del archivo elegido.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reemplazar'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _showMessage({required String title, required String message}) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
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
            const Positioned(
              top: 68,
              left: 20,
              right: 20,
              child: Text(
                'Archivo completo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF4FAFF),
                  shadows: [
                    Shadow(
                      color: Color(0xCC000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              top: 130,
              child: FutureBuilder<List<ResponseEntry>>(
                future: ResponseDao.fetchAll(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final responses = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                    children: [
                      if (responses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40, bottom: 28),
                          child: Center(
                            child: Text(
                              'Aún no hay respuestas guardadas.',
                              style: TextStyle(
                                color: Color(0xFFE5F0FF),
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      for (final entry in responses)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CupertinoButton(
                            color: const Color(0x9E0D1A2D),
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) =>
                                      ResponseViewerScreen(response: entry),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  _iconForMediaType(entry.mediaType),
                                  color: const Color(0xFFEAF4FF),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        QuestionRegistry
                                                .byId[entry.questionId]
                                                ?.text ??
                                            'Pregunta no disponible',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFF2F8FF),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(entry.createdAt),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFD6E6FF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!_isReadOnlyMode) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                          decoration: BoxDecoration(
                            color: const Color(0x5E0D1A2D),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0x335D7FA8)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                '¿Tienes un archivo de memoria?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF1F8FF),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Puedes explorar el archivo de un conocido o usar uno propio para recuperar tu memoria.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.35,
                                  color: Color(0xFFD4E5FF),
                                ),
                              ),
                              const SizedBox(height: 14),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                color: const Color(0x8030476B),
                                borderRadius: BorderRadius.circular(14),
                                onPressed: _openBackupViewer,
                                child: const Text(
                                  'Explorar archivo de memoria',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF3F9FF),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                color: const Color(0x553F2430),
                                borderRadius: BorderRadius.circular(14),
                                onPressed: _replaceDataFromFile,
                                child: const Text(
                                  'Reemplazar datos con archivo de memoria',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF3F9FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
