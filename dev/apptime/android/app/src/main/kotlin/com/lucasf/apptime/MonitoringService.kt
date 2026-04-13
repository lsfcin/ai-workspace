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
    private var watchdogTick = 0
    private var lastDate: String = ""

    // Reopening tolerance: if the same app returns within this window, don't
    // count it as a new open (covers copy-paste flows, permission dialogs, etc.)
    // 120 s aligns with common session-gap thresholds in mobile UX research.
    private var lastClosedPkg: String? = null
    private var lastClosedMs: Long = 0L
    private val REOPEN_TOLERANCE_MS = 120_000L

    private val unlockReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == Intent.ACTION_USER_PRESENT) {
                val date = today()
                val hour = currentHour()
                // Daily total — use putLong so Flutter's getInt() (which reads Long) works
                val key = "flutter.unlock_count_${date}"
                prefs.edit().putLong(key, prefs.safeGetCount(key) + 1).apply()
                // Hourly count
                val hourKey = "flutter.hourly_unlocks_${date}_${hour}"
                prefs.edit().putLong(hourKey, prefs.safeGetCount(hourKey) + 1).apply()
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
        lastDate = today()
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
        // Watchdog: restart OverlayService every 30s in case it was killed
        if (++watchdogTick >= 30) {
            watchdogTick = 0
            startService(Intent(this, OverlayService::class.java))
        }

        // Day rollover: flush the active session so pre-midnight usage isn't
        // attributed to the new calendar day. The in-flight duration is discarded
        // (bounded loss: at most one session's worth of ms, typically seconds).
        val currentDate = today()
        if (currentDate != lastDate) {
            lastPackage = null
            lastDate = currentDate
        }

        val current = getCurrentApp()
        val isLauncher = current != null && LAUNCHERS.contains(current)

        if (current == null) {
            // Screen off or no foreground app — close any open session immediately
            if (lastPackage != null) {
                val duration = System.currentTimeMillis() - sessionStartMs
                accumulateDailyMs(lastPackage!!, duration)
                lastPackage = null
            }
            prefs.edit()
                .putString("flutter.overlay_text", "")
                .putBoolean("flutter.overlay_visible", false)
                .remove("flutter.current_pkg")
                .apply()
            return
        }

        if (current != lastPackage) {
            // App switch — close previous session, open new one
            val now = System.currentTimeMillis()
            if (lastPackage != null) {
                val duration = now - sessionStartMs
                accumulateDailyMs(lastPackage!!, duration)
                lastClosedPkg = lastPackage
                lastClosedMs  = now
            }
            lastPackage = current
            sessionStartMs = now
            val isReturn = current == lastClosedPkg && (now - lastClosedMs) < REOPEN_TOLERANCE_MS
            if (!isLauncher && !isReturn) incrementOpenCount(current)
        }

        // ── Per-app overlay visibility ──────────────────────────────────────
        val disabledApps = prefs.getStringList("flutter.disabled_apps") ?: emptyList<String>()
        val monitorLauncher = prefs.getBoolean("flutter.monitor_launcher", true)
        val overlayHidden = disabledApps.contains(current) || (isLauncher && !monitorLauncher)

        if (overlayHidden) {
            // Still track time and session, but don't show overlay
            prefs.edit()
                .putString("flutter.overlay_text", "")
                .putBoolean("flutter.overlay_visible", false)
                .putString("flutter.current_pkg", current)
                .putLong("flutter.current_session_start_ms", sessionStartMs)
                .apply()
            return
        }

        val overlayText = when {
            isLauncher -> {
                val unlocks = getUnlockCount()
                val totalMs = getDeviceDailyMs()
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
            .putBoolean("flutter.overlay_visible", true)
            // Expose raw values for OverlayService feedback evaluation
            .putString("flutter.current_pkg", current)
            .putLong("flutter.current_session_start_ms", sessionStartMs)
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
        // The "day" starts at 04:00 — hours 00–03 belong to the previous calendar day.
        val c = java.util.Calendar.getInstance()
        if (c.get(java.util.Calendar.HOUR_OF_DAY) < 4) c.add(java.util.Calendar.DATE, -1)
        return "%04d-%02d-%02d".format(c.get(java.util.Calendar.YEAR),
            c.get(java.util.Calendar.MONTH) + 1, c.get(java.util.Calendar.DAY_OF_MONTH))
    }

    private fun currentHour(): Int =
        java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY)

    private fun accumulateDailyMs(pkg: String, duration: Long) {
        val date = today()
        val hour = currentHour()

        // Daily totals (per-app + device)
        val key = "flutter.daily_ms_${pkg}_${date}"
        prefs.edit().putLong(key, prefs.getLong(key, 0L) + duration).apply()
        val deviceKey = "flutter.device_daily_ms_${date}"
        prefs.edit().putLong(deviceKey, prefs.getLong(deviceKey, 0L) + duration).apply()

        // Hourly breakdown (per-app + device)
        val hourKey = "flutter.hourly_ms_${pkg}_${date}_${hour}"
        prefs.edit().putLong(hourKey, prefs.getLong(hourKey, 0L) + duration).apply()
        val deviceHourKey = "flutter.device_hourly_ms_${date}_${hour}"
        prefs.edit().putLong(deviceHourKey, prefs.getLong(deviceHourKey, 0L) + duration).apply()

        // Session duration bucket
        val bucketIdx = when {
            duration < 60_000L  -> 0   // < 1 min
            duration < 300_000L -> 1   // 1–5 min
            duration < 900_000L -> 2   // 5–15 min
            else                -> 3   // > 15 min
        }
        val bucketKey = "flutter.session_bucket_${bucketIdx}_${date}"
        prefs.edit().putLong(bucketKey, prefs.safeGetCount(bucketKey) + 1).apply()
    }

    private fun incrementOpenCount(pkg: String) {
        val date = today()
        val hour = currentHour()
        val key = "flutter.open_count_${pkg}_${date}"
        prefs.edit().putLong(key, prefs.safeGetCount(key) + 1).apply()
        val hourKey = "flutter.hourly_opens_${pkg}_${date}_${hour}"
        prefs.edit().putLong(hourKey, prefs.safeGetCount(hourKey) + 1).apply()
    }

    private fun getDailyMs(pkg: String): Long =
        prefs.getLong("flutter.daily_ms_${pkg}_${today()}", 0L)

    private fun getOpenCount(pkg: String): Int =
        prefs.safeGetCount("flutter.open_count_${pkg}_${today()}").toInt()

    private fun getUnlockCount(): Int =
        prefs.safeGetCount("flutter.unlock_count_${today()}").toInt()

    private fun getDeviceDailyMs(): Long =
        prefs.getLong("flutter.device_daily_ms_${today()}", 0L)

    // ── Formatação ────────────────────────────────────────────────────────────

    private fun formatTime(ms: Long): String {
        val totalSec = ms / 1000
        val hours = totalSec / 3600
        val mins = (totalSec % 3600) / 60
        val secs = totalSec % 60
        return if (hours > 0) "%d:%02d:%02d".format(hours, mins, secs)
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

    /** Read a counter written by either putLong (new) or putInt (legacy data). */
    private fun SharedPreferences.safeGetCount(key: String): Long =
        try { getLong(key, 0L) } catch (_: ClassCastException) { getInt(key, 0).toLong() }

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
