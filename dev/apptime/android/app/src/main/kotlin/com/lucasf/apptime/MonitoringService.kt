package com.lucasf.apptime

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat

class MonitoringService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var usageStatsManager: UsageStatsManager
    private lateinit var prefs: SharedPreferences

    private var lastPackage: String? = null
    private var sessionStartMs: Long = 0L

    private val unlockReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == Intent.ACTION_USER_PRESENT) {
                val key = "flutter.unlock_count_${today()}"
                val current = prefs.getInt(key, 0)
                prefs.edit().putInt(key, current + 1).apply()
            }
        }
    }

    private val pollRunnable = object : Runnable {
        override fun run() {
            tick()
            handler.postDelayed(this, 1_000)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIF_ID, buildNotification())
        usageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        registerReceiver(unlockReceiver, IntentFilter(Intent.ACTION_USER_PRESENT))
        handler.post(pollRunnable)
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(pollRunnable)
        try { unregisterReceiver(unlockReceiver) } catch (_: Exception) {}
        prefs.edit()
            .putBoolean("flutter.overlay_visible", false)
            .apply()
        super.onDestroy()
    }

    private fun tick() {
        val current = getCurrentApp()
        val isLauncher = current != null && LAUNCHERS.contains(current)

        if (current != null && current != lastPackage) {
            // Fecha sessão anterior
            if (lastPackage != null) {
                val duration = System.currentTimeMillis() - sessionStartMs
                accumulateDailyMs(lastPackage!!, duration)
            }
            // Abre nova sessão
            lastPackage = current
            sessionStartMs = System.currentTimeMillis()
            if (!isLauncher) incrementOpenCount(current)
        }

        val overlayText = when {
            current == null -> ""
            isLauncher -> {
                val unlocks = getUnlockCount()
                val totalMs = getDeviceDailyMs()
                // Alterna fase baseado em tempo desde último unlock (simplificado: usa tempo fixo)
                if (shouldShowCount()) "$unlocks×" else formatTime(totalMs)
            }
            else -> {
                val opens = getOpenCount(current)
                val ms = getDailyMs(current) + (System.currentTimeMillis() - sessionStartMs)
                if (shouldShowCount()) "$opens×" else formatTime(ms)
            }
        }

        prefs.edit()
            .putString("flutter.overlay_text", overlayText)
            .putBoolean("flutter.overlay_visible", current != null)
            .apply()
    }

    private fun getCurrentApp(): String? {
        val now = System.currentTimeMillis()
        val events = usageStatsManager.queryEvents(now - 60_000, now)
        val event = UsageEvents.Event()
        var lastFg: String? = null
        var lastTs = 0L

        while (events.getNextEvent(event)) {
            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    if (event.timeStamp > lastTs) {
                        lastFg = event.packageName
                        lastTs = event.timeStamp
                    }
                }
                UsageEvents.Event.SCREEN_NON_INTERACTIVE -> {
                    // Tela apagou — sem app em foco
                    if (event.timeStamp > lastTs) {
                        lastFg = null
                        lastTs = event.timeStamp
                    }
                }
            }
        }
        return lastFg
    }

    // ── Banco de sessões ──────────────────────────────────────────────────────

    private fun today(): String {
        val c = java.util.Calendar.getInstance()
        return "%04d-%02d-%02d".format(c.get(java.util.Calendar.YEAR),
            c.get(java.util.Calendar.MONTH) + 1, c.get(java.util.Calendar.DAY_OF_MONTH))
    }

    private fun accumulateDailyMs(pkg: String, duration: Long) {
        val key = "flutter.daily_ms_${pkg}_${today()}"
        val current = prefs.getLong(key, 0L)
        prefs.edit().putLong(key, current + duration).apply()

        val deviceKey = "flutter.device_daily_ms_${today()}"
        val deviceCurrent = prefs.getLong(deviceKey, 0L)
        prefs.edit().putLong(deviceKey, deviceCurrent + duration).apply()
    }

    private fun incrementOpenCount(pkg: String) {
        val key = "flutter.open_count_${pkg}_${today()}"
        val current = prefs.getInt(key, 0)
        prefs.edit().putInt(key, current + 1).apply()
    }

    private fun getDailyMs(pkg: String): Long =
        prefs.getLong("flutter.daily_ms_${pkg}_${today()}", 0L)

    private fun getOpenCount(pkg: String): Int =
        prefs.getInt("flutter.open_count_${pkg}_${today()}", 0)

    private fun getUnlockCount(): Int =
        prefs.getInt("flutter.unlock_count_${today()}", 0)

    private fun getDeviceDailyMs(): Long =
        prefs.getLong("flutter.device_daily_ms_${today()}", 0L)

    // ── Formatação ────────────────────────────────────────────────────────────

    private fun formatTime(ms: Long): String {
        val totalSec = ms / 1000
        val hours = totalSec / 3600
        val mins = (totalSec % 3600) / 60
        val secs = totalSec % 60
        return if (hours > 0) "%d:%02d".format(hours, mins)
               else "%d:%02d".format(mins, secs)
    }

    // Phase 0 = mostrar contagem (primeiros 5s de cada sessão de app)
    private fun shouldShowCount(): Boolean {
        val elapsed = System.currentTimeMillis() - sessionStartMs
        return elapsed < 5_000
    }

    // ── Notificação ───────────────────────────────────────────────────────────

    private fun buildNotification(): Notification {
        val channelId = "apptime_monitoring"
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(channelId) == null) {
            manager.createNotificationChannel(
                NotificationChannel(channelId, "AppTime Monitoramento",
                    NotificationManager.IMPORTANCE_MIN)
            )
        }
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("AppTime monitorando")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .build()
    }

    companion object {
        const val NOTIF_ID = 1002

        val LAUNCHERS = setOf(
            "com.google.android.apps.nexuslauncher",
            "com.sec.android.app.launcher",
            "com.miui.home",
            "com.android.launcher",
            "com.android.launcher3",
            "com.huawei.android.launcher",
            "com.oneplus.launcher",
        )
    }
}
