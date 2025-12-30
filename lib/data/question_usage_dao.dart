import 'package:sqflite/sqflite.dart';

import 'database.dart';
import '../services/question_selector.dart';

class QuestionUsageDao {
  static Future<Map<String, QuestionUsage>> fetchAll() async {
    final Database db = await AppDatabase.instance;

    final rows = await db.query('question_usage');

    final Map<String, QuestionUsage> result = {};

    for (final row in rows) {
      final questionId = row['question_id'] as String;
      result[questionId] = QuestionUsage(
        questionId: questionId,
        timesAnswered: row['times_answered'] as int,
        lastAnsweredAt: row['last_answered_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                row['last_answered_at'] as int,
              )
            : null,
      );
    }

    return result;
  }

  static Future<void> recordAnswer(String questionId) async {
    final Database db = await AppDatabase.instance;

    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      final existing = await txn.query(
        'question_usage',
        where: 'question_id = ?',
        whereArgs: [questionId],
      );

      if (existing.isEmpty) {
        await txn.insert('question_usage', {
          'question_id': questionId,
          'times_answered': 1,
          'last_answered_at': now,
        });
      } else {
        final current = existing.first;
        await txn.update(
          'question_usage',
          {
            'times_answered': (current['times_answered'] as int) + 1,
            'last_answered_at': now,
          },
          where: 'question_id = ?',
          whereArgs: [questionId],
        );
      }
    });
  }
}