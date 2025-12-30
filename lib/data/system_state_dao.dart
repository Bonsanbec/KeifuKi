import 'package:sqflite/sqflite.dart';

import 'database.dart';

class SystemStateDao {
  static Future<String?> get(String key) async {
    final Database db = await AppDatabase.instance;

    final rows = await db.query(
      'system_state',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  static Future<void> set(String key, String value) async {
    final Database db = await AppDatabase.instance;

    await db.insert(
      'system_state',
      {
        'key': key,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<DateTime?> getDateTime(String key) async {
    final value = await get(key);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
  }

  static Future<void> setDateTime(String key, DateTime dateTime) async {
    await set(key, dateTime.millisecondsSinceEpoch.toString());
  }
}