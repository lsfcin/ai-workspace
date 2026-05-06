package com.lsf.apptime

/**
 * F.PM messages — 2-3 short phrases, ~8 words each, no trailing dot, lowercase first letter.
 * Pairs the behavioral trigger with a sharp research-backed WHY.
 * No forced line breaks — text wraps naturally to overlay width.
 */
object PmMessages {

    /** 24h total phone time doubled the limit. */
    fun phoneTimeExceeded(lang: String): String =
        if (lang == "en")
            "You've hit your daily screen limit. Excessive use may impair prefrontal control. Consider stepping away — your brain needs recovery time."
        else
            "Você atingiu seu limite diário de tela. Uso excessivo pode prejudicar o controle pré-frontal. Considera se afastar — seu cérebro precisa de tempo para se recuperar."

    /** Per-app 24h limit doubled. [appName] = last segment of package. */
    fun appLimitExceeded(lang: String, appName: String): String =
        if (lang == "en")
            "You've spent more time than planned on $appName today. Each extra minute reinforces the pattern — Value your attention as a finite resource."
        else
            "Você passou mais tempo que o planejado no $appName hoje. Cada minuto extra reforça esse padrão — Valorize sua atenção como um recurso finito."

    /** Current session doubled the max-session limit. */
    fun sessionExceeded(lang: String): String =
        if (lang == "en")
            "This session has gone on too long. Interruptions can leave focus slow to return — sometimes around 23 minutes. Take a real break and move your body."
        else
            "Essa sessão já está longa demais. Interrupções podem fazer o foco demorar a voltar — às vezes cerca de 23 minutos. Faça uma pausa de verdade e mexa o corpo."

    /** Phone used after sleep-cutoff hour. */
    fun sleepingHours(lang: String): String =
        if (lang == "en")
            "Using screens this late can delay melatonin. Blue light can shift sleep hormones by about 30 minutes. Put it down — protect your deep sleep."
        else
            "Usar telas a esta hora pode atrasar a melatonina. A luz azul pode adiar os hormônios do sono em cerca de 30 minutos. Deixe o celular de lado — proteja seu sono profundo."
    
    /** Social app opened before wakeup-hour threshold. */
    fun wakeupSocial(lang: String): String =
        if (lang == "en")
            "Social media right after waking may raise cortisol. Your brain deserves a calm, intentional start. Protect your morning routine — avoid noise, messages, notifications, and feeds."
        else
            "Redes sociais logo ao acordar podem elevar o cortisol. Seu cérebro merece um começo calmo e intencional. Proteja sua rotina da manhã — evite ruídos, mensagens, notificações e feeds."
    
    /** Triggered 3 s after an unlock when unlock count exceeds limit. */
    fun unlockExceeded(lang: String): String =
        if (lang == "en")
            "Too many unlocks today. Each one strengthens the habit of checking on impulse. Before proceeding, take a breath and check why you unlocked it."
        else
            "Desbloqueios demais hoje. Cada um fortalece o hábito de checar por impulso. Antes de seguir, respira e avalia por que você pegou o celular."
}
