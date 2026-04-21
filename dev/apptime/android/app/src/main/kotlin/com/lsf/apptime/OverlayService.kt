package com.lsf.apptime

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
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
import android.widget.TextView
import androidx.core.app.NotificationCompat

class OverlayService : Service() {

    // ── Regular overlay (tiny counter in status-bar zone) ─────────────────────
    private lateinit var overlayView: TextView
    private lateinit var prefs: SharedPreferences
    private val handler = Handler(Looper.getMainLooper())
    private var isViewAdded = false

    // ── Feedback engine (F.BN / F.VW / F.PM) ─────────────────────────────────
    private lateinit var feedbackEngine: FeedbackEngine

    // ── Feedback evaluation every 5 poll ticks (~2.5 s) ──────────────────────
    private var evalTick = 0

    // ── Max overlay width in px (set once in addOverlayView) ─────────────────
    private var maxWidthPx = 0

    // ── Slide suppression — only reposition window when y actually changes ────
    private var lastTopY = -1

    // ── Poll loop ─────────────────────────────────────────────────────────────
    private val pollRunnable = object : Runnable {
        override fun run() {
            updateOverlay()
            if (++evalTick >= 5) {
                evalTick = 0
                feedbackEngine.evaluate()
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
        prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        if (!isViewAdded) addOverlayView()
        feedbackEngine = FeedbackEngine(
            view         = overlayView,
            handler      = handler,
            getViewAdded = { isViewAdded },
            setWindowWidth = ::setWindowWidth,
            getMaxWidthPx  = { maxWidthPx },
            getPrefs = { prefs },
        )
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
        super.onDestroy()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Regular overlay (counter)
    // ─────────────────────────────────────────────────────────────────────────

    private val windowManager by lazy { getSystemService(WINDOW_SERVICE) as WindowManager }

    private fun addOverlayView() {
        val screenWidthPx = resources.displayMetrics.widthPixels
        maxWidthPx = (screenWidthPx * 0.88f).toInt()

        overlayView = TextView(this).apply {
            text = ""
            textSize = 14f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            setShadowLayer(3f, 1f, 1f, Color.BLACK)
            setPadding(16, 8, 16, 8)
            maxWidth = maxWidthPx
            setSingleLine(false)
            scaleX = 1f
            scaleY = 1f
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
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

        val showBg     = prefs.getBoolean("flutter.overlay_show_background", true)
        val showBorder = prefs.getBoolean("flutter.overlay_show_border", true)
        val topDp      = readFloat(prefs, "flutter.overlay_top_dp", 40f).coerceIn(0f, 800f)
        val density    = resources.displayMetrics.density

        // Font size stored as Int for cross-process reliability;
        // fall back to readFloat for any existing Float/Double legacy data.
        // Flutter shared_preferences stores int as Long on Android; use getLong().toInt().
        val fontSizeBase = run {
            val asLong = try { prefs.getLong("flutter.overlay_font_size", 0L) }
                         catch (_: ClassCastException) { 0L }
            if (asLong > 0L) asLong.toFloat()
            else readFloat(prefs, "flutter.overlay_font_size", 14f)
        }.coerceIn(10f, 30f)

        val fontSize = fontSizeBase * feedbackEngine.visualWeightMult

        overlayView.textSize = fontSize
        overlayView.scaleX = 1f   // never use view scale — font size does the work
        overlayView.scaleY = 1f

        val bg = GradientDrawable().apply {
            cornerRadius = 8f * density
            setColor(if (showBg) Color.argb(160, 0, 0, 0) else Color.TRANSPARENT)
            if (showBorder) setStroke((1.5f * density).toInt(), Color.WHITE)
        }
        overlayView.background = bg

        // Only reposition the window when y actually changed — calling
        // updateViewLayout every tick causes the OS to re-center WRAP_CONTENT
        // width on each frame, producing a subtle lateral slide.
        if (!feedbackEngine.pmActive) {
            try {
                val lp = overlayView.layoutParams as WindowManager.LayoutParams
                val newY = (topDp * density).toInt()
                if (newY != lastTopY) {
                    lp.y = newY
                    lastTopY = newY
                    windowManager.updateViewLayout(overlayView, lp)
                }
            } catch (_: Exception) {
                isViewAdded = false
                return
            }
        }

        if (feedbackEngine.pmActive) return   // PM owns text and visibility

        val text           = prefs.getString("flutter.overlay_text", "") ?: ""
        val visible        = prefs.getBoolean("flutter.overlay_visible", false)
        val overlayEnabled = prefs.getBoolean("flutter.overlay_enabled", true)
        val currentPkg    = prefs.getString("flutter.current_pkg", null)
        val isUnmonitored = currentPkg != null &&
            AppConstants.parseDisabledApps(prefs).contains(currentPkg)
        val shouldShow    = overlayEnabled && visible && text.isNotEmpty() && !isUnmonitored

        overlayView.text = text
        if (!feedbackEngine.breathingActive && !feedbackEngine.pmActive) overlayView.alpha = 1f
        overlayView.visibility = if (shouldShow) View.VISIBLE else View.INVISIBLE

        if (feedbackEngine.pmJustEnded && shouldShow) {
            feedbackEngine.pmJustEnded = false
            feedbackEngine.fadeInView(500L)
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Window width helper
    // ─────────────────────────────────────────────────────────────────────────

    private fun setWindowWidth(widthPx: Int) {
        if (!isViewAdded) return
        try {
            val lp = overlayView.layoutParams as WindowManager.LayoutParams
            lp.width = widthPx
            windowManager.updateViewLayout(overlayView, lp)
        } catch (_: Exception) {}
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    private fun readFloat(prefs: SharedPreferences, key: String, default: Float): Float {
        val raw = prefs.all[key] ?: return default
        return when (raw) {
            is Float  -> raw
            is Double -> raw.toFloat()
            is Long   -> java.lang.Double.longBitsToDouble(raw).toFloat()
            is Int    -> raw.toFloat()
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
                NotificationChannel(channelId, "AppTime Overlay",
                    NotificationManager.IMPORTANCE_MIN)
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
    }
}
