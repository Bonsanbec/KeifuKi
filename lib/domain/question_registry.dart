import 'question.dart';

/// Canonical registry of all questions available in the app.
///
/// This list is finite and intentionally compiled into the binary.
/// Questions are identified exclusively by their [id].
///
/// Do NOT reuse an id for a different question.
/// Text may change; identity must not.
class QuestionRegistry {
  const QuestionRegistry._(); // Prevent instantiation

  /// Ordered list of all questions.
  ///
  /// Order does not imply presentation order; selection logic
  /// is handled elsewhere.
  static const List<Question> all = [
    Question(
      id: 'childhood_place',
      text: '¿Cómo era el lugar donde creciste?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_memory_early',
      text: '¿Cuál es uno de tus recuerdos más antiguos?',
      category: 'childhood',
    ),
    Question(
      id: 'parents_description',
      text: '¿Cómo describirías a tus padres?',
      category: 'family',
    ),
    Question(
      id: 'school_experience',
      text: '¿Cómo fue tu experiencia en la escuela?',
      category: 'education',
    ),
    Question(
      id: 'first_job',
      text: '¿Cuál fue tu primer trabajo y cómo lo recuerdas?',
      category: 'work',
    ),
    Question(
      id: 'work_pride',
      text: '¿De qué trabajo o actividad te sentiste más orgulloso?',
      category: 'work',
    ),
    Question(
      id: 'life_turning_point',
      text: '¿Hubo algún momento que cambió el rumbo de tu vida?',
      category: 'life',
    ),
    Question(
      id: 'important_people',
      text: '¿Qué personas han sido más importantes para ti?',
      category: 'relationships',
    ),
    Question(
      id: 'love_definition',
      text: '¿Qué significa para ti el amor?',
      category: 'values',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'fear_definition',
      text: '¿A qué le has tenido más miedo en la vida?',
      category: 'values',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'daily_thoughts',
      text: '¿En qué pensaste hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_annoyance',
      text: '¿Hubo algo que te molestara hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'current_worries',
      text: '¿Hay algo que te preocupe últimamente?',
      category: 'present',
      repeatable: true,
      cooldownDays: 30,
    ),
    Question(
      id: 'unanswered_question',
      text: '¿Hay algo que sientas que nadie te ha preguntado?',
      category: 'meta',
      repeatable: true,
      cooldownDays: 90,
    ),
    Question(
      id: 'message_future',
      text: 'Si pudieras dejar un mensaje para el futuro, ¿qué dirías?',
      category: 'legacy',
      repeatable: true,
      cooldownDays: 365,
    ),
  ];

  /// Convenience lookup by id.
  static final Map<String, Question> byId = {
    for (final q in all) q.id: q,
  };

  /// Returns only questions currently marked as active.
  static List<Question> get active =>
      all.where((q) => q.active).toList(growable: false);
}