/// Represents an immutable question prompt.
///
/// A Question is identified by a stable [id] defined at compile time.
/// Its identity must never change across app versions, even if the
/// text is edited. All persistence and usage tracking rely on this.
class Question {
  /// Stable unique identifier.
  ///
  /// This is NOT generated dynamically.
  /// Once published, it must never be reused for a different question.
  final String id;

  /// Text shown to the user.
  ///
  /// This may change across app versions without breaking persistence,
  /// as long as [id] remains the same.
  final String text;

  /// Optional category for internal organization.
  ///
  /// This is never shown to the user and exists only to help the author
  /// reason about coverage (e.g. childhood, work, values).
  final String? category;

  /// Whether this question may be answered more than once.
  final bool repeatable;

  /// Minimum number of days that must pass before the question
  /// may be shown again, if [repeatable] is true.
  ///
  /// If null, the question may repeat immediately.
  final int? cooldownDays;

  /// Whether this question is currently active.
  ///
  /// Inactive questions are ignored by selection logic but remain
  /// part of the registry to preserve historical integrity.
  final bool active;

  const Question({
    required this.id,
    required this.text,
    this.category,
    this.repeatable = false,
    this.cooldownDays,
    this.active = true,
  }) : assert(
          !repeatable || cooldownDays == null || cooldownDays >= 0,
          'cooldownDays must be null or >= 0',
        );

  /// Convenience helper to express cooldown as a [Duration].
  ///
  /// Returns null if no cooldown is defined.
  Duration? get cooldownDuration {
    if (cooldownDays == null) return null;
    return Duration(days: cooldownDays!);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Question(id: $id, repeatable: $repeatable, active: $active)';
  }
}