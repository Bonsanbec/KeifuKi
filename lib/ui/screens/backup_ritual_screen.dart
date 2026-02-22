import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../services/backup_service.dart';
import '../../services/drive_backup_service.dart';

class BackupRitualScreen extends StatefulWidget {
  const BackupRitualScreen({super.key});

  @override
  State<BackupRitualScreen> createState() => _BackupRitualScreenState();
}

class _BackupRitualScreenState extends State<BackupRitualScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _offset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startBackup();
  }

  Future<void> _startBackup() async {
    try {
      // Comienza animación (recoger manzana)
      _controller.forward();

      final snapshotPath = await BackupService.createSnapshot();
      await DriveBackupService.uploadSnapshot(File(snapshotPath));
    } catch (_) {
      // Fallo silencioso: el ritual igualmente concluye
    } finally {
      // Dejar que la animación concluya antes de salir
      Timer(const Duration(milliseconds: 2600), () {
        if (!mounted) return;

        Navigator.of(context).pop();

        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Respaldo completado'),
            content: const Text('Hemos respaldado tus recuerdos.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Aceptar'),
                onPressed: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Respaldo'),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _offset,
                child: FadeTransition(
                  opacity: _opacity,
                  child: Column(
                    children: const [
                      Icon(
                        CupertinoIcons.tree,
                        size: 72,
                        color: CupertinoColors.systemRed,
                      ),
                      SizedBox(height: 12),
                      Icon(
                        CupertinoIcons.shopping_cart,
                        size: 64,
                        color: CupertinoColors.systemGrey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Guardando recuerdos…',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
