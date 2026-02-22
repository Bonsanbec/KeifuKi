import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static const Duration _wateringReminderDelay = Duration(hours: 24);
  static const int wateringReminderId = 41001;
  static const MethodChannel _channel = MethodChannel('keifuki/notifications');

  const NotificationService._();

  static Future<void> refreshWateringReminder({
    required DateTime? lastWateredAt,
    required String? identityName,
  }) async {
    await _ensurePermission();

    await cancelWateringReminder();

    if (lastWateredAt == null) {
      await _scheduleAt(
        DateTime.now().add(_wateringReminderDelay),
        identityName,
      );
      return;
    }

    final dueAt = lastWateredAt.add(_wateringReminderDelay);
    final scheduleAt = dueAt.isAfter(DateTime.now()) ? dueAt : DateTime.now();
    await _scheduleAt(scheduleAt, identityName);
  }

  static Future<void> cancelWateringReminder() async {
    try {
      await _channel.invokeMethod('cancel', {'id': wateringReminderId});
    } catch (_) {
      // Silent fallback if native implementation is not wired yet.
    }
  }

  static Future<void> _scheduleAt(
    DateTime dateTime,
    String? identityName,
  ) async {
    final displayName = (identityName == null || identityName.trim().isEmpty)
        ? 'Amigo'
        : identityName.trim();

    try {
      await _channel.invokeMethod('schedule', {
        'id': wateringReminderId,
        'title': '$displayName, ¿estás ahí?',
        'body': 'Tu árbol necesita un riego suave para seguir creciendo.',
        'scheduled_at_millis': dateTime.millisecondsSinceEpoch,
      });
    } catch (_) {
      // Silent fallback if native implementation is not wired yet.
    }
  }

  static Future<void> _ensurePermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}
