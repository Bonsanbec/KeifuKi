import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

/// Responsible for creating full application backups.
///
/// A backup consists of:
/// - SQLite database file
/// - media directory (audio, video, images, text)
///
/// This service does NOT:
/// - schedule backups
/// - upload files directly
/// - manage authentication
class BackupService {
  static const String _backupFolderName = 'backups';
  static const String _databaseFileName = 'app.db';
  static const String _mediaFolderName = 'media';

  /// Creates a compressed snapshot of the current app state.
  ///
  /// Returns the path to the generated archive.
  static Future<String> createSnapshot() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory backupDir =
        Directory(join(appDir.path, _backupFolderName));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final String timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-');

    final String archivePath =
        join(backupDir.path, 'snapshot_$timestamp.zip');

    final encoder = ZipFileEncoder();
    encoder.create(archivePath);

    final File dbFile = File(join(appDir.path, _databaseFileName));
    if (await dbFile.exists()) {
      encoder.addFile(dbFile);
    }

    final Directory mediaDir =
        Directory(join(appDir.path, _mediaFolderName));
    if (await mediaDir.exists()) {
      encoder.addDirectory(mediaDir);
    }

    encoder.close();
    return archivePath;
  }

  /// Lists existing local backup snapshots.
  static Future<List<FileSystemEntity>> listSnapshots() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory backupDir =
        Directory(join(appDir.path, _backupFolderName));

    if (!await backupDir.exists()) {
      return [];
    }

    return backupDir.listSync()
      ..sort((a, b) => b.path.compareTo(a.path));
  }
}