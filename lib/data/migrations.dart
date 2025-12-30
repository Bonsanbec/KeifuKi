/// SQLite schema migrations.
///
/// This file defines the canonical database structure.
/// SQL is kept explicit and readable on purpose.
class Migrations {
  static const int currentVersion = 1;

  static const List<String> v1 = [
    '''
    CREATE TABLE IF NOT EXISTS responses (
      id TEXT PRIMARY KEY,
      question_id TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      media_type TEXT NOT NULL,
      duration_seconds INTEGER,
      file_path TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE IF NOT EXISTS question_usage (
      question_id TEXT PRIMARY KEY,
      times_answered INTEGER NOT NULL,
      last_answered_at INTEGER
    );
    ''',
    '''
    CREATE TABLE IF NOT EXISTS system_state (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
    '''
  ];

  static List<List<String>> get all => [
        v1,
      ];
}