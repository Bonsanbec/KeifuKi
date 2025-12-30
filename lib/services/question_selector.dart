import 'dart:async';

import '../domain/question.dart';
import '../domain/question_registry.dart';
import '../data/question_usage_dao.dart';


class SelectedQuestion {
  final String id;
  final String text;

  const SelectedQuestion({
    required this.id,
    required this.text,
  });
}

/// Represents usage information for a question.
///
/// This is a read-only projection of persisted state.
/// The selector does not mutate anything.
class QuestionUsage {
  final String questionId;
  final int timesAnswered;
  final DateTime? lastAnsweredAt;

  const QuestionUsage({
    required this.questionId,
    required this.timesAnswered,
    this.lastAnsweredAt,
  });
}

/// Selects the next question to present based on declared rules
/// and recorded usage.
///
/// This class contains no persistence logic and no randomness.
/// If randomness is desired, it must be injected explicitly.
class QuestionSelector {
  /// Selects the next valid question.
  ///
  /// Returns null if no question is currently eligible.
  static Question? selectNext({
    required DateTime now,
    required Map<String, QuestionUsage> usageByQuestionId,
  }) {
    final activeQuestions = QuestionRegistry.active;

    // 1. Prefer questions never answered.
    for (final question in activeQuestions) {
      final usage = usageByQuestionId[question.id];
      if (usage == null || usage.timesAnswered == 0) {
        return question;
      }
    }

    // 2. Consider repeatable questions that satisfy cooldown.
    for (final question in activeQuestions.where((q) => q.repeatable)) {
      final usage = usageByQuestionId[question.id];
      if (usage == null || usage.lastAnsweredAt == null) {
        return question;
      }

      final cooldown = question.cooldownDuration;
      if (cooldown == null) {
        return question;
      }

      final elapsed = now.difference(usage.lastAnsweredAt!);
      if (elapsed >= cooldown) {
        return question;
      }
    }

    // 3. No eligible question.
    return null;
  }

  static Future<SelectedQuestion?> next() async {
    final usageMap = await QuestionUsageDao.fetchAll();
    final question = selectNext(now: DateTime.now(), usageByQuestionId: usageMap);
    if (question == null) {
      return null;
    }
    return SelectedQuestion(
      id: question.id,
      text: question.text,
    );
  }

  // Esta puede quedarse si aún la usas en algún lado,
  // pero ya no es la vía principal.
  static Future<String> nextQuestionText() async {
    final q = await next();
    return q?.text ?? 'No hay preguntas disponibles por ahora.';
  }
}