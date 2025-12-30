import 'dart:async';
import 'package:flutter/cupertino.dart';

class SubmissionRitualScreen extends StatefulWidget {
  final String mediaType;

  const SubmissionRitualScreen({
    super.key,
    required this.mediaType,
  });

  @override
  State<SubmissionRitualScreen> createState() => _SubmissionRitualScreenState();
}

class _SubmissionRitualScreenState extends State<SubmissionRitualScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _offset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _iconForMediaType() {
    switch (widget.mediaType) {
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

  String _thankYouText() {
    switch (widget.mediaType) {
      case 'audio':
        return 'Gracias por tu voz.';
      case 'photo':
        return 'Gracias por esta imagen.';
      case 'video':
        return 'Gracias por este recuerdo.';
      case 'text':
      default:
        return 'Gracias por tus palabras.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _offset,
                child: FadeTransition(
                  opacity: _opacity,
                  child: Icon(
                    _iconForMediaType(),
                    size: 96,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _thankYouText(),
                style: const TextStyle(
                  fontSize: 20,
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