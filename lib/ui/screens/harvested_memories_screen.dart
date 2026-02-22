import 'package:flutter/cupertino.dart';

import '../../data/harvested_memory_dao.dart';
import '../../domain/response.dart';
import '../../domain/question_registry.dart';
import 'response_viewer_screen.dart';

class HarvestedMemoriesScreen extends StatelessWidget {
  const HarvestedMemoriesScreen({super.key});

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
                'Canasta de frutos',
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
                future: HarvestedMemoryDao.fetchHarvestedResponses(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final responses = snapshot.data!;
                  if (responses.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aún no has recogido frutos.',
                        style: TextStyle(
                          color: Color(0xFFE5F0FF),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                    itemCount: responses.length,
                    itemBuilder: (context, index) {
                      final entry = responses[index];
                      final title =
                          QuestionRegistry.byId[entry.questionId]?.text ??
                          'Pregunta no disponible';

                      return Padding(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
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
                      );
                    },
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
