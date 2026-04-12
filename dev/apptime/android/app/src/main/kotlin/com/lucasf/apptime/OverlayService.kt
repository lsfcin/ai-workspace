package com.lucasf.apptime

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.WindowManager
import android.widget.TextView
import androidx.core.app.NotificationCompat

class OverlayService : Service() {

    private val windowManager by lazy { getSystemService(WINDOW_SERVICE) as WindowManager }
    private lateinit var overlayView: TextView
    private val handler = Handler(Looper.getMainLooper())
    private var isViewAdded = false

    private val pollRunnable = object : Runnable {
        override fun run() {
            updateOverlay()
            handler.postDelayed(this, 500)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIF_ID, buildNotification())
        if (!isViewAdded) {
            addOverlayView()
            isViewAdded = true
        }
        handler.post(pollRunnable)
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(pollRunnable)
        if (isViewAdded) {
            windowManager.removeView(overlayView)
            isViewAdded = false
        }
        super.onDestroy()
    }

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
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 120
        }

        windowManager.addView(overlayView, params)
    }

    private fun updateOverlay() {
        if (!isViewAdded) return
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val text = prefs.getString("flutter.overlay_text", "") ?: ""
            val visible = prefs.getBoolean("flutter.overlay_visible", false)
            val showBg = prefs.getBoolean("flutter.overlay_show_background", false)
            val fontSize = readFloat(prefs, "flutter.overlay_font_size", 14f).coerceIn(10f, 18f)
            val topDp = readFloat(prefs, "flutter.overlay_top_dp", 40f).coerceIn(0f, 800f)
            val hPct = readFloat(prefs, "flutter.overlay_h_pct", 0f).coerceIn(0f, 1f)
            val anchor = prefs.getString("flutter.overlay_anchor", "left") ?: "left"

            overlayView.text = text
            overlayView.textSize = fontSize
            overlayView.visibility = if (visible && text.isNotEmpty()) android.view.View.VISIBLE
                                      else android.view.View.INVISIBLE
            overlayView.setBackgroundColor(
                if (showBg) Color.argb(160, 0, 0, 0) else Color.TRANSPARENT
            )

            val layoutParams = overlayView.layoutParams as WindowManager.LayoutParams
            val metrics = resources.displayMetrics
            val density = metrics.density

            // Sempre usa START gravity + x absoluto para evitar comportamento indefinido
            // com gravity END (x seria deslocamento da borda direita, causando overflow).
            layoutParams.gravity = when (anchor) {
                "bottom" -> Gravity.BOTTOM or Gravity.START
                else -> Gravity.TOP or Gravity.START
            }
            layoutParams.x = when (anchor) {
                "right" -> (metrics.widthPixels * (1f - hPct)).toInt()
                else -> (metrics.widthPixels * hPct).toInt()
            }
            layoutParams.y = (topDp * density).toInt()

            windowManager.updateViewLayout(overlayView, layoutParams)
        } catch (e: Exception) {
            // Swallow — próximo ciclo de 500ms tentará novamente
        }
    }

    /**
     * SharedPreferences não tem putDouble nativo. Flutter pode armazenar doubles
     * como Float, Long (bits) ou String dependendo da versão do plugin.
     * Tenta as três formas e usa o default se nenhuma funcionar.
     */
    private fun readFloat(prefs: android.content.SharedPreferences, key: String, default: Float): Float {
        val raw = prefs.all[key] ?: return default
        return when (raw) {
            is Float -> raw
            is Double -> raw.toFloat()
            is Long -> java.lang.Double.longBitsToDouble(raw).toFloat()
            is String -> raw.toFloatOrNull() ?: default
            else -> default
        }
    }

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
    }
}
