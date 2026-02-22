import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../data/harvested_memory_dao.dart';
import '../../data/response_dao.dart';
import '../../data/system_state_dao.dart';
import '../../domain/response.dart';
import '../../domain/tree_projection.dart';
import '../../services/notification_service.dart';
import '../../services/question_selector.dart';
import '../../services/tree_projection_service.dart';
import '../painters/procedural_tree_painter.dart';
import '../painters/time_sky_painter.dart';
import '../painters/tree_environment_painter.dart';
import '../widgets/question_overlay.dart';
import 'backup_ritual_screen.dart';
import 'capture_screen.dart';
import 'harvested_memories_screen.dart';
import 'response_viewer_screen.dart';
import 'responses_archive_screen.dart';

class _TreeHomeViewModel {
  final TreeProjection projection;
  final SelectedQuestion? nextQuestion;
  final List<ResponseEntry> responses;
  final int harvestedCount;

  const _TreeHomeViewModel({
    required this.projection,
    required this.nextQuestion,
    required this.responses,
    required this.harvestedCount,
  });
}

class TreeHomeScreen extends StatefulWidget {
  const TreeHomeScreen({super.key});

  @override
  State<TreeHomeScreen> createState() => _TreeHomeScreenState();
}

class _TreeHomeScreenState extends State<TreeHomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<_TreeHomeViewModel> _future;
  Timer? _clockTimer;
  late final AnimationController _windController;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _future = _load();
    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _windController.dispose();
    super.dispose();
  }

  Future<_TreeHomeViewModel> _load() async {
    final treeState = await SystemStateDao.ensureTreeState();
    final responses = await ResponseDao.fetchAll();

    final harvestedIds = await HarvestedMemoryDao.fetchHarvestedResponseIds();
    final harvestedCount = harvestedIds.length;

    final projection = TreeProjectionService.project(
      treeState: treeState,
      responses: responses,
      harvestedResponseIds: harvestedIds,
      harvestedCount: harvestedCount,
      now: DateTime.now(),
    );
    final nextQuestion = await QuestionSelector.next();

    await NotificationService.refreshWateringReminder(
      lastWateredAt: projection.lastWateredAt,
      identityName: projection.identityName,
    );

    return _TreeHomeViewModel(
      projection: projection,
      nextQuestion: nextQuestion,
      responses: responses,
      harvestedCount: harvestedCount,
    );
  }

  Future<void> _refresh() async {
    final next = _load();
    if (!mounted) return;
    setState(() {
      _future = next;
      _now = DateTime.now();
    });
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'No disponible';
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  String _timeSinceHHMM(DateTime? value) {
    if (value == null) return '00:00';

    final diff = DateTime.now().difference(value);
    final totalMinutes = diff.isNegative ? 0 : diff.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
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
              style: const TextStyle(
                fontSize: 17,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              child: Column(
                children: [
                  Text('Plantado: ${_formatDate(projection.plantedAt)}'),
                  const SizedBox(height: 8),
                  Text(
                    'Nivel de crecimiento: ${(projection.growthRatio * 100).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 8),
                  Text('Vitalidad: ${projection.vitalityLabel}'),
                  const SizedBox(height: 8),
                  Text(
                    'Último riego: Hace ${_timeSinceHHMM(projection.lastWateredAt)} horas',
                  ),
                  const SizedBox(height: 8),
                  Text('Frutos recogidos: ${vm.harvestedCount}'),
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
              child: const Text('Archivo completo'),
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

    await HarvestedMemoryDao.markHarvested(
      responseId: responseId,
      harvestedAt: DateTime.now(),
    );

    if (!mounted) return;
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ResponseViewerScreen(response: response!),
      ),
    );
    await _refresh();
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
                      child: CustomPaint(painter: TimeSkyPainter(now: _now)),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: constraints.maxHeight * 0.11,
                              child: Opacity(
                                opacity: 0.9,
                                child: Image.asset(
                                  'assets/toluca.png', // No actualizar a JPG. Esta ruta es correcta.
                                  width: constraints.maxWidth,
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment.bottomCenter,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TreeGroundPainter(
                          vitality: projection.vitality,
                          soilMoistureLevel: projection.soilMoistureLevel,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _windController,
                        builder: (context, child) {
                          final eased = Curves.easeInOut.transform(
                            _windController.value,
                          );
                          final centered = (eased * 2) - 1; // -1..1
                          final phase = _windController.value * 2 * math.pi;

                          // Primary sway + tiny harmonic that closes the loop.
                          final swayX =
                              (centered * 4.2) + (math.sin(phase * 2) * 0.6);
                          final swayAngle =
                              (centered * 0.012) +
                              (math.sin(phase * 2) * 0.0018);
                          final wateringAgeSeconds =
                              projection.lastWateredAt == null
                              ? double.infinity
                              : DateTime.now()
                                        .difference(projection.lastWateredAt!)
                                        .inMilliseconds /
                                    1000.0;
                          final isRecentWatering = wateringAgeSeconds <= 90;
                          final wateringDecay = isRecentWatering
                              ? (1 - (wateringAgeSeconds / 90)).clamp(0.0, 1.0)
                              : 0.0;

                          double growthPulseScale = 1.0;
                          double lowCapacityWaveY = 0.0;
                          if (isRecentWatering &&
                              projection.lastAbsorptionAtWatering > 0.7) {
                            growthPulseScale +=
                                math.sin(phase * 3).abs() *
                                0.017 *
                                wateringDecay;
                          } else if (isRecentWatering &&
                              projection.lastAbsorptionAtWatering < 0.3) {
                            lowCapacityWaveY =
                                math.sin(phase * 3) * 1.8 * wateringDecay;
                          }

                          return Transform.translate(
                            offset: Offset(swayX, lowCapacityWaveY),
                            child: Transform.scale(
                              scale: growthPulseScale,
                              alignment: Alignment.bottomCenter,
                              child: Transform.rotate(
                                angle: swayAngle,
                                alignment: Alignment.bottomCenter,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: ProceduralTreePainter(
                                  growthSeed: projection.growthSeed,
                                  growthRatio: projection.growthRatio,
                                  vitality: projection.vitality,
                                  absorptionCapacity:
                                      projection.absorptionCapacity,
                                  fruits: projection.availableFruits,
                                ),
                              ),
                            ),
                            for (final fruit in fruitPlacements)
                              Positioned(
                                left: fruit.center.dx - 24,
                                top: fruit.center.dy - 24,
                                width: 48,
                                height: 48,
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
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 18,
                      left: 16,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        minimumSize: const Size(52, 52),
                        color: const Color(0xC0182D4A),
                        borderRadius: BorderRadius.circular(22),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => const HarvestedMemoriesScreen(),
                            ),
                          );
                          await _refresh();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🧺', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 6),
                            Text(
                              '${vm.harvestedCount}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF4FAFF),
                              ),
                            ),
                          ],
                        ),
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
                      child: Opacity(
                        opacity: 0.55 + (projection.absorptionCapacity * 0.45),
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          minimumSize: const Size(52, 52),
                          color: Color.lerp(
                            const Color(0xA03A3C3D),
                            const Color(0xDD2E6A52),
                            projection.absorptionCapacity.clamp(0.0, 1.0),
                          ),
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
                              const Text('🚿', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text(
                                'Responder',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color.lerp(
                                    const Color(0x99E9F3FF),
                                    const Color(0xFFE9F3FF),
                                    projection.absorptionCapacity.clamp(
                                      0.0,
                                      1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
