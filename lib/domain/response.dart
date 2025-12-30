class ResponseEntry {
  final String id;
  final String questionId;
  final DateTime createdAt;
  final String mediaType;
  final int? durationSeconds;
  final String filePath;

  const ResponseEntry({
    required this.id,
    required this.questionId,
    required this.createdAt,
    required this.mediaType,
    this.durationSeconds,
    required this.filePath,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'question_id': questionId,
        'created_at': createdAt.millisecondsSinceEpoch,
        'media_type': mediaType,
        'duration_seconds': durationSeconds,
        'file_path': filePath,
      };

  static ResponseEntry fromMap(Map<String, Object?> map) {
    return ResponseEntry(
      id: map['id'] as String,
      questionId: map['question_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
      ),
      mediaType: map['media_type'] as String,
      durationSeconds: map['duration_seconds'] as int?,
      filePath: map['file_path'] as String,
    );
  }
}