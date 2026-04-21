import '../../l10n/app_localizations.dart';

// Classification message: 5 time tiers × 4 unlock tiers
// Time tiers:    T0 <60min  T1 60–120  T2 120–240  T3 240–360  T4 >360
// Unlock tiers:  U0 <30/d   U1 30–60   U2 60–100   U3 >100
// Research: Twenge et al. (2018), Rosen et al. (2013), Billieux et al. (2015),
//           Mark et al. (2008), Przybylski & Weinstein (2017).

String classificationMessage(AppLocalizations l10n, int avgMinDay, int avgUnlocksDay) {
  final tI = avgMinDay < 60 ? 0 : avgMinDay < 120 ? 1 : avgMinDay < 240 ? 2 : avgMinDay < 360 ? 3 : 4;
  final uI = avgUnlocksDay < 30 ? 0 : avgUnlocksDay < 60 ? 1 : avgUnlocksDay < 100 ? 2 : 3;
  final pt = l10n.locale.languageCode == 'pt';
  final m = avgMinDay, u = avgUnlocksDay;
  final hh = (m / 60).toStringAsFixed(1);

  final msgs = <List<String Function(int m, int u, String h)>>[
    // T0 — < 60 min/day
    [
      (m, u, h) => pt
          ? 'Uso muito baixo ($m min/dia) e poucos desbloqueios ($u/dia). Você está bem abaixo dos limites saudáveis. Mantenha esse padrão.'
          : 'Very low usage ($m min/day) with few unlocks ($u/day). Well below healthy limits. Keep it up.',
      (m, u, h) => pt
          ? 'Tempo de tela baixo ($m min/dia), mas $u desbloqueios diários indicam checagem frequente. A frequência de checagem prediz ansiedade mesmo com tempo total baixo (Rosen et al., 2013). Agrupe suas verificações em blocos de tempo.'
          : 'Low screen time ($m min/day), but $u daily unlocks signal frequent checking. Check frequency predicts anxiety even at low total time (Rosen et al., 2013). Try batching checks.',
      (m, u, h) => pt
          ? 'Pouco tempo de tela ($m min/dia), mas $u desbloqueios é acima do esperado. Cada desbloqueio fragmenta o foco. Desative notificações não essenciais.'
          : 'Low screen time ($m min/day) but $u unlocks is above expected. Each unlock fragments focus. Disable non-essential notifications.',
      (m, u, h) => pt
          ? 'Você abre o celular $u vezes/dia usando-o pouco. Checagem compulsiva sem uso prolongado está associada a ciclos de ansiedade (Billieux et al., 2015). Pratique adiamento de impulso: espere 5 minutos antes de pegar o celular.'
          : 'You unlock $u times/day despite low total usage. Compulsive checking without prolonged use is linked to anxiety cycles (Billieux et al., 2015). Practice impulse delay — wait 5 minutes before reaching for your phone.',
    ],
    // T1 — 60–120 min/day
    [
      (m, u, h) => pt
          ? 'Uso equilibrado ($m min/dia) dentro da faixa recomendada por especialistas (até 120 min) e apenas $u desbloqueios. Continue assim.'
          : 'Balanced usage ($m min/day) within the expert-recommended range (up to 120 min) and just $u unlocks. Well done.',
      (m, u, h) => pt
          ? 'Uso moderado ($m min/dia) com frequência de desbloqueio normal ($u/dia). Você está na zona de equilíbrio. Monitore para que não aumente.'
          : 'Moderate usage ($m min/day) with normal unlock frequency ($u/day). You are in the balance zone. Keep monitoring.',
      (m, u, h) => pt
          ? 'Tempo de tela aceitável ($m min/dia), mas $u desbloqueios fragmentam a atenção. Recuperar o foco após uma interrupção leva em média 23 min (Mark et al., 2008). Agrupe verificações no começo e fim do dia.'
          : 'Acceptable screen time ($m min/day), but $u unlocks fragment attention. Recovering focus after an interruption takes ~23 min on average (Mark et al., 2008). Batch checks to morning and evening.',
      (m, u, h) => pt
          ? 'Tempo total razoável ($m min/dia), mas $u desbloqueios/dia é um padrão compulsivo. Isso prediz baixa qualidade de sono (Levenson et al., 2016). Estabeleça horários sem celular e desative notificações à noite.'
          : 'Reasonable total time ($m min/day), but $u unlocks/day is a compulsive pattern. This predicts poor sleep quality (Levenson et al., 2016). Set phone-free hours and silence notifications at night.',
    ],
    // T2 — 120–240 min/day
    [
      (m, u, h) => pt
          ? 'Acima do recomendado ($m min/dia; referência: 120 min para adultos). Os poucos desbloqueios ($u/dia) sugerem sessões longas. Defina um limite diário e use o modo foco.'
          : 'Above recommended ($m min/day; reference: 120 min for adults). Low unlock count ($u/day) suggests long sessions. Set a daily limit and use focus mode.',
      (m, u, h) => pt
          ? 'Com $m min/dia e $u desbloqueios, você está acima dos limites associados a bem-estar digital (Przybylski & Weinstein, 2017). Reduza as notificações para diminuir interrupções passivas.'
          : 'At $m min/day and $u unlocks, you exceed limits linked to digital wellbeing (Przybylski & Weinstein, 2017). Reduce notifications to lower passive interruptions.',
      (m, u, h) => pt
          ? 'Uso preocupante: $m min/dia ($hh h) com $u desbloqueios. Acima de 2h/dia há redução mensurável no bem-estar subjetivo de adultos (Twenge et al., 2018). Comece desativando notificações de redes sociais.'
          : 'Concerning usage: $m min/day ($hh h) with $u unlocks. Above 2h/day there is measurable decline in adult subjective wellbeing (Twenge et al., 2018). Start by turning off social media notifications.',
      (m, u, h) => pt
          ? 'Alto tempo ($m min/dia) e uso compulsivo ($u desbloqueios). Esse perfil é consistente com dependência de smartphone (Billieux et al., 2015). Aplique regras de distância física — especialmente no quarto à noite.'
          : 'High time ($m min/day) and compulsive use ($u unlocks). This profile is consistent with smartphone dependency (Billieux et al., 2015). Apply physical distance rules — especially in the bedroom at night.',
    ],
    // T3 — 240–360 min/day
    [
      (m, u, h) => pt
          ? 'Uso elevado ($m min/dia ≈ $hh h), concentrado em sessões longas ($u desbloqueios). Sessões prolongadas de consumo passivo estão ligadas a ruminação e humor deprimido (Verduyn et al., 2015). Faça pausas ativas a cada 30 minutos.'
          : 'High usage ($m min/day ≈ $hh h) in long sessions ($u unlocks). Prolonged passive consumption is linked to rumination and depressed mood (Verduyn et al., 2015). Take active breaks every 30 minutes.',
      (m, u, h) => pt
          ? 'Quase $hh h de tela por dia ($u desbloqueios). Esse nível está associado a redução na qualidade de sono e atenção sustentada. Reserve a primeira e a última hora do dia sem celular.'
          : 'Nearly $hh h of screen time per day ($u unlocks). This level is linked to reduced sleep quality and sustained attention. Reserve the first and last hour of your day phone-free.',
      (m, u, h) => pt
          ? 'Alto tempo ($m min/dia) combinado com $u desbloqueios: padrão fragmentado e excessivo. Cada interrupção cria um pico de dopamina que reforça o hábito (Schultz, 2015). Tente uma semana sem redes sociais para quebrar o ciclo.'
          : 'High time ($m min/day) combined with $u unlocks: a fragmented and excessive pattern. Each interrupt creates a dopamine spike that reinforces the habit (Schultz, 2015). Try a week without social media to break the cycle.',
      (m, u, h) => pt
          ? 'Uso muito alto: $m min/dia ($hh h) com $u desbloqueios. Esse perfil está fortemente associado a ansiedade, isolamento social e baixo desempenho. Considere ferramentas de bloqueio de apps e apoio especializado.'
          : 'Very high usage: $m min/day ($hh h) with $u unlocks. This profile is strongly linked to anxiety, social isolation, and poor performance. Consider app-blocking tools and professional support.',
    ],
    // T4 — > 360 min/day
    [
      (m, u, h) => pt
          ? 'Acima de 6h/dia ($m min). Mesmo em sessões longas, esse nível supera amplamente os limites saudáveis. Há evidências de redução de massa cinzenta no córtex pré-frontal com uso crônico excessivo (He et al., 2017). Consulte um especialista em saúde digital.'
          : 'Above 6h/day ($m min). Even in long sessions, this far exceeds healthy limits. There is evidence of grey matter reduction in the prefrontal cortex with chronic excessive use (He et al., 2017). Seek a digital health specialist.',
      (m, u, h) => pt
          ? 'Uso severo: $m min/dia ($hh h). Twenge et al. (2018) identificaram declínios claros de bem-estar acima de 5h diárias. Reduza imediatamente pelo menos 30 min/dia e estabeleça zonas livres de celular em casa.'
          : 'Severe usage: $m min/day ($hh h). Twenge et al. (2018) found clear wellbeing declines above 5h/day. Immediately cut at least 30 min/day and establish phone-free zones at home.',
      (m, u, h) => pt
          ? 'Uso severo ($m min/dia, $hh h) com alta frequência ($u desbloqueios). A combinação de alto tempo e alta frequência é o perfil de maior risco para saúde mental em estudos longitudinais. Priorize uma estratégia de redução estruturada.'
          : 'Severe usage ($m min/day, $hh h) with high frequency ($u unlocks). The combination of high time and high frequency is the highest-risk mental health profile in longitudinal studies. Prioritize a structured reduction strategy.',
      (m, u, h) => pt
          ? 'Uso extremo: $m min/dia ($hh h) com $u desbloqueios. Esse padrão compromete sono, foco, relacionamentos e saúde mental. Busque apoio profissional — a mudança de hábito nesse nível raramente ocorre sem estrutura externa.'
          : 'Extreme usage: $m min/day ($hh h) with $u unlocks. This pattern impairs sleep, focus, relationships, and mental health. Seek professional support — habit change at this level rarely happens without external structure.',
    ],
  ];

  return msgs[tI][uI](m, u, hh);
}
