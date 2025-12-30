/// Defines core enumerations used across the domain.
///
/// These enums are deliberately small and stable.
/// Any expansion should be carefully justified, as they affect
/// persistence, backups, and media handling.

/// Represents the physical form of a response.
enum MediaType {
  text,
  audio,
  video,
  image,
}

/// Represents the lifecycle state of a question.
enum QuestionState {
  unanswered,
  answered,
  revisitable,
}

/// Indicates how a response was captured.
enum CaptureMethod {
  typed,
  recorded,
  imported,
}