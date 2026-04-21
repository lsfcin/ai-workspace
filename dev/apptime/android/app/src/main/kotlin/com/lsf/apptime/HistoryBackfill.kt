package com.lsf.apptime

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.SharedPreferences

private data class Seg(val pkg: String, val startMs: Long, val endMs: Long)

/**
 * Fills in usage data for periods when MonitoringService was not running.
 *
 * Constructed with injectable dependencies so this logic can be unit-tested
 * independently of the Android service lifecycle.
 */
class HistoryBackfill(
    private val usageStats: UsageStatsManager,
    private val prefs: SharedPreferences,
    private val accumulate: (String, Long, Long) -> Unit,
    private val epochToDate: (Long) -> String,
) {
    companion object {
        // Key used to persist the last-alive timestamp so gap detection survives
        // process death (service killed, device reboot, crash, etc.)
        const val HEARTBEAT_KEY = "flutter.monitoring_heartbeat_ms"
    }

    /**
     * Replays usage events for any gap between the last heartbeat and now.
     * [gapThresholdMs] defines how large a gap must be before we attempt backfill
     * (10 s covers normal poll jitter; anything larger is a real gap).
     */
    fun backfillGap(gapThresholdMs: Long) {
        val lastHeartbeat = prefs.getLong(HEARTBEAT_KEY, 0L)
        val now = System.currentTimeMillis()

        val gapStart = if (lastHeartbeat == 0L) {
            // Fresh install / first ever run: fill from today's 4am boundary.
            java.util.Calendar.getInstance().apply {
                if (get(java.util.Calendar.HOUR_OF_DAY) < 4) add(java.util.Calendar.DATE, -1)
                set(java.util.Calendar.HOUR_OF_DAY, 4)
                set(java.util.Calendar.MINUTE, 0)
                set(java.util.Calendar.SECOND, 0)
                set(java.util.Calendar.MILLISECOND, 0)
            }.timeInMillis
        } else {
            if ((now - lastHeartbeat) < gapThresholdMs) return
            lastHeartbeat
        }

        val events = usageStats.queryEvents(gapStart, now)
        val event = UsageEvents.Event()
        val segments = mutableListOf<Seg>()
        var lastFgPkg: String? = null
        var lastFgTs = gapStart

        while (events.getNextEvent(event)) {
            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    if (lastFgPkg != null && event.timeStamp > lastFgTs)
                        segments += Seg(lastFgPkg!!, lastFgTs, event.timeStamp)
                    lastFgPkg = event.packageName
                    lastFgTs = event.timeStamp
                }
                UsageEvents.Event.MOVE_TO_BACKGROUND,
                UsageEvents.Event.SCREEN_NON_INTERACTIVE -> {
                    if (lastFgPkg != null && event.timeStamp > lastFgTs) {
                        segments += Seg(lastFgPkg!!, lastFgTs, event.timeStamp)
                        lastFgPkg = null
                    }
                }
            }
        }
        if (lastFgPkg != null && now > lastFgTs)
            segments += Seg(lastFgPkg!!, lastFgTs, now)

        for (seg in segments) accumulate(seg.pkg, seg.startMs, seg.endMs)
    }

    /**
     * Scans the last 30 days for days with no recorded data and fills them from
     * Android's UsageStatsManager. Recent days get full per-app/per-hour detail
     * via queryEvents; older days fall back to queryUsageStats(INTERVAL_DAILY).
     * Runs at most once per day in a background thread.
     */
    fun backfillHistory() {
        val now = System.currentTimeMillis()
        val lastRun = prefs.getLong("flutter.history_backfill_ts", 0L)
        if (now - lastRun < 23 * 3_600_000L) return
        prefs.edit().putLong("flutter.history_backfill_ts", now).apply()

        Thread {
            for (i in 1..30) {
                val cal = java.util.Calendar.getInstance().apply {
                    timeInMillis = now
                    add(java.util.Calendar.DATE, -i)
                    set(java.util.Calendar.HOUR_OF_DAY, 4)
                    set(java.util.Calendar.MINUTE, 0)
                    set(java.util.Calendar.SECOND, 0)
                    set(java.util.Calendar.MILLISECOND, 0)
                }
                val dayStart = cal.timeInMillis
                val dayEnd   = dayStart + 24 * 3_600_000L
                val dateKey  = epochToDate(dayStart)
                if (hasAnyDataForDate(dateKey)) continue
                if (!backfillDayFromEvents(dateKey, dayStart, dayEnd))
                    backfillDayFromStats(dateKey, dayStart, dayEnd)
            }
        }.start()
    }

    private fun hasAnyDataForDate(dateKey: String): Boolean {
        if (prefs.getLong("flutter.device_daily_ms_$dateKey", 0L) > 0L) return true
        return prefs.all.keys.any { it.startsWith("flutter.daily_ms_") && it.endsWith("_$dateKey") }
    }

    /** Replays UsageEvents for [start, end) into accumulate. Returns true if any data found. */
    private fun backfillDayFromEvents(dateKey: String, start: Long, end: Long): Boolean {
        val events = usageStats.queryEvents(start, end)
        val event = UsageEvents.Event()
        val segments = mutableListOf<Seg>()
        var lastFgPkg: String? = null
        var lastFgTs = start

        while (events.getNextEvent(event)) {
            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    if (lastFgPkg != null && event.timeStamp > lastFgTs)
                        segments += Seg(lastFgPkg!!, lastFgTs, event.timeStamp)
                    lastFgPkg = event.packageName
                    lastFgTs = event.timeStamp
                }
                UsageEvents.Event.MOVE_TO_BACKGROUND,
                UsageEvents.Event.SCREEN_NON_INTERACTIVE -> {
                    if (lastFgPkg != null && event.timeStamp > lastFgTs) {
                        segments += Seg(lastFgPkg!!, lastFgTs, event.timeStamp)
                        lastFgPkg = null
                    }
                }
            }
        }
        if (lastFgPkg != null && end > lastFgTs)
            segments += Seg(lastFgPkg!!, lastFgTs, end)

        if (segments.isEmpty()) return false
        for (seg in segments) accumulate(seg.pkg, seg.startMs, seg.endMs)
        return true
    }

    /** Falls back to aggregated daily stats when event log has been trimmed by Android. */
    private fun backfillDayFromStats(dateKey: String, start: Long, end: Long) {
        val statsList = usageStats.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, start, end)
        var deviceTotal = 0L
        for (stats in statsList) {
            val ms = stats.totalTimeInForeground
            if (ms <= 0L) continue
            val key = "flutter.daily_ms_${stats.packageName}_$dateKey"
            prefs.edit().putLong(key, prefs.getLong(key, 0L) + ms).apply()
            deviceTotal += ms
        }
        if (deviceTotal > 0L) {
            val key = "flutter.device_daily_ms_$dateKey"
            prefs.edit().putLong(key, prefs.getLong(key, 0L) + deviceTotal).apply()
        }
    }
}
