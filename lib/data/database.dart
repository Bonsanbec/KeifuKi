import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';

/// Central SQLite access point.
///
/// This class owns the database lifecycle.
/// No other part of the app should open or close the database.
class AppDatabase {
  static Database? _db;

  /// Returns the singleton database instance.
  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(appDir.path, 'data', 'app.db');

    // Ensure parent directory exists
    await Directory(dirname(dbPath)).create(recursive: true);

    return openDatabase(
      dbPath,
      version: Migrations.currentVersion,
      onCreate: (db, version) async {
        await _runMigrations(db, from: 0, to: version);
      },
      onUpgrade: (db, from, to) async {
        await _runMigrations(db, from: from, to: to);
      },
    );
  }

  static Future<void> _runMigrations(
    Database db, {
    required int from,
    required int to,
  }) async {
    for (int version = from; version < to; version++) {
      final migrationBatch = Migrations.all[version];
      for (final sql in migrationBatch) {
        await db.execute(sql);
      }
    }
  }

  /// Closes the database.
  ///
  /// This should rarely be called explicitly.
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}