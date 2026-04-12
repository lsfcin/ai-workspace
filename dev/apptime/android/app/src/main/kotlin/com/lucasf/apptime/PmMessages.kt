package com.lucasf.apptime

/**
 * Pre-defined F.PM messages — max 2 lines, 4 words per line.
 * Kind tone, research-backed.
 */
object PmMessages {

    /** 24h total phone time doubled the limit. */
    fun phoneTimeExceeded(lang: String): String =
        if (lang == "en") "Screen time\nexceeded today."
        else              "Tempo de tela\nexcedido hoje."

    /** Per-app 24h limit doubled. [appName] = last segment of package. */
    fun appLimitExceeded(lang: String, appName: String): String =
        if (lang == "en") "$appName: daily\nlimit reached."
        else              "$appName: limite\natingido hoje."

    /** Current session doubled the max-session limit. */
    fun sessionExceeded(lang: String): String =
        if (lang == "en") "Time for\na break?"
        else              "Pausa agora?\nSeus olhos pedem."

    /** Phone used after sleep-cutoff hour. */
    fun sleepingHours(lang: String): String =
        if (lang == "en") "Sleep suffers\nfrom screens."
        else              "Sono prejudicado\npor telas."

    /** Social app opened before wakeup-hour threshold. */
    fun wakeupSocial(lang: String): String =
        if (lang == "en") "Start your day\nscreen-free."
        else              "Comece o dia\nsem redes sociais."

    /** Triggered 3 s after an unlock when unlock count exceeds limit. */
    fun unlockExceeded(lang: String): String =
        if (lang == "en") "Worth opening?\nBe intentional."
        else              "Vale abrir?\nSeja intencional."
}
