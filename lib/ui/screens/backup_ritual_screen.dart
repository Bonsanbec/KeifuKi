import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../services/backup_service.dart';
import '../../services/drive_backup_service.dart';
import '../painters/time_sky_painter.dart';
import '../painters/tree_environment_painter.dart';

class BackupRitualScreen extends StatefulWidget {
  const BackupRitualScreen({super.key});

  @override
  State<BackupRitualScreen> createState() => _BackupRitualScreenState();
}

class _BackupRitualScreenState extends State<BackupRitualScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _progress = 0.0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _startBackup();
  }

  Future<void> _startBackup() async {
    bool success = true;

    try {
      final snapshotPath = await BackupService.createSnapshot(
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _progress = progress.clamp(0.0, 0.9);
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _progress = 0.93;
      });

      await DriveBackupService.uploadSnapshot(File(snapshotPath));

      if (!mounted) return;
      setState(() {
        _progress = 1.0;
      });
    } catch (_) {
      success = false;
      if (!mounted) return;
      setState(() {
        _progress = 1.0;
      });
    }

    if (!mounted) return;
    setState(() {
      _completed = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    await showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(success ? 'Semilla respaldada' : 'Respaldo incompleto'),
          content: Text(
            success
                ? 'La memoria de tu árbol quedó protegida en la nube.'
                : 'No pudimos terminar el respaldo. Puedes intentarlo de nuevo.',
          ),
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

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: TimeSkyPainter(now: now)),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: TreeGroundPainter(vitality: _completed ? 0.92 : 0.65),
              ),
            ),
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Text(
                _completed ? 'Respaldo completado' : 'Plantando respaldo',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF5FAFF),
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
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value;
                    final shovelOffset = (_completed ? 0.0 : (t - 0.5) * 16);
                    final seedDrop = (_progress * 120).clamp(0, 120).toDouble();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: Offset(0, shovelOffset),
                          child: const Text(
                            '🪏',
                            style: TextStyle(fontSize: 76),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Transform.translate(
                          offset: Offset(0, seedDrop),
                          child: const Text(
                            '🌰',
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          _completed
                              ? 'Tus recuerdos quedaron protegidos.'
                              : 'Guardando recuerdos en la tierra digital…',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF1F8FF),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 42,
              child: Column(
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0x6625344D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF63D18E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF4FAFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
