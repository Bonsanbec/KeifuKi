import 'dart:async';
import 'dart:math' as math;

import '../data/question_usage_dao.dart';
import '../data/system_state_dao.dart';
import '../domain/question.dart';
import '../domain/question_registry.dart';

class SelectedQuestion {
  final String id;
  final String text;
  final String? category;

  const SelectedQuestion({
    required this.id,
    required this.text,
    required this.category,
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
class QuestionSelector {
  /// Selects the next valid question.
  static Question selectNext({
    required DateTime now,
    required Map<String, QuestionUsage> usageByQuestionId,
    required int growthSeed,
    required bool hasIdentityResponse,
  }) {
    final identityQuestion =
        QuestionRegistry.byId[QuestionRegistry.identityQuestionId];
    if (identityQuestion == null) {
      throw StateError(
        'Identity question is missing: ${QuestionRegistry.identityQuestionId}',
      );
    }

    // Hard rule: first question must be identity if no identity response exists.
    if (!hasIdentityResponse) {
      return identityQuestion;
    }

    // System questions are excluded after identity.
    final candidatePool = QuestionRegistry.active
        .where((q) => q.id != QuestionRegistry.identityQuestionId)
        .where((q) => q.category != 'system')
        .toList(growable: false);

    // Deterministic ordering independent of QuestionRegistry.all declaration.
    final normalizedPool = [...candidatePool]
      ..sort((a, b) => a.id.compareTo(b.id));

    // Track most recently answered question to avoid immediate repetition.
    String? mostRecentQuestionId;
    DateTime? mostRecentAt;
    for (final entry in usageByQuestionId.values) {
      final last = entry.lastAnsweredAt;
      if (last == null) continue;
      if (mostRecentAt == null || last.isAfter(mostRecentAt)) {
        mostRecentAt = last;
        mostRecentQuestionId = entry.questionId;
      }
    }

    List<Question> unansweredEligible() {
      return normalizedPool
          .where((q) {
            final usage = usageByQuestionId[q.id];
            return usage == null || usage.timesAnswered == 0;
          })
          .toList(growable: false);
    }

    List<Question> repeatableCooldownEligible() {
      return normalizedPool
          .where((q) => q.repeatable)
          .where((q) {
            final usage = usageByQuestionId[q.id];
            if (usage == null || usage.lastAnsweredAt == null) return true;
            final cooldown = q.cooldownDuration;
            if (cooldown == null) return true;
            return now.difference(usage.lastAnsweredAt!) >= cooldown;
          })
          .toList(growable: false);
    }

    List<Question> removeImmediateRepeat(List<Question> questions) {
      if (questions.length <= 1 || mostRecentQuestionId == null) {
        return questions;
      }
      final filtered = questions
          .where((q) => q.id != mostRecentQuestionId)
          .toList(growable: false);
      return filtered.isEmpty ? questions : filtered;
    }

    Question pickDeterministic(List<Question> options, String tier) {
      final sortedOptions = [...options]..sort((a, b) => a.id.compareTo(b.id));
      final totalAnswers = usageByQuestionId.values.fold<int>(
        0,
        (sum, usage) => sum + usage.timesAnswered,
      );
      final dayBucket = DateTime(
        now.year,
        now.month,
        now.day,
      ).millisecondsSinceEpoch;
      final optionIds = sortedOptions.map((q) => q.id).join('|');
      final seed = _stableHash(
        '$growthSeed|$totalAnswers|$dayBucket|$tier|$optionIds',
      );
      final random = math.Random(seed);
      return sortedOptions[random.nextInt(sortedOptions.length)];
    }

    final tier1 = removeImmediateRepeat(unansweredEligible());
    if (tier1.isNotEmpty) {
      return pickDeterministic(tier1, 'tier1-unanswered');
    }

    final tier2 = removeImmediateRepeat(repeatableCooldownEligible());
    if (tier2.isNotEmpty) {
      return pickDeterministic(tier2, 'tier2-repeatable-cooldown');
    }

    // Explicit fallback: if nothing is eligible, repeat oldest answered
    // repeatable question first, then oldest non-system question.
    final repeatableFallback =
        normalizedPool.where((q) => q.repeatable).toList(growable: false)
          ..sort((a, b) {
            final aLast = usageByQuestionId[a.id]?.lastAnsweredAt;
            final bLast = usageByQuestionId[b.id]?.lastAnsweredAt;
            if (aLast == null && bLast == null) return a.id.compareTo(b.id);
            if (aLast == null) return -1;
            if (bLast == null) return 1;
            final cmp = aLast.compareTo(bLast);
            if (cmp != 0) return cmp;
            return a.id.compareTo(b.id);
          });
    final tier3 = removeImmediateRepeat(repeatableFallback);
    if (tier3.isNotEmpty) {
      return tier3.first;
    }

    final generalFallback = [...normalizedPool]
      ..sort((a, b) {
        final aLast = usageByQuestionId[a.id]?.lastAnsweredAt;
        final bLast = usageByQuestionId[b.id]?.lastAnsweredAt;
        if (aLast == null && bLast == null) return a.id.compareTo(b.id);
        if (aLast == null) return -1;
        if (bLast == null) return 1;
        final cmp = aLast.compareTo(bLast);
        if (cmp != 0) return cmp;
        return a.id.compareTo(b.id);
      });
    final tier4 = removeImmediateRepeat(generalFallback);
    if (tier4.isNotEmpty) {
      return tier4.first;
    }

    // Last safety guard: never return null.
    return identityQuestion;
  }

  static Future<SelectedQuestion> next() async {
    final usageMap = await QuestionUsageDao.fetchAll();
    final treeState = await SystemStateDao.ensureTreeState();
    final identityUsage = usageMap[QuestionRegistry.identityQuestionId];
    final hasIdentityResponse = (identityUsage?.timesAnswered ?? 0) > 0;

    final question = selectNext(
      now: DateTime.now(),
      usageByQuestionId: usageMap,
      growthSeed: treeState.growthSeed,
      hasIdentityResponse: hasIdentityResponse,
    );

    return SelectedQuestion(
      id: question.id,
      text: question.text,
      category: question.category,
    );
  }

  static Future<String> nextQuestionText() async {
    final q = await next();
    return q.text;
  }

  static int _stableHash(String input) {
    int hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }
}
