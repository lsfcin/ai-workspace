package com.lsf.apptime

import android.content.SharedPreferences
import java.util.Calendar

object DateUtils {

    /** 4 AM-anchored today key — hours 00–03 belong to the previous calendar day. */
    fun today(): String {
        val c = Calendar.getInstance()
        if (c.get(Calendar.HOUR_OF_DAY) < 4) c.add(Calendar.DATE, -1)
        return "%04d-%02d-%02d".format(
            c.get(Calendar.YEAR),
            c.get(Calendar.MONTH) + 1,
            c.get(Calendar.DAY_OF_MONTH)
        )
    }

    fun currentHour(): Int = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
}

/** Read a counter written by either putLong (new) or putInt (legacy data). */
fun SharedPreferences.safeGetCount(key: String): Long =
    try { getLong(key, 0L) } catch (_: ClassCastException) { getInt(key, 0).toLong() }
