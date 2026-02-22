import '../data/system_state_dao.dart';
import '../domain/response.dart';
import '../domain/tree_state.dart';
import '../domain/question_registry.dart';
import 'notification_service.dart';

class TreeStateService {
  const TreeStateService._();

  static Future<void> registerResponse({
    required ResponseEntry response,
    required String? identityText,
  }) async {
    final state = await SystemStateDao.ensureTreeState();

    final markers = [...state.structuralMarkers];
    if (response.growthMetadata?.structuralShift == true) {
      final markerId = 'response:${response.id}';
      final exists = markers.any((m) => m.id == markerId);
      if (!exists) {
        markers.add(
          StructuralMarker(
            id: markerId,
            createdAt: response.createdAt,
            reason: 'response-shift',
            intensity: response.growthMetadata?.depth ?? 1,
          ),
        );
      }
    }

    final isIdentityResponse =
        response.questionId == QuestionRegistry.identityQuestionId;
    final identityCandidate = (identityText ?? '').trim();

    final updated = state.copyWith(
      plantedAt: isIdentityResponse && state.plantedAt == null
          ? response.createdAt
          : state.plantedAt,
      identityName: isIdentityResponse && identityCandidate.isNotEmpty
          ? identityCandidate
          : state.identityName,
      structuralMarkers: markers,
      lastWateredAt: response.createdAt,
    );

    await SystemStateDao.saveTreeState(updated);
    await NotificationService.refreshWateringReminder(
      lastWateredAt: updated.lastWateredAt,
      identityName: updated.identityName,
    );
  }
}
