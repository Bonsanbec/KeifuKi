import 'package:sqflite/sqflite.dart';

import 'database.dart';
import '../domain/response.dart';

class ResponseDao {
  static Future<void> insert(ResponseEntry response) async {
    final Database db = await AppDatabase.instance;

    await db.insert(
      'responses',
      response.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<List<ResponseEntry>> fetchAll() async {
    final Database db = await AppDatabase.instance;

    final rows = await db.query(
      'responses',
      orderBy: 'created_at ASC',
    );

    return rows.map(ResponseEntry.fromMap).toList();
  }

  static Future<List<ResponseEntry>> fetchByQuestionId(String questionId) async {
    final Database db = await AppDatabase.instance;

    final rows = await db.query(
      'responses',
      where: 'question_id = ?',
      whereArgs: [questionId],
      orderBy: 'created_at ASC',
    );

    return rows.map(ResponseEntry.fromMap).toList();
  }
}