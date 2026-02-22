import 'package:flutter/cupertino.dart';

import '../../data/response_dao.dart';
import '../../data/system_state_dao.dart';
import '../../domain/tree_projection.dart';
import '../../services/question_selector.dart';
import '../../services/tree_projection_service.dart';
import '../painters/procedural_tree_painter.dart';
import '../widgets/big_button.dart';
import 'backup_ritual_screen.dart';
import 'capture_screen.dart';
import 'responses_archive_screen.dart';

class _TreeHomeViewModel {
  final TreeProjection projection;
  final SelectedQuestion? nextQuestion;

  const _TreeHomeViewModel({
    required this.projection,
    required this.nextQuestion,
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
    );
  }

  Future<void> _refresh() async {
    final next = _load();
    if (!mounted) return;
    setState(() {
      _future = next;
    });
  }

  String _formatLastWatered(DateTime? value) {
    if (value == null) return 'Aún no regado';
    final d = value;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} ${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  BoxDecoration _backgroundForVitality(double vitality) {
    final clamped = vitality.clamp(0.0, 1.0);

    final top = Color.lerp(
      const Color(0xFFEFF5EE),
      const Color(0xFFDFF0DF),
      clamped,
    )!;
    final mid = Color.lerp(
      const Color(0xFFE8EFE8),
      const Color(0xFFD3E8D3),
      clamped,
    )!;
    final bottom = Color.lerp(
      const Color(0xFFE2DDD6),
      const Color(0xFFDBD4C7),
      clamped,
    )!;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, mid, bottom],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('KeifuKi')),
      child: SafeArea(
        child: FutureBuilder<_TreeHomeViewModel>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final vm = snapshot.data!;
            final projection = vm.projection;

            return Container(
              decoration: _backgroundForVitality(projection.vitality),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 360,
                      child: CustomPaint(
                        painter: ProceduralTreePainter(
                          growthSeed: projection.growthSeed,
                          growthRatio: projection.growthRatio,
                          vitality: projection.vitality,
                          structuralMarkers: projection.structuralMarkers,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      projection.identityName != null
                          ? 'Árbol de ${projection.identityName}'
                          : 'Semilla en reposo',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CupertinoListSection.insetGrouped(
                      children: [
                        CupertinoListTile(
                          title: const Text('Crecimiento'),
                          trailing: Text(
                            '${(projection.growthRatio * 100).toStringAsFixed(1)}%',
                          ),
                        ),
                        CupertinoListTile(
                          title: const Text('Vitalidad'),
                          trailing: Text(
                            '${projection.vitalityLabel} '
                            '(${(projection.vitality * 100).toStringAsFixed(0)}%)',
                          ),
                        ),
                        CupertinoListTile(
                          title: const Text('Marcadores estructurales'),
                          trailing: Text(
                            '${projection.structuralMarkers.length}',
                          ),
                        ),
                        CupertinoListTile(
                          title: const Text('Frutos disponibles'),
                          trailing: Text(
                            '${projection.availableFruits.length}',
                          ),
                        ),
                        CupertinoListTile(
                          title: const Text('Último riego'),
                          subtitle: Text(
                            _formatLastWatered(projection.lastWateredAt),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (vm.nextQuestion != null)
                      Text(
                        vm.nextQuestion!.text,
                        style: const TextStyle(fontSize: 18),
                      )
                    else
                      const Text('No hay preguntas disponibles por ahora.'),
                    const SizedBox(height: 14),
                    BigButton(
                      label: 'Responder ahora',
                      onPressed: vm.nextQuestion == null
                          ? null
                          : () async {
                              await Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) =>
                                      CaptureScreen(question: vm.nextQuestion!),
                                ),
                              );
                              await _refresh();
                            },
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const ResponsesArchiveScreen(),
                          ),
                        );
                        await _refresh();
                      },
                      child: const Text('Abrir archivo de respuestas'),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const BackupRitualScreen(),
                          ),
                        );
                      },
                      child: const Text('Respaldar en Google Drive'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
