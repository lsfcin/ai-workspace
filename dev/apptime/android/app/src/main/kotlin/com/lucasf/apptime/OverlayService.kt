package com.lucasf.apptime

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ObjectAnimator
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.TextView
import androidx.core.app.NotificationCompat

class OverlayService : Service() {

    // ── Regular overlay (tiny counter in status-bar zone) ─────────────────────
    private lateinit var overlayView: TextView
    private val handler = Handler(Looper.getMainLooper())
    private var isViewAdded = false

    // ── F.PM — personalized-message overlay (full-width, centered) ────────────
    private var pmView: TextView? = null
    private var isPmViewAdded = false
    private var pmActive = false
    private var pmCooldownUntil = 0L

    // ── F.BN — breathing-nudge state ──────────────────────────────────────────
    private var breathingActive = false

    // ── Unlock tracking for F.PM-on-unlock ───────────────────────────────────
    private var lastSeenUnlockCount = 0

    // ── Feedback evaluation every 5 poll ticks (~2.5 s) ──────────────────────
    private var evalTick = 0

    // ── Poll loop ─────────────────────────────────────────────────────────────
    private val pollRunnable = object : Runnable {
        override fun run() {
            updateOverlay()
            if (++evalTick >= 5) {
                evalTick = 0
                evaluateFeedbacks()
            }
            handler.postDelayed(this, 500)
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Lifecycle
    // ─────────────────────────────────────────────────────────────────────────

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIF_ID, buildNotification())
        if (!isViewAdded) addOverlayView()
        handler.removeCallbacks(pollRunnable)
        handler.post(pollRunnable)
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        if (isViewAdded) {
            try { windowManager.removeView(overlayView) } catch (_: Exception) {}
            isViewAdded = false
        }
        removePmView()
        super.onDestroy()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Regular overlay (counter)
    // ─────────────────────────────────────────────────────────────────────────

    private val windowManager by lazy { getSystemService(WINDOW_SERVICE) as WindowManager }

    private fun addOverlayView() {
        overlayView = TextView(this).apply {
            text = ""
            textSize = 14f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            setShadowLayer(3f, 1f, 1f, Color.BLACK)
            setPadding(12, 6, 12, 6)
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            x = 0
            y = 120
        }
        try {
            windowManager.addView(overlayView, params)
            isViewAdded = true
        } catch (e: Exception) {
            isViewAdded = false
        }
    }

    private fun updateOverlay() {
        if (!isViewAdded) return
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val text    = prefs.getString("flutter.overlay_text", "") ?: ""
        val visible = prefs.getBoolean("flutter.overlay_visible", false)
        val showBg  = prefs.getBoolean("flutter.overlay_show_background", false)
        val showBorder = prefs.getBoolean("flutter.overlay_show_border", false)
        val fontSize   = readFloat(prefs, "flutter.overlay_font_size", 14f).coerceIn(10f, 30f)
        val topDp      = readFloat(prefs, "flutter.overlay_top_dp", 40f).coerceIn(0f, 800f)

        overlayView.text = text
        overlayView.textSize = fontSize
        overlayView.visibility = if (visible && text.isNotEmpty()) View.VISIBLE else View.INVISIBLE

        val density = resources.displayMetrics.density
        val bg = GradientDrawable().apply {
            cornerRadius = 8f * density
            setColor(if (showBg) Color.argb(160, 0, 0, 0) else Color.TRANSPARENT)
            if (showBorder) setStroke((1.5f * density).toInt(), Color.WHITE)
        }
        overlayView.background = bg

        try {
            val lp = overlayView.layoutParams as WindowManager.LayoutParams
            lp.gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            lp.x = 0
            lp.y = (topDp * density).toInt()
            windowManager.updateViewLayout(overlayView, lp)
        } catch (e: Exception) {
            isViewAdded = false
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Feedback evaluation
    // ─────────────────────────────────────────────────────────────────────────

    private fun evaluateFeedbacks() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val goalLevel = prefs.getInt("flutter.goal_level", 0)

        if (goalLevel == 0) {
            stopBreathing()
            resetScale()
            return
        }

        val thresholds = GoalThresholds.forLevel(goalLevel)
        val lang = prefs.getString("flutter.language_code", "pt") ?: "pt"
        val date = today()
        val hour = currentHour()
        val now  = System.currentTimeMillis()

        val pkg = prefs.getString("flutter.current_pkg", null)
        val isLauncher = pkg != null && MonitoringService.LAUNCHERS.contains(pkg)
        val sessionStartMs = prefs.getLong("flutter.current_session_start_ms", now)
        val sessionMs = if (pkg != null) (now - sessionStartMs).coerceAtLeast(0L) else 0L

        // ── Metrics ──────────────────────────────────────────────────────────

        val deviceMs  = prefs.getLong("flutter.device_daily_ms_$date", 0L)
        val unlocks   = prefs.getInt("flutter.unlock_count_$date", 0)
        val appMs     = if (pkg != null && !isLauncher)
            prefs.getLong("flutter.daily_ms_${pkg}_$date", 0L) else 0L

        val appGoalLevel = if (pkg != null && !isLauncher)
            prefs.getInt("flutter.app_goal_$pkg", 0).let { if (it == 0) goalLevel else it }
        else goalLevel
        val appThresholds = GoalThresholds.forLevel(appGoalLevel)

        // Percentages (100 = at limit, 200 = doubled)
        val phonePct   = if (thresholds.phoneLimitMs > 0)
            (deviceMs  * 100 / thresholds.phoneLimitMs).toInt()  else 0
        val appPct     = if (appThresholds.appLimitMs > 0 && pkg != null && !isLauncher)
            (appMs     * 100 / appThresholds.appLimitMs).toInt() else 0
        val sessionPct = if (thresholds.maxSessionMs > 0 && pkg != null && !isLauncher)
            (sessionMs * 100 / thresholds.maxSessionMs).toInt()  else 0

        val inSleepWindow  = (thresholds.sleepCutoffHour > 0) &&
                (hour >= thresholds.sleepCutoffHour || hour < 6)
        val inWakeupWindow = (thresholds.wakeupHour > 0) && (hour < thresholds.wakeupHour)
        val isSocialApp    = pkg != null && SOCIAL_PATTERNS.any { pkg.contains(it) }

        // ── Determine feedbacks ───────────────────────────────────────────────

        var wantBn = false
        var wantVw = false
        var maxPct = 0
        var pmMessage: String? = null

        // 24h phone time
        if (phonePct >= 100) {
            wantBn = true; maxPct = maxOf(maxPct, phonePct)
            if (phonePct >= 200) { wantVw = true; pmMessage = pmMessage ?: PmMessages.phoneTimeExceeded(lang) }
        }
        // App-specific 24h limit
        if (appPct >= 100 && pkg != null && !isLauncher) {
            wantBn = true; maxPct = maxOf(maxPct, appPct)
            if (appPct >= 200) {
                wantVw = true
                pmMessage = pmMessage ?: PmMessages.appLimitExceeded(lang, pkg.split(".").last())
            }
        }
        // Max session
        if (sessionPct >= 100 && pkg != null && !isLauncher) {
            wantBn = true; maxPct = maxOf(maxPct, sessionPct)
            if (sessionPct >= 200) { wantVw = true; pmMessage = pmMessage ?: PmMessages.sessionExceeded(lang) }
        }
        // Sleeping hours
        if (inSleepWindow && pkg != null && !isLauncher) {
            wantVw = true
            pmMessage = pmMessage ?: PmMessages.sleepingHours(lang)
        }
        // Wakeup + social
        if (inWakeupWindow && isSocialApp) {
            wantVw = true
            pmMessage = pmMessage ?: PmMessages.wakeupSocial(lang)
        }

        // ── Unlock trigger (F.PM 3 s after new unlock when over limit) ───────
        val currentUnlocks = prefs.getInt("flutter.unlock_count_$date", 0)
        if (currentUnlocks > lastSeenUnlockCount) {
            lastSeenUnlockCount = currentUnlocks
            if (currentUnlocks > thresholds.unlockLimit) {
                val msg = PmMessages.unlockExceeded(lang)
                handler.postDelayed({ triggerPm(msg) }, 3_000L)
            }
        }

        // ── Apply ─────────────────────────────────────────────────────────────
        if (wantBn) startBreathing() else stopBreathing()
        if (wantVw) applyVisualWeight(maxPct) else resetScale()
        if (pmMessage != null) triggerPm(pmMessage)
    }

    // ─────────────────────────────────────────────────────────────────────────
    // F.BN — Breathing Nudge
    // ─────────────────────────────────────────────────────────────────────────

    private fun startBreathing() {
        if (breathingActive) return
        breathingActive = true
        scheduleBreathe()
    }

    private fun stopBreathing() {
        breathingActive = false
        if (isViewAdded) overlayView.alpha = 1f
    }

    private fun scheduleBreathe() {
        if (!breathingActive || !isViewAdded) return
        val fadeInMs  = (2_000L..3_000L).random()
        val stayMs    = (1_000L..3_000L).random()
        val fadeOutMs = (2_000L..3_000L).random()
        val hiddenMs  = (5_000L..15_000L).random()

        animateAlpha(overlayView, 0f, 1f, fadeInMs) {
            handler.postDelayed({
                if (!breathingActive) return@postDelayed
                animateAlpha(overlayView, 1f, 0f, fadeOutMs) {
                    overlayView.alpha = 0f
                    handler.postDelayed({
                        if (breathingActive) scheduleBreathe()
                        else overlayView.alpha = 1f
                    }, hiddenMs)
                }
            }, stayMs)
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // F.VW — Visual Weight
    // ─────────────────────────────────────────────────────────────────────────

    private fun applyVisualWeight(pct: Int) {
        if (!isViewAdded) return
        // 80 % → 1.0×  …  100 % → 1.2×  (capped)
        val scale = (1f + ((pct - 80).coerceAtLeast(0) * 0.01f)).coerceAtMost(1.2f)
        overlayView.scaleX = scale
        overlayView.scaleY = scale
    }

    private fun resetScale() {
        if (isViewAdded) {
            overlayView.scaleX = 1f
            overlayView.scaleY = 1f
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // F.PM — Personalized Message
    // ─────────────────────────────────────────────────────────────────────────

    private fun addPmView() {
        if (isPmViewAdded) return
        pmView = TextView(this).apply {
            setTextColor(Color.WHITE)
            textSize = 15f
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(32, 20, 32, 20)
            val bg = GradientDrawable().apply {
                cornerRadius = 16f * resources.displayMetrics.density
                setColor(Color.argb(220, 10, 10, 20))
            }
            background = bg
            alpha = 0f
            visibility = View.INVISIBLE
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }
        try {
            windowManager.addView(pmView, params)
            isPmViewAdded = true
        } catch (e: Exception) {
            isPmViewAdded = false
        }
    }

    private fun removePmView() {
        if (isPmViewAdded && pmView != null) {
            try { windowManager.removeView(pmView) } catch (_: Exception) {}
        }
        pmView = null
        isPmViewAdded = false
    }

    private fun triggerPm(message: String) {
        val now = System.currentTimeMillis()
        if (now < pmCooldownUntil) return
        if (pmActive) return
        pmActive = true
        pmCooldownUntil = now + 60_000L

        addPmView()
        val view = pmView ?: run { pmActive = false; return }

        view.text = message
        view.alpha = 0f
        view.visibility = View.VISIBLE

        // 3 s fade-in → 10 s stay → 3 s fade-out
        animateAlpha(view, 0f, 1f, 3_000L) {
            handler.postDelayed({
                animateAlpha(view, 1f, 0f, 3_000L) {
                    view.visibility = View.INVISIBLE
                    pmActive = false
                }
            }, 10_000L)
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Animation helper
    // ─────────────────────────────────────────────────────────────────────────

    private fun animateAlpha(view: View, from: Float, to: Float, durationMs: Long, onEnd: () -> Unit) {
        ObjectAnimator.ofFloat(view, View.ALPHA, from, to).apply {
            duration = durationMs
            interpolator = AccelerateDecelerateInterpolator()
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) = onEnd()
            })
            start()
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    private fun today(): String {
        val c = java.util.Calendar.getInstance()
        return "%04d-%02d-%02d".format(
            c.get(java.util.Calendar.YEAR),
            c.get(java.util.Calendar.MONTH) + 1,
            c.get(java.util.Calendar.DAY_OF_MONTH)
        )
    }

    private fun currentHour(): Int =
        java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY)

    private fun readFloat(prefs: android.content.SharedPreferences, key: String, default: Float): Float {
        val raw = prefs.all[key] ?: return default
        return when (raw) {
            is Float  -> raw
            is Double -> raw.toFloat()
            is Long   -> java.lang.Double.longBitsToDouble(raw).toFloat()
            is String -> raw.toFloatOrNull() ?: default
            else      -> default
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Notification
    // ─────────────────────────────────────────────────────────────────────────

    private fun buildNotification(): Notification {
        val channelId = "apptime_overlay"
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(channelId) == null) {
            manager.createNotificationChannel(
                NotificationChannel(channelId, "AppTime Overlay", NotificationManager.IMPORTANCE_MIN)
            )
        }
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("AppTime ativo")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .build()
    }

    companion object {
        const val NOTIF_ID = 1001

        /** Package-name fragments that identify social/passive apps. */
        val SOCIAL_PATTERNS = listOf(
            "instagram", "tiktok", "twitter", "facebook", "snapchat",
            "reddit", "pinterest", "linkedin", "threads", "bluesky",
            "gmail", "outlook", "yahoo.mail", "protonmail",
            "whatsapp", "telegram", "signal", "discord"
        )
    }
}
