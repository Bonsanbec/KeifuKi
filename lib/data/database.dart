import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';
import '../services/app_data_runtime.dart';

/// Central SQLite access point.
///
/// This class owns the database lifecycle.
/// No other part of the app should open or close the database.
class AppDatabase {
  static Database? _db;
  static String? _currentPath;
  static bool? _currentReadOnly;

  /// Returns the singleton database instance.
  static Future<Database> get instance async {
    final AppDataSource source = await AppDataRuntime.currentSource();
    if (_db != null &&
        AppDataRuntime.pathsMatch(
          source,
          _currentPath ?? '',
          _currentReadOnly ?? false,
        )) {
      return _db!;
    }

    await close();
    _db = await _open(source);
    _currentPath = source.databasePath;
    _currentReadOnly = source.isReadOnly;
    return _db!;
  }

  static Future<Database> _open(AppDataSource source) async {
    final String dbPath = source.databasePath;
    // Ensure parent directory exists
    await Directory(dirname(dbPath)).create(recursive: true);

    return openDatabase(
      dbPath,
      readOnly: source.isReadOnly,
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
    _currentPath = null;
    _currentReadOnly = null;
  }
}
