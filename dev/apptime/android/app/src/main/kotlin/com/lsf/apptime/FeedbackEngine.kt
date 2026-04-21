package com.lsf.apptime

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ObjectAnimator
import android.content.SharedPreferences
import android.os.Handler
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.TextView

/**
 * Encapsulates all feedback evaluation and animation logic (F.BN, F.VW, F.PM)
 * independently of the Android service lifecycle. Constructed with injectable
 * dependencies so this logic can be unit-tested without a running OverlayService.
 */
class FeedbackEngine(
    private val view: TextView,
    private val handler: Handler,
    private val getViewAdded: () -> Boolean,
    private val setWindowWidth: (Int) -> Unit,
    private val getMaxWidthPx: () -> Int,
    private val getPrefs: () -> SharedPreferences,
) {
    var pmActive = false
        private set
    var pmJustEnded = false
    var breathingActive = false
        private set
    var visualWeightMult: Float = 1f
        private set

    private var pmCooldownUntil = 0L
    private var pmQueue: List<String> = emptyList()
    private var pmQueueIdx: Int = 0
    private var breathingAnimator: ObjectAnimator? = null
    private var pmAnimator: ObjectAnimator? = null
    private var lastSeenUnlockCount = 0

    fun evaluate() {
        val prefs = getPrefs()
        val goalLevel = prefs.safeGetCount("flutter.goal_level").toInt()

        if (goalLevel == 0) {
            stopBreathing()
            resetVisualWeight()
            return
        }

        val pkg = prefs.getString("flutter.current_pkg", null)
        val isLauncher = pkg != null && AppConstants.LAUNCHERS.contains(pkg)

        if (pkg != null && !isLauncher &&
            AppConstants.parseDisabledApps(prefs).contains(pkg)) {
            stopBreathing()
            resetVisualWeight()
            return
        }

        val thresholds = GoalThresholds.forLevel(goalLevel)
        val lang = prefs.getString("flutter.language_code", "pt") ?: "pt"
        val date = DateUtils.today()
        val hour = DateUtils.currentHour()
        val now  = System.currentTimeMillis()
        val sessionStartMs = prefs.getLong("flutter.current_session_start_ms", now)
        val sessionMs = if (pkg != null) (now - sessionStartMs).coerceAtLeast(0L) else 0L

        val deviceMs = prefs.getLong("flutter.device_daily_ms_$date", 0L)
        val appMs    = if (pkg != null && !isLauncher)
            prefs.getLong("flutter.daily_ms_${pkg}_$date", 0L) else 0L

        val appGoalLevel = if (pkg != null && !isLauncher)
            prefs.safeGetCount("flutter.app_goal_$pkg").toInt()
                .let { if (it == 0) goalLevel else it }
        else goalLevel
        val appThresholds = GoalThresholds.forLevel(appGoalLevel)

        val phonePct   = if (thresholds.phoneLimitMs > 0)
            (deviceMs  * 100 / thresholds.phoneLimitMs).toInt()  else 0
        val appPct     = if (appThresholds.appLimitMs > 0 && pkg != null && !isLauncher)
            (appMs     * 100 / appThresholds.appLimitMs).toInt() else 0
        val sessionPct = if (thresholds.maxSessionMs > 0 && pkg != null && !isLauncher)
            (sessionMs * 100 / thresholds.maxSessionMs).toInt()  else 0

        val inSleepWindow  = (thresholds.sleepCutoffHour > 0) && when {
            thresholds.sleepCutoffHour >= 18 -> hour >= thresholds.sleepCutoffHour || hour < 6
            else -> hour >= thresholds.sleepCutoffHour && hour < 6
        }
        val inWakeupWindow = (thresholds.wakeupHour > 0) && (hour < thresholds.wakeupHour)
        val isSocialApp    = pkg != null && AppConstants.SOCIAL_PATTERNS.any { pkg.contains(it) }

        var wantBn = false
        var wantVw = false
        var maxPct = 0
        val pendingMessages = mutableListOf<String>()

        if (phonePct >= 100) {
            wantBn = true; maxPct = maxOf(maxPct, phonePct)
            if (phonePct >= 200) { wantVw = true; pendingMessages += PmMessages.phoneTimeExceeded(lang) }
        }
        if (appPct >= 100 && pkg != null && !isLauncher) {
            wantBn = true; maxPct = maxOf(maxPct, appPct)
            if (appPct >= 200) {
                wantVw = true
                pendingMessages += PmMessages.appLimitExceeded(lang, pkg.split(".").last())
            }
        }
        if (sessionPct >= 100 && pkg != null && !isLauncher) {
            wantBn = true; maxPct = maxOf(maxPct, sessionPct)
            if (sessionPct >= 200) { wantVw = true; pendingMessages += PmMessages.sessionExceeded(lang) }
        }
        if (inSleepWindow && pkg != null && !isLauncher) {
            wantVw = true
            pendingMessages += PmMessages.sleepingHours(lang)
        }
        if (inWakeupWindow && isSocialApp) {
            wantVw = true
            pendingMessages += PmMessages.wakeupSocial(lang)
        }

        if (pendingMessages != pmQueue) {
            pmQueue = pendingMessages
            pmQueueIdx = 0
        }

        val currentUnlocks = prefs.safeGetCount("flutter.unlock_count_$date").toInt()
        if (currentUnlocks > lastSeenUnlockCount) {
            lastSeenUnlockCount = currentUnlocks
            if (currentUnlocks > thresholds.unlockLimit) {
                val msg = PmMessages.unlockExceeded(lang)
                handler.postDelayed({ triggerPm(msg) }, 3_000L)
            }
        }

        if (wantBn) startBreathing() else stopBreathing()
        if (wantVw) applyVisualWeight(maxPct) else resetVisualWeight()
        if (pmQueue.isNotEmpty()) {
            val msg = pmQueue[pmQueueIdx % pmQueue.size]
            if (triggerPm(msg)) pmQueueIdx = (pmQueueIdx + 1) % pmQueue.size
        }
    }

    /** Called by OverlayService.updateOverlay() when pmJustEnded is true and overlay should show. */
    fun fadeInView(durationMs: Long) {
        animatePm(view, 0f, 1f, durationMs) {}
    }

    // ── F.BN — Breathing Nudge ─────────────────────────────────────────────────

    private fun startBreathing() {
        if (breathingActive || pmActive) return
        breathingActive = true
        scheduleBreathe()
    }

    private fun stopBreathing() {
        breathingActive = false
        if (!pmActive) {
            breathingAnimator?.cancel()
            breathingAnimator = null
            if (getViewAdded() && !pmJustEnded) {
                val from = view.alpha
                if (from < 1f) animateBreathe(view, from, 1f, 400L) {}
                else view.alpha = 1f
            }
        }
    }

    private fun scheduleBreathe() {
        if (!breathingActive || !getViewAdded() || pmActive) return
        val fadeOutMs = (2_000L..3_000L).random()
        val fadeInMs  = (2_000L..3_000L).random()

        animateBreathe(view, 1f, DIM_ALPHA, fadeOutMs) {
            if (!breathingActive || pmActive) return@animateBreathe
            animateBreathe(view, DIM_ALPHA, 1f, fadeInMs) {
                if (breathingActive) scheduleBreathe()
            }
        }
    }

    // ── F.VW — Visual Weight ───────────────────────────────────────────────────

    private fun applyVisualWeight(pct: Int) {
        // 80% → 1.0×  …  100% → 1.2×  …  200% → 1.5× (capped)
        visualWeightMult = (1f + ((pct - 80).coerceAtLeast(0) * 0.007f)).coerceAtMost(1.5f)
    }

    private fun resetVisualWeight() {
        visualWeightMult = 1f
    }

    // ── F.PM — Personalized Message ────────────────────────────────────────────

    private fun triggerPm(message: String): Boolean {
        val now = System.currentTimeMillis()
        if (now < pmCooldownUntil) return false
        if (pmActive) return false
        if (!getViewAdded()) return false
        val prefs = getPrefs()
        if (!prefs.getBoolean("flutter.overlay_enabled", true)) return false

        pmActive = true
        pmCooldownUntil = now + 60_000L
        breathingActive = false
        breathingAnimator?.cancel()
        breathingAnimator = null

        val fontSizeBase = readFloat(prefs, "flutter.overlay_font_size", 14f).coerceIn(10f, 30f)
        val pmFontSize = (fontSizeBase - 2f).coerceAtLeast(11f)

        setWindowWidth(getMaxWidthPx())

        val startAlpha = if (view.visibility == View.VISIBLE) view.alpha else 0f
        animatePm(view, startAlpha, 0f, 400L) {
            view.textSize = pmFontSize
            view.text = message
            view.visibility = View.VISIBLE
            animatePm(view, 0f, 1f, 800L) {
                handler.postDelayed({
                    if (!pmActive) return@postDelayed
                    animatePm(view, 1f, 0f, 800L) {
                        view.textSize = fontSizeBase
                        setWindowWidth(WindowManager.LayoutParams.WRAP_CONTENT)
                        pmActive = false
                        pmJustEnded = true
                    }
                }, 20_000L)
            }
        }
        return true
    }

    // ── Animation helpers ──────────────────────────────────────────────────────

    private fun animateBreathe(view: View, from: Float, to: Float,
                               durationMs: Long, onEnd: () -> Unit) {
        breathingAnimator?.cancel()
        var cancelled = false
        breathingAnimator = ObjectAnimator.ofFloat(view, View.ALPHA, from, to).apply {
            duration = durationMs
            interpolator = AccelerateDecelerateInterpolator()
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(a: Animator) {
                    if (a == breathingAnimator) breathingAnimator = null
                    if (!cancelled) onEnd()
                }
                override fun onAnimationCancel(a: Animator) {
                    if (a == breathingAnimator) breathingAnimator = null
                    cancelled = true
                }
            })
            start()
        }
    }

    private fun animatePm(view: View, from: Float, to: Float,
                          durationMs: Long, onEnd: () -> Unit) {
        pmAnimator?.cancel()
        var cancelled = false
        pmAnimator = ObjectAnimator.ofFloat(view, View.ALPHA, from, to).apply {
            duration = durationMs
            interpolator = AccelerateDecelerateInterpolator()
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(a: Animator) {
                    if (a == pmAnimator) pmAnimator = null
                    if (!cancelled) onEnd()
                }
                override fun onAnimationCancel(a: Animator) {
                    if (a == pmAnimator) pmAnimator = null
                    cancelled = true
                }
            })
            start()
        }
    }

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

    companion object {
        const val DIM_ALPHA = 0.35f
    }
}
