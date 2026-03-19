import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppDataSource {
  final String databasePath;
  final String mediaRootPath;
  final bool isReadOnly;
  final String? label;

  const AppDataSource({
    required this.databasePath,
    required this.mediaRootPath,
    this.isReadOnly = false,
    this.label,
  });

  AppDataSource copyWith({
    String? databasePath,
    String? mediaRootPath,
    bool? isReadOnly,
    String? label,
  }) {
    return AppDataSource(
      databasePath: databasePath ?? this.databasePath,
      mediaRootPath: mediaRootPath ?? this.mediaRootPath,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      label: label ?? this.label,
    );
  }
}

class AppDataRuntime {
  AppDataRuntime._();

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static AppDataSource? _current;

  static Future<AppDataSource> liveSource() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return AppDataSource(
      databasePath: join(appDir.path, 'data', 'app.db'),
      mediaRootPath: join(appDir.path, 'media'),
    );
  }

  static Future<AppDataSource> currentSource() async {
    _current ??= await liveSource();
    return _current!;
  }

  static AppDataSource requireCurrentSource() {
    final source = _current;
    if (source == null) {
      throw StateError('AppDataRuntime has not been initialized.');
    }
    return source;
  }

  static Future<bool> isReadOnly() async {
    final source = await currentSource();
    return source.isReadOnly;
  }

  static bool isReadOnlySync() {
    return requireCurrentSource().isReadOnly;
  }

  static Future<void> switchTo(AppDataSource source) async {
    _current = source;
    revision.value++;
  }

  static Future<void> switchToLive() async {
    await switchTo(await liveSource());
  }

  static bool pathsMatch(AppDataSource source, String dbPath, bool isReadOnly) {
    return source.databasePath == dbPath && source.isReadOnly == isReadOnly;
  }
}
