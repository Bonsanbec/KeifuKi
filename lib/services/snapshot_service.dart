import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';
import 'app_data_runtime.dart';

class SnapshotSelection {
  final String zipPath;

  const SnapshotSelection({required this.zipPath});
}

class SnapshotPackage {
  final Directory rootDirectory;
  final File databaseFile;
  final Directory mediaDirectory;
  final String sourceZipPath;

  const SnapshotPackage({
    required this.rootDirectory,
    required this.databaseFile,
    required this.mediaDirectory,
    required this.sourceZipPath,
  });

  AppDataSource toViewerDataSource() {
    return AppDataSource(
      databasePath: databaseFile.path,
      mediaRootPath: mediaDirectory.path,
      isReadOnly: true,
      label: basename(sourceZipPath),
    );
  }
}

class SnapshotImportResult {
  final String snapshotName;

  const SnapshotImportResult({required this.snapshotName});
}

class SnapshotService {
  SnapshotService._();

  static const String _databaseFileName = 'app.db';
  static const String _mediaFolderName = 'media';

  static Future<SnapshotSelection?> pickSnapshotZip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      withData: false,
    );

    final path = result?.files.single.path;
    if (path == null || path.isEmpty) {
      return null;
    }

    return SnapshotSelection(zipPath: path);
  }

  static Future<SnapshotPackage> extractSnapshot(String zipPath) async {
    final Directory tempDir = await getTemporaryDirectory();
    final Directory extractionRoot = Directory(
      join(
        tempDir.path,
        'snapshot_viewer',
        DateTime.now().microsecondsSinceEpoch.toString(),
      ),
    );
    await extractionRoot.create(recursive: true);

    final InputFileStream inputStream = InputFileStream(zipPath);
    late final Archive archive;
    try {
      archive = ZipDecoder().decodeStream(inputStream);
    } finally {
      inputStream.close();
    }

    _validateArchiveStructure(archive);
    _extractArchive(archive, extractionRoot);

    final File dbFile = File(join(extractionRoot.path, _databaseFileName));
    final Directory mediaDir = Directory(
      join(extractionRoot.path, _mediaFolderName),
    );

    await _validateExtractedSnapshot(
      rootDirectory: extractionRoot,
      databaseFile: dbFile,
      mediaDirectory: mediaDir,
    );

    return SnapshotPackage(
      rootDirectory: extractionRoot,
      databaseFile: dbFile,
      mediaDirectory: mediaDir,
      sourceZipPath: zipPath,
    );
  }

  static Future<SnapshotImportResult> importSnapshot(String zipPath) async {
    final snapshot = await extractSnapshot(zipPath);
    final AppDataSource liveSource = await AppDataRuntime.liveSource();
    final String snapshotName = basename(zipPath);
    final Directory databaseParent = Directory(
      dirname(liveSource.databasePath),
    );
    final Directory mediaParent = Directory(dirname(liveSource.mediaRootPath));

    await databaseParent.create(recursive: true);
    await mediaParent.create(recursive: true);

    final String importToken = DateTime.now().microsecondsSinceEpoch.toString();
    final File stagedDatabase = File(
      join(databaseParent.path, 'app.db.importing.$importToken'),
    );
    final Directory stagedMedia = Directory(
      join(mediaParent.path, 'media.importing.$importToken'),
    );
    final File backupDatabase = File(
      join(databaseParent.path, 'app.db.backup.$importToken'),
    );
    final Directory backupMedia = Directory(
      join(mediaParent.path, 'media.backup.$importToken'),
    );
    final File liveDatabase = File(liveSource.databasePath);
    final Directory liveMedia = Directory(liveSource.mediaRootPath);

    await _copyFile(snapshot.databaseFile, stagedDatabase);
    await _copyDirectory(snapshot.mediaDirectory, stagedMedia);

    await AppDatabase.close();

    bool liveDatabaseMoved = false;
    bool liveMediaMoved = false;
    bool stagedDatabaseMoved = false;
    bool stagedMediaMoved = false;

    try {
      if (await liveDatabase.exists()) {
        await liveDatabase.rename(backupDatabase.path);
        liveDatabaseMoved = true;
      }

      if (await liveMedia.exists()) {
        await liveMedia.rename(backupMedia.path);
        liveMediaMoved = true;
      }

      await stagedDatabase.rename(liveDatabase.path);
      stagedDatabaseMoved = true;

      await stagedMedia.rename(liveMedia.path);
      stagedMediaMoved = true;

      if (await backupDatabase.exists()) {
        await backupDatabase.delete();
      }
      if (await backupMedia.exists()) {
        await backupMedia.delete(recursive: true);
      }
    } catch (_) {
      if (stagedDatabaseMoved && await liveDatabase.exists()) {
        await liveDatabase.delete();
      }
      if (stagedMediaMoved && await liveMedia.exists()) {
        await liveMedia.delete(recursive: true);
      }
      if (liveDatabaseMoved && await backupDatabase.exists()) {
        await backupDatabase.rename(liveDatabase.path);
      }
      if (liveMediaMoved && await backupMedia.exists()) {
        await backupMedia.rename(liveMedia.path);
      }
      rethrow;
    } finally {
      if (await stagedDatabase.exists()) {
        await stagedDatabase.delete();
      }
      if (await stagedMedia.exists()) {
        await stagedMedia.delete(recursive: true);
      }
      if (await snapshot.rootDirectory.exists()) {
        await snapshot.rootDirectory.delete(recursive: true);
      }
      await AppDataRuntime.switchToLive();
    }

    return SnapshotImportResult(snapshotName: snapshotName);
  }

  static void _validateArchiveStructure(Archive archive) {
    bool hasDatabase = false;
    bool hasMediaEntry = false;

    for (final file in archive.files) {
      final String entryName = normalize(file.name);
      final bool isDirectory = file.isFile == false;

      if (_isUnsafeArchivePath(entryName)) {
        throw const SnapshotFormatException('El ZIP contiene rutas inválidas.');
      }

      if (entryName == _databaseFileName) {
        hasDatabase = true;
      }

      if (entryName == _mediaFolderName ||
          entryName.startsWith('$_mediaFolderName${Platform.pathSeparator}') ||
          entryName.startsWith('$_mediaFolderName/')) {
        hasMediaEntry = true;
      }

      if (entryName == _mediaFolderName && !isDirectory) {
        throw const SnapshotFormatException(
          'La ruta media debe ser un directorio.',
        );
      }
    }

    if (!hasDatabase || !hasMediaEntry) {
      throw const SnapshotFormatException(
        'El snapshot debe incluir app.db y el directorio media/.',
      );
    }
  }

  static Future<void> _validateExtractedSnapshot({
    required Directory rootDirectory,
    required File databaseFile,
    required Directory mediaDirectory,
  }) async {
    if (!await databaseFile.exists()) {
      throw const SnapshotFormatException('Falta el archivo app.db.');
    }
    if (!await mediaDirectory.exists()) {
      throw const SnapshotFormatException('Falta el directorio media/.');
    }
    if (await databaseFile.length() == 0) {
      throw const SnapshotFormatException('El archivo app.db está vacío.');
    }
    final String rootPath = normalize(rootDirectory.path);
    if (!normalize(databaseFile.path).startsWith(rootPath) ||
        !normalize(mediaDirectory.path).startsWith(rootPath)) {
      throw const SnapshotFormatException('El snapshot extraído es inválido.');
    }
  }

  static void _extractArchive(Archive archive, Directory destination) {
    for (final file in archive.files) {
      final String relativePath = normalize(file.name);
      if (_isUnsafeArchivePath(relativePath)) {
        throw const SnapshotFormatException('El ZIP contiene rutas inválidas.');
      }

      final String outputPath = join(destination.path, relativePath);
      if (file.isFile) {
        final File outFile = File(outputPath)..createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>, flush: true);
      } else {
        Directory(outputPath).createSync(recursive: true);
      }
    }
  }

  static bool _isUnsafeArchivePath(String pathValue) {
    if (pathValue.isEmpty || isAbsolute(pathValue)) {
      return true;
    }
    final List<String> parts = split(pathValue);
    return parts.contains('..');
  }

  static Future<void> _copyDirectory(
    Directory source,
    Directory destination,
  ) async {
    await destination.create(recursive: true);

    await for (final entity in source.list(recursive: false)) {
      final String targetPath = join(destination.path, basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(targetPath));
      } else if (entity is File) {
        await _copyFile(entity, File(targetPath));
      }
    }
  }

  static Future<void> _copyFile(File source, File destination) async {
    await destination.parent.create(recursive: true);
    await source.copy(destination.path);
  }
}

class SnapshotFormatException implements Exception {
  final String message;

  const SnapshotFormatException(this.message);

  @override
  String toString() => message;
}
