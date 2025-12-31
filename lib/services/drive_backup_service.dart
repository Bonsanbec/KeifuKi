import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

/// Handles authentication and upload of backup snapshots to Google Drive.
///
/// Responsibilities:
/// - Google Sign-In
/// - Ensure KeifuKi folder exists
/// - Upload ZIP snapshots
///
/// Does NOT:
/// - Create backups
/// - Schedule uploads
/// - Interact with UI directly
class DriveBackupService {
  static const _keifukiFolderName = 'KeifuKi';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      drive.DriveApi.driveFileScope,
    ],
  );

  static GoogleSignInAccount? _currentUser;
  static drive.DriveApi? _driveApi;
  static String? _folderId;

  /// Ensures the user is authenticated and Drive API is ready.
  static Future<void> _ensureSignedIn() async {
    _currentUser ??= await _googleSignIn.signInSilently();

    _currentUser ??= await _googleSignIn.signIn();

    if (_currentUser == null) {
      throw Exception('Google Sign-In aborted');
    }

    final authHeaders = await _currentUser!.authHeaders;
    final authenticatedClient = GoogleAuthClient(authHeaders);

    _driveApi = drive.DriveApi(authenticatedClient);
  }

  /// Ensures the KeifuKi folder exists in Drive.
  static Future<void> _ensureFolder() async {
    if (_folderId != null) return;

    final query =
        "mimeType='application/vnd.google-apps.folder' and name='$_keifukiFolderName' and trashed=false";

    final result = await _driveApi!.files.list(q: query);

    if (result.files != null && result.files!.isNotEmpty) {
      _folderId = result.files!.first.id;
      return;
    }

    final folder = drive.File()
      ..name = _keifukiFolderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await _driveApi!.files.create(folder);
    _folderId = created.id;
  }

  /// Uploads a backup ZIP file to Google Drive.
  ///
  /// Throws if sign-in is cancelled or upload fails.
  static Future<void> uploadSnapshot(File zipFile) async {
    await _ensureSignedIn();
    await _ensureFolder();

    final media = drive.Media(
      zipFile.openRead(),
      zipFile.lengthSync(),
    );

    final driveFile = drive.File()
      ..name = zipFile.uri.pathSegments.last
      ..parents = [_folderId!];

    await _driveApi!.files.create(
      driveFile,
      uploadMedia: media,
    );
  }
}

/// Minimal authenticated HTTP client for googleapis
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}