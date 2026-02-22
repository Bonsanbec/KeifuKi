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
  static Future<String> createSnapshot({
    void Function(double progress)? onProgress,
  }) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory backupDir = Directory(join(appDir.path, _backupFolderName));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final String timestamp = DateTime.now().toIso8601String().replaceAll(
      ':',
      '-',
    );

    final String archivePath = join(backupDir.path, 'snapshot_$timestamp.zip');

    onProgress?.call(0.05);

    final Archive archive = Archive();

    // Add database file as 'app.db'
    final File dbFile = File(join(appDir.path, 'data', _databaseFileName));
    if (await dbFile.exists()) {
      final List<int> dbBytes = await dbFile.readAsBytes();
      archive.addFile(ArchiveFile(_databaseFileName, dbBytes.length, dbBytes));
    }
    onProgress?.call(0.25);

    // Add media directory files recursively
    final Directory mediaDir = Directory(join(appDir.path, _mediaFolderName));
    if (await mediaDir.exists()) {
      final entities = await mediaDir
          .list(recursive: true)
          .where((entity) => entity is File)
          .cast<File>()
          .toList();

      final totalFiles = entities.isEmpty ? 1 : entities.length;
      int processedFiles = 0;

      for (final entity in entities) {
        final String fullPath = entity.path;
        final List<int> fileBytes = await entity.readAsBytes();
        final String relativePath = fullPath.substring(appDir.path.length + 1);
        archive.addFile(ArchiveFile(relativePath, fileBytes.length, fileBytes));

        processedFiles++;
        final step = processedFiles / totalFiles;
        onProgress?.call(0.25 + (step * 0.55));
      }
    } else {
      onProgress?.call(0.8);
    }

    final ZipEncoder encoder = ZipEncoder();
    final OutputFileStream outputStream = OutputFileStream(archivePath);
    encoder.encode(archive, output: outputStream);
    await outputStream.close();
    onProgress?.call(0.88);

    return archivePath;
  }

  /// Lists existing local backup snapshots.
  static Future<List<FileSystemEntity>> listSnapshots() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory backupDir = Directory(join(appDir.path, _backupFolderName));

    if (!await backupDir.exists()) {
      return [];
    }

    return backupDir.listSync()..sort((a, b) => b.path.compareTo(a.path));
  }
}
