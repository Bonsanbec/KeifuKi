import 'dart:io';

import 'package:path/path.dart';

import '../domain/enums.dart';
import 'app_data_runtime.dart';

/// Handles physical storage of media files.
///
/// This class is responsible only for:
/// - creating directories
/// - generating deterministic file paths
/// - writing text files
///
/// It does NOT handle recording, encoding, or permissions.
class MediaStore {
  /// Ensures that the media directory structure exists.
  static Future<Directory> _ensureBaseDir() async {
    final AppDataSource source = await AppDataRuntime.currentSource();
    final Directory mediaDir = Directory(source.mediaRootPath);

    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    return mediaDir;
  }

  /// Returns the directory for a given media type.
  static Future<Directory> _ensureTypeDir(MediaType type) async {
    final Directory base = await _ensureBaseDir();
    final Directory typeDir = Directory(join(base.path, _typeFolderName(type)));

    if (!await typeDir.exists()) {
      await typeDir.create(recursive: true);
    }

    return typeDir;
  }

  /// Generates a file path for a new media entry.
  ///
  /// The filename is derived exclusively from the response id.
  static Future<String> generatePath({
    required String responseId,
    required MediaType type,
  }) async {
    final Directory dir = await _ensureTypeDir(type);
    final String extension = _fileExtension(type);

    return join(dir.path, '$responseId.$extension');
  }

  /// Writes a text response to disk and returns its path.
  static Future<String> writeText({
    required String responseId,
    required String content,
  }) async {
    final path = await generatePath(
      responseId: responseId,
      type: MediaType.text,
    );

    final file = File(path);
    await file.writeAsString(content, flush: true);

    return path;
  }

  /// Copies an existing file into the media store.
  ///
  /// This is used for audio, video, or images captured elsewhere.
  static Future<String> importFile({
    required String responseId,
    required MediaType type,
    required File source,
  }) async {
    final path = await generatePath(responseId: responseId, type: type);

    await source.copy(path);
    return path;
  }

  static Future<String> resolveStoredPath(String storedPath) async {
    final AppDataSource source = await AppDataRuntime.currentSource();
    return resolveStoredPathForSource(
      storedPath: storedPath,
      mediaRootPath: source.mediaRootPath,
    );
  }

  static String resolveStoredPathForSource({
    required String storedPath,
    required String mediaRootPath,
  }) {
    final String normalizedMediaRoot = normalize(mediaRootPath);
    final String normalizedStoredPath = normalize(storedPath);

    if (!normalizedStoredPath.contains('media')) {
      return storedPath;
    }

    final List<String> parts = split(normalizedStoredPath);
    final int mediaIndex = parts.lastIndexOf('media');
    if (mediaIndex == -1 || mediaIndex == parts.length - 1) {
      return storedPath;
    }

    final String relativePath = joinAll(parts.sublist(mediaIndex + 1));
    return join(normalizedMediaRoot, relativePath);
  }

  static String _typeFolderName(MediaType type) {
    switch (type) {
      case MediaType.audio:
        return 'audio';
      case MediaType.video:
        return 'video';
      case MediaType.image:
        return 'image';
      case MediaType.text:
        return 'text';
    }
  }

  static String _fileExtension(MediaType type) {
    switch (type) {
      case MediaType.audio:
        return 'm4a';
      case MediaType.video:
        return 'mp4';
      case MediaType.image:
        return 'jpg';
      case MediaType.text:
        return 'txt';
    }
  }
}
