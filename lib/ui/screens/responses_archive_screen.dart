import 'package:flutter/cupertino.dart';
import '../../domain/response.dart';
import '../../data/response_dao.dart';
import '../../domain/question_registry.dart';
import 'response_viewer_screen.dart';

class ResponsesArchiveScreen extends StatefulWidget {
  const ResponsesArchiveScreen({super.key});

  @override
  State<ResponsesArchiveScreen> createState() => _ResponsesArchiveScreenState();
}

class _ResponsesArchiveScreenState extends State<ResponsesArchiveScreen> {
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
      navigationBar: const CupertinoNavigationBar(middle: Text('Archivo')),
      child: SafeArea(
        child: FutureBuilder<List<ResponseEntry>>(
          future: ResponseDao.fetchAll(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final responses = snapshot.data!;
            if (responses.isEmpty) {
              return const Center(
                child: Text(
                  'Aún no hay respuestas guardadas.',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
              );
            }

            return CupertinoListSection.insetGrouped(
              children: responses.map((entry) {
                String titleText = QuestionRegistry.byId[entry.questionId]?.text ?? "Pregunta no disponible...";
                TextStyle titleStyle = const TextStyle(fontSize: 16);

                return CupertinoListTile(
                  leading: Icon(
                    _iconForMediaType(entry.mediaType),
                    color: CupertinoColors.systemGrey,
                  ),
                  title: Text(titleText, style: titleStyle),
                  subtitle: Text(
                    _formatDate(entry.createdAt),
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => ResponseViewerScreen(response: entry),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
