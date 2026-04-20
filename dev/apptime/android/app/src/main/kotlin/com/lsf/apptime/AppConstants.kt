package com.lsf.apptime

import android.content.SharedPreferences
import org.json.JSONArray

object AppConstants {

    const val CHANNEL = "apptime/service"

    /** Social/communication apps — used by OverlayService for wakeup-hour feedback. */
    val SOCIAL_PATTERNS: List<String> = listOf(
        "instagram", "tiktok", "twitter", "facebook", "snapchat",
        "reddit", "pinterest", "linkedin", "threads", "bluesky",
        "gmail", "outlook", "yahoo.mail", "protonmail",
        "whatsapp", "telegram", "signal", "discord"
    )

    val LAUNCHERS: Set<String> = setOf(
        "com.google.android.apps.nexuslauncher",
        "com.sec.android.app.launcher",
        "com.miui.home",
        "com.android.launcher",
        "com.android.launcher3",
        "com.huawei.android.launcher",
        "com.oneplus.launcher",
        "com.google.android.googlequicksearchbox",
    )

    /** Parse the disabled-apps set stored by Flutter as a plain JSON string via setString(). */
    fun parseDisabledApps(prefs: SharedPreferences): Set<String> {
        val raw = prefs.getString("flutter.disabled_apps", null) ?: return emptySet()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length())
                .map { arr.getString(it) }
                .filter { it.isNotEmpty() && it.matches(Regex("[a-zA-Z0-9_.]+")) }
                .toSet()
        } catch (_: Exception) { emptySet() }
    }
}
