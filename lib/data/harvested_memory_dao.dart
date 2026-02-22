import 'package:sqflite/sqflite.dart';

import '../domain/response.dart';
import 'database.dart';

class HarvestedMemoryDao {
  static Future<void> markHarvested({
    required String responseId,
    required DateTime harvestedAt,
  }) async {
    final Database db = await AppDatabase.instance;

    await db.insert('harvested_memories', {
      'response_id': responseId,
      'harvested_at': harvestedAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<Set<String>> fetchHarvestedResponseIds() async {
    final Database db = await AppDatabase.instance;

    final rows = await db.query('harvested_memories');
    return rows.map((row) => row['response_id'] as String).toSet();
  }

  static Future<int> countHarvested() async {
    final Database db = await AppDatabase.instance;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM harvested_memories',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  static Future<List<ResponseEntry>> fetchHarvestedResponses() async {
    final Database db = await AppDatabase.instance;

    final rows = await db.rawQuery('''
      SELECT r.*
      FROM harvested_memories h
      INNER JOIN responses r ON r.id = h.response_id
      ORDER BY h.harvested_at DESC
    ''');

    return rows
        .map((row) => ResponseEntry.fromMap(row))
        .toList(growable: false);
  }
}
