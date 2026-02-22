package dev.bonsanbec.keifu_ki

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "keifuki/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "schedule" -> {
                        val id = call.argument<Int>("id")
                        val title = call.argument<String>("title")
                        val body = call.argument<String>("body")
                        val scheduledAtMillis = call.argument<Long>("scheduled_at_millis")

                        if (id == null || title == null || body == null || scheduledAtMillis == null) {
                            result.error("invalid_args", "Missing notification arguments", null)
                            return@setMethodCallHandler
                        }

                        scheduleNotification(
                            context = applicationContext,
                            id = id,
                            title = title,
                            body = body,
                            triggerAtMillis = scheduledAtMillis,
                        )
                        result.success(null)
                    }

                    "cancel" -> {
                        val id = call.argument<Int>("id")
                        if (id == null) {
                            result.error("invalid_args", "Missing notification id", null)
                            return@setMethodCallHandler
                        }

                        cancelNotification(applicationContext, id)
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun scheduleNotification(
        context: Context,
        id: Int,
        title: String,
        body: String,
        triggerAtMillis: Long,
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = buildPendingIntent(context, id, title, body)

        val now = System.currentTimeMillis()
        val triggerAt = if (triggerAtMillis > now) triggerAtMillis else now + 1_000L

        cancelNotification(context, id)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                pendingIntent,
            )
        } else {
            alarmManager.set(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                pendingIntent,
            )
        }
    }

    private fun cancelNotification(context: Context, id: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = buildPendingIntent(
            context = context,
            id = id,
            title = "",
            body = "",
        )

        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }

    private fun buildPendingIntent(
        context: Context,
        id: Int,
        title: String,
        body: String,
    ): PendingIntent {
        val intent = Intent(context, WateringReminderReceiver::class.java).apply {
            putExtra(WateringReminderReceiver.EXTRA_NOTIFICATION_ID, id)
            putExtra(WateringReminderReceiver.EXTRA_TITLE, title)
            putExtra(WateringReminderReceiver.EXTRA_BODY, body)
        }

        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, id, intent, flags)
    }
}
