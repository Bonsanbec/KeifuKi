package dev.bonsanbec.keifu_ki

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class WateringReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 41001)
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "Tu árbol te recuerda volver"
        val body = intent.getStringExtra(EXTRA_BODY)
            ?: "Tu árbol necesita un riego suave para seguir creciendo."

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Recordatorios de KeifuKi",
                NotificationManager.IMPORTANCE_DEFAULT,
            )
            channel.description = "Recordatorios de riego del árbol"
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_my_calendar)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()

        manager.notify(id, notification)
    }

    companion object {
        const val CHANNEL_ID = "keifuki_watering_reminders"
        const val EXTRA_NOTIFICATION_ID = "notification_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
    }
}
