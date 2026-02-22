import 'package:flutter/cupertino.dart';

import '../../data/response_dao.dart';
import '../../data/system_state_dao.dart';
import '../../domain/response.dart';
import '../../domain/tree_projection.dart';
import '../../services/question_selector.dart';
import '../../services/tree_projection_service.dart';
import '../painters/procedural_tree_painter.dart';
import '../painters/tree_environment_painter.dart';
import '../widgets/question_overlay.dart';
import 'backup_ritual_screen.dart';
import 'capture_screen.dart';
import 'response_viewer_screen.dart';
import 'responses_archive_screen.dart';

class _TreeHomeViewModel {
  final TreeProjection projection;
  final SelectedQuestion? nextQuestion;
  final List<ResponseEntry> responses;

  const _TreeHomeViewModel({
    required this.projection,
    required this.nextQuestion,
    required this.responses,
  });
}

class TreeHomeScreen extends StatefulWidget {
  const TreeHomeScreen({super.key});

  @override
  State<TreeHomeScreen> createState() => _TreeHomeScreenState();
}

class _TreeHomeScreenState extends State<TreeHomeScreen> {
  late Future<_TreeHomeViewModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TreeHomeViewModel> _load() async {
    final treeState = await SystemStateDao.ensureTreeState();
    final responses = await ResponseDao.fetchAll();
    final projection = TreeProjectionService.project(
      treeState: treeState,
      responses: responses,
      now: DateTime.now(),
    );
    final nextQuestion = await QuestionSelector.next();

    return _TreeHomeViewModel(
      projection: projection,
      nextQuestion: nextQuestion,
      responses: responses,
    );
  }

  Future<void> _refresh() async {
    final next = _load();
    if (!mounted) return;
    setState(() {
      _future = next;
    });
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'No disponible';
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  int _daysSince(DateTime? value) {
    if (value == null) return 0;
    return DateTime.now().difference(value).inDays;
  }

  Future<void> _openInfo(_TreeHomeViewModel vm) async {
    final projection = vm.projection;

    await showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Información del árbol'),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 17, color: Color.fromARGB(255, 255, 255, 255)),
              child: Column(
                children: [
                  Text('Plantado: ${_formatDate(projection.plantedAt)}'),
                  const SizedBox(height: 8),
                  Text(
                    'Crecimiento: ${(projection.growthRatio * 100).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 8),
                  Text('Vitalidad: ${projection.vitalityLabel}'),
                  const SizedBox(height: 8),
                  Text(
                    'Días desde último riego: ${_daysSince(projection.lastWateredAt)}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Marcadores estructurales: ${projection.structuralMarkers.length}',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () async {
                Navigator.of(context).pop();
                await Navigator.of(this.context).push(
                  CupertinoPageRoute(
                    builder: (_) => const ResponsesArchiveScreen(),
                  ),
                );
                await _refresh();
              },
              child: const Text('Abrir archivo completo'),
            ),
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

  Future<void> _openFruitResponse({
    required _TreeHomeViewModel vm,
    required String responseId,
  }) async {
    ResponseEntry? response;
    for (final entry in vm.responses) {
      if (entry.id == responseId) {
        response = entry;
        break;
      }
    }

    if (response == null) return;

    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ResponseViewerScreen(response: response!),
      ),
    );
    await _refresh();
  }

  BoxDecoration _skyBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.38, 0.74, 1.0],
        colors: [
          Color(0xFF080D1F),
          Color(0xFF132A67),
          Color(0xFF1D3A2E),
          Color(0xFF2A2E1A),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: FutureBuilder<_TreeHomeViewModel>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final vm = snapshot.data!;
            final projection = vm.projection;
            final questionText =
                vm.nextQuestion?.text ??
                'No hay preguntas disponibles por ahora.';

            return LayoutBuilder(
              builder: (context, constraints) {
                final treeSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                final fruitPlacements =
                    ProceduralTreePainter.computeFruitPlacements(
                      growthSeed: projection.growthSeed,
                      growthRatio: projection.growthRatio,
                      vitality: projection.vitality,
                      fruits: projection.availableFruits,
                      size: treeSize,
                    );

                return Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(decoration: _skyBackground()),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TreeGroundPainter(
                          vitality: projection.vitality,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ProceduralTreePainter(
                          growthSeed: projection.growthSeed,
                          growthRatio: projection.growthRatio,
                          vitality: projection.vitality,
                          fruits: projection.availableFruits,
                        ),
                      ),
                    ),
                    for (final fruit in fruitPlacements)
                      Positioned(
                        left: fruit.center.dx - 22,
                        top: fruit.center.dy - 22,
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            await _openFruitResponse(
                              vm: vm,
                              responseId: fruit.responseId,
                            );
                          },
                          child: const SizedBox.expand(),
                        ),
                      ),
                    Positioned(
                      top: 18,
                      right: 16,
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(12),
                        minimumSize: const Size(52, 52),
                        color: const Color(0xCC10213D),
                        borderRadius: BorderRadius.circular(26),
                        onPressed: () => _openInfo(vm),
                        child: const Icon(
                          CupertinoIcons.info,
                          color: Color(0xFFF5FAFF),
                          size: 28,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 16,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        minimumSize: const Size(52, 52),
                        color: const Color(0xAA1B2F22),
                        borderRadius: BorderRadius.circular(20),
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => const BackupRitualScreen(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🪏', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 8),
                            Text(
                              'Respaldo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF5FAFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 24,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        minimumSize: const Size(52, 52),
                        color: const Color(0xDD2E4E3E),
                        borderRadius: BorderRadius.circular(20),
                        onPressed: vm.nextQuestion == null
                            ? null
                            : () async {
                                await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => CaptureScreen(
                                      question: vm.nextQuestion!,
                                    ),
                                  ),
                                );
                                await _refresh();
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🚿', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 8),
                            Text(
                              'Responder',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF5FAFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    QuestionOverlay(text: questionText),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
