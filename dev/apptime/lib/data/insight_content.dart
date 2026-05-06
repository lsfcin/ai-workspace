import 'package:flutter/material.dart';
import '../screens/insights/insight_data.dart';

class InsightEntry {
  const InsightEntry({
    required this.icon,
    required this.title,
    required this.body,
    required this.reference,
    required this.url,
    required this.analysisFn,
    this.titleEn,
    this.bodyEn,
    this.analysisFnEn,
  });

  final IconData icon;
  final String title;
  final String body;
  final String reference;
  final String url;
  final String Function(InsightData) analysisFn;
  final String? titleEn;
  final String? bodyEn;
  final String Function(InsightData)? analysisFnEn;
}

// ─── Alertas (problem-awareness cards) ───────────────────────────────────────

final kAlertas = <InsightEntry>[
  InsightEntry(
    icon: Icons.timer_outlined,
    title: 'A regra dos 23 minutos',
    titleEn: 'The 23-Minute Rule',
    body: 'Após uma única interrupção por notificação, o cérebro leva em média '
        '23 minutos e 15 segundos para retomar o foco profundo na tarefa original.',
    bodyEn: 'After a single notification interruption, the brain takes an average of '
        '23 minutes and 15 seconds to resume deep focus on the original task.',
    reference: 'Gloria Mark, UCI — Cost of Interrupted Work',
    url: 'https://www.ics.uci.edu/~gmark/chi08-mark.pdf',
    analysisFn: (d) => d.hasData
        ? 'você pegou o celular ~${d.workUnlocks} vezes entre 9h–18h na semana passada — cada uma custa 23 min de refoco'
        : 'registre uso por alguns dias para ver quantas interrupções você acumula no trabalho',
    analysisFnEn: (d) => d.hasData
        ? 'you picked up your phone ~${d.workUnlocks} times between 9am–6pm last week — each one costs 23 min of refocus'
        : 'record use for a few days to see how many work interruptions you accumulate',
  ),
  InsightEntry(
    icon: Icons.psychology_outlined,
    title: 'Queda temporária de QI',
    titleEn: 'Temporary IQ Drop',
    body: 'A multitarefa digital pode reduzir o QI funcional em 10 pontos — '
        'um impacto cognitivo maior do que perder uma noite inteira de sono.',
    bodyEn: 'Digital multitasking can reduce functional IQ by 10 points — '
        'a greater cognitive impact than losing an entire night of sleep.',
    reference: 'American Psychological Association — Multitasking Research',
    url: 'https://www.apa.org/research/action/multitask',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} das suas sessões na semana passada duraram menos de 1 min — puro custo de multitarefa'
        : 'use o app por alguns dias para ver quantas sessões breves você acumula',
    analysisFnEn: (d) => d.hasData
        ? '${d.microSessions} of your sessions last week lasted under 1 min — pure multitasking cost'
        : 'use the app for a few days to see how many brief sessions you accumulate',
  ),
  InsightEntry(
    icon: Icons.hourglass_empty_outlined,
    title: 'Erosão da atenção',
    titleEn: 'Attention Erosion',
    body: 'Nos últimos 20 anos, o tempo médio de atenção em uma tarefa digital '
        'caiu de 150 segundos para apenas 47 segundos.',
    bodyEn: 'Over the last 20 years, the average attention span on a digital task '
        'has fallen from 150 seconds to just 47 seconds.',
    reference: 'Dr. Gloria Mark (2023) — Attention Span Data',
    url: 'https://www.penguinrandomhouse.com/books/706203/attention-span-by-gloria-mark/',
    analysisFn: (d) => d.hasData
        ? 'você usou o celular em média ${d.avgDailyMin} min/dia na semana passada — cada sessão curta fragmenta mais a atenção'
        : 'registre alguns dias de uso para ver sua duração média de sessões',
    analysisFnEn: (d) => d.hasData
        ? 'you used your phone an average of ${d.avgDailyMin} min/day last week — each short session fragments attention further'
        : 'record a few days of use to see your average session duration',
  ),
  InsightEntry(
    icon: Icons.trending_down_outlined,
    title: 'Dreno de produtividade',
    titleEn: 'Productivity Drain',
    body: 'Alternar entre apps e trabalho pode consumir até 40% do seu tempo '
        'produtivo devido à carga cognitiva da reorientação mental.',
    bodyEn: 'Switching between apps and work can consume up to 40% of your '
        'productive time due to the cognitive load of mental reorientation.',
    reference: 'Rubinstein, Meyer & Evans (2001) — Task-Switching Study',
    url: 'https://doi.org/10.1037/0096-3445.130.2.211',
    analysisFn: (d) => d.hasData
        ? 'você desbloqueou o celular ~${d.workUnlocks} vezes no horário de trabalho (9h–18h) na semana passada'
        : 'use o app em dias úteis para ver quantas vezes o celular interrompe seu trabalho',
    analysisFnEn: (d) => d.hasData
        ? 'you unlocked your phone ~${d.workUnlocks} times during work hours (9am–6pm) last week'
        : 'use the app on weekdays to see how often the phone interrupts your work',
  ),
  InsightEntry(
    icon: Icons.bedtime_outlined,
    title: 'Atraso da melatonina',
    titleEn: 'Melatonin Delay',
    body: 'Usar telas antes de dormir pode atrasar a liberação de melatonina '
        'em até 30 minutos, prejudicando a capacidade de recuperação cerebral.',
    bodyEn: 'Using screens before sleep can delay melatonin release by up to '
        '30 minutes, impairing the brain\'s recovery capacity.',
    reference: 'Frontiers in Psychiatry — Digital Nudge Study, 2025',
    url: 'https://www.frontiersin.org/journals/psychiatry',
    analysisFn: (d) => d.hasData
        ? 'você ficou ${d.lateNightMin} min na tela após as 22h na semana passada'
        : 'registre uso noturno para ver quanto do seu sono está sendo afetado',
    analysisFnEn: (d) => d.hasData
        ? 'you spent ${d.lateNightMin} min on screen after 10pm last week'
        : 'track nighttime use to see how much of your sleep is being affected',
  ),
  InsightEntry(
    icon: Icons.alarm_outlined,
    title: 'Acordar estressado',
    titleEn: 'Waking Up Stressed',
    body: 'Checar o celular nos primeiros 5 minutos após acordar coloca o '
        'cérebro em estado de alto cortisol antes mesmo de sair da cama.',
    bodyEn: 'Checking your phone within the first 5 minutes of waking puts the '
        'brain in a high-cortisol state before you even get out of bed.',
    reference: 'Mindfulness and Digital Distraction Study',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+cortisol+morning',
    analysisFn: (d) => d.hasData
        ? 'você desbloqueou ${d.earlyUnlocks} vezes antes das 8h na semana passada'
        : 'registre seu uso matinal para ver como você começa os dias',
    analysisFnEn: (d) => d.hasData
        ? 'you unlocked ${d.earlyUnlocks} times before 8am last week'
        : 'track your morning use to see how your days start',
  ),
  InsightEntry(
    icon: Icons.airline_seat_flat_outlined,
    title: 'Perda de sono REM',
    titleEn: 'REM Sleep Loss',
    body: 'Pessoas que usam redes sociais na cama perdem em média 16 minutos '
        'de sono por noite devido à superestimulação cognitiva e à luz azul.',
    bodyEn: 'People who use social media in bed lose an average of 16 minutes '
        'of sleep per night due to cognitive overstimulation and blue light.',
    reference: 'University of Wisconsin-Madison Attention Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=social+media+REM+sleep+loss',
    analysisFn: (d) => d.hasData
        ? '${d.lateNightMin} min do seu tempo de tela semanal aconteceu após as 22h'
        : 'use o app para rastrear quanto do seu uso cai no horário de sono',
    analysisFnEn: (d) => d.hasData
        ? '${d.lateNightMin} min of your weekly screen time happened after 10pm'
        : 'use the app to track how much of your usage falls during sleep time',
  ),
  InsightEntry(
    icon: Icons.schedule_outlined,
    title: 'Duração do sono',
    titleEn: 'Sleep Duration',
    body: 'Uso intenso do smartphone (mais de 63h por semana) está diretamente '
        'ligado a uma redução de 6,66 minutos no descanso noturno total.',
    bodyEn: 'Intense smartphone use (more than 63h per week) is directly '
        'linked to a 6.66-minute reduction in total nightly rest.',
    reference: 'Journal of Medical Internet Research, 2025',
    url: 'https://www.jmir.org',
    analysisFn: (d) => d.hasData
        ? 'sua média foi ${d.avgDailyMin} min/dia (${(d.weeklyMin / 60).toStringAsFixed(0)}h na semana) — acima de 63h/semana há risco clínico'
        : 'registre uso por uma semana para comparar com o limite de risco',
    analysisFnEn: (d) => d.hasData
        ? 'your average was ${d.avgDailyMin} min/day (${(d.weeklyMin / 60).toStringAsFixed(0)}h this week) — above 63h/week there is clinical risk'
        : 'record use for a week to compare with the risk threshold',
  ),
  InsightEntry(
    icon: Icons.autorenew_outlined,
    title: 'O ciclo da ansiedade',
    titleEn: 'The Anxiety Cycle',
    body: 'Checar notificações com frequência cria um ciclo de "recompensa '
        'intermitente" semelhante às caça-níqueis, condicionando o cérebro a '
        'buscar constantemente o próximo pico de dopamina.',
    bodyEn: 'Frequently checking notifications creates an "intermittent reward" '
        'cycle similar to slot machines, conditioning the brain to constantly '
        'seek the next dopamine spike.',
    reference: 'Psychology of Phone Addiction Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+intermittent+reinforcement+dopamine',
    analysisFn: (d) => d.hasData
        ? 'você desbloqueou ${d.todayUnlocks}× hoje — média de ${d.weeklyUnlocks ~/ 7}/dia na semana passada'
        : 'registre uso hoje para ver quantas vezes você busca essa recompensa',
    analysisFnEn: (d) => d.hasData
        ? 'you unlocked ${d.todayUnlocks}× today — average of ${d.weeklyUnlocks ~/ 7}/day last week'
        : 'record use today to see how often you seek that reward',
  ),
  InsightEntry(
    icon: Icons.lock_open_outlined,
    title: 'O custo de desbloquear',
    titleEn: 'The Cost of Unlocking',
    body: 'Cada vez que você desbloqueia o celular sem um objetivo claro, '
        'reforça vias neurais impulsivas que dificultam a manutenção do foco '
        'em tarefas de longo prazo.',
    bodyEn: 'Each time you unlock your phone without a clear goal, you reinforce '
        'impulsive neural pathways that make it harder to maintain focus '
        'on long-term tasks.',
    reference: 'Longitudinal Investigation of Smartphone Interaction Patterns',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+unlock+impulsive+neural',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyUnlocks} desbloqueios na semana passada, ${d.microSessions} sessões abaixo de 1 min — provavelmente sem objetivo'
        : 'registre uso por alguns dias para ver quantos desbloqueios são impulsivos',
    analysisFnEn: (d) => d.hasData
        ? '${d.weeklyUnlocks} unlocks last week, ${d.microSessions} sessions under 1 min — probably without a goal'
        : 'record use for a few days to see how many unlocks are impulsive',
  ),
  InsightEntry(
    icon: Icons.phone_android_outlined,
    title: 'Frequência vs. Sono',
    titleEn: 'Frequency vs. Sleep',
    body: 'Checar o celular mais de 400 vezes por semana aumenta o risco de '
        'baixa qualidade de sono em 61% — um preditor mais forte do que o tempo total.',
    bodyEn: 'Checking your phone more than 400 times per week increases the risk '
        'of poor sleep quality by 61% — a stronger predictor than total screen time.',
    reference: 'Mental Health Journal — Estudo de uso objetivo, 2025',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+check+frequency+sleep+quality',
    analysisFn: (d) => d.hasData
        ? 'você desbloqueou ~${d.weeklyUnlocks} vezes na semana passada${d.weeklyUnlocks > 400 ? " — acima do limiar de risco (400×)" : ""}'
        : 'registre uma semana completa para comparar com o limiar de risco',
    analysisFnEn: (d) => d.hasData
        ? 'you unlocked ~${d.weeklyUnlocks} times last week${d.weeklyUnlocks > 400 ? " — above the risk threshold (400×)" : ""}'
        : 'record a full week to compare with the risk threshold',
  ),
  InsightEntry(
    icon: Icons.bolt_outlined,
    title: 'Estresse do micro-uso',
    titleEn: 'Micro-Use Stress',
    body: 'Sessões de uso menores que 10 segundos são tipicamente "checagens '
        'por tédio" que fragmentam a atenção e aumentam os níveis basais de estresse.',
    bodyEn: 'Usage sessions shorter than 10 seconds are typically "boredom checks" '
        'that fragment attention and raise baseline stress levels.',
    reference: 'ARDUOUS User Interaction Analysis',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=micro+session+smartphone+stress',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} sessões abaixo de 1 min na semana passada — cada uma é uma checagem por tédio'
        : 'use o app por alguns dias para ver quantas checagens breves você faz',
    analysisFnEn: (d) => d.hasData
        ? '${d.microSessions} sessions under 1 min last week — each one is a boredom check'
        : 'use the app for a few days to see how many brief checks you make',
  ),
  InsightEntry(
    icon: Icons.sentiment_dissatisfied_outlined,
    title: 'Dreno emocional',
    titleEn: 'Emotional Drain',
    body: 'Rolar feeds passivamente sem interagir está fortemente ligado ao '
        'aumento de sintomas de depressão, ansiedade e inveja social.',
    bodyEn: 'Passively scrolling feeds without interacting is strongly linked to '
        'increased symptoms of depression, anxiety, and social envy.',
    reference: 'Mobile Sensing Technology — Mental Health Study',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=passive+scrolling+depression+anxiety',
    analysisFn: (d) => d.hasData
        ? 'você passou ${d.passiveMin} min em apps passivos (social, vídeo) na semana passada'
        : 'registre uso por uma semana para ver quanto tempo vai para consumo passivo',
    analysisFnEn: (d) => d.hasData
        ? 'you spent ${d.passiveMin} min on passive apps (social, video) last week'
        : 'record use for a week to see how much time goes to passive consumption',
  ),
  InsightEntry(
    icon: Icons.compare_arrows_outlined,
    title: 'O mito do multitarefa',
    titleEn: 'The Multitasking Myth',
    body: 'Apenas 2,5% da população consegue fazer multitarefa com eficiência; '
        'para os outros 97,5%, a taxa de erros aumenta 50% ao usar o celular durante o trabalho.',
    bodyEn: 'Only 2.5% of the population can multitask efficiently; '
        'for the other 97.5%, error rate increases by 50% when using a phone while working.',
    reference: 'Watson & Strayer (2010) — Supertasker Profiles',
    url: 'https://doi.org/10.1177/1071181310541514',
    analysisFn: (d) => d.hasData
        ? 'você alternou contexto ~${d.workUnlocks} vezes no horário de trabalho na semana passada'
        : 'registre uso em dias úteis para ver seu padrão de multitarefa',
    analysisFnEn: (d) => d.hasData
        ? 'you switched context ~${d.workUnlocks} times during work hours last week'
        : 'record use on weekdays to see your multitasking pattern',
  ),
  InsightEntry(
    icon: Icons.dynamic_feed_outlined,
    title: 'Doomscrolling',
    titleEn: 'Doomscrolling',
    body: 'Consumir notícias negativas sem fim ativa a amígdala, mantendo o '
        'corpo em estado constante de "luta ou fuga".',
    bodyEn: 'Endlessly consuming negative news activates the amygdala, keeping '
        'the body in a constant "fight or flight" state.',
    reference: 'Emerson Health — Digital Wellness Guidelines',
    url: 'https://www.emersonhospital.org/services/behavioral-health/digital-wellness',
    analysisFn: (d) => d.hasData
        ? '${d.passiveMin} min em apps de social, vídeo e notícias na semana passada'
        : 'registre uso para ver quanto do seu tempo vai para consumo de conteúdo',
    analysisFnEn: (d) => d.hasData
        ? '${d.passiveMin} min on social, video, and news apps last week'
        : 'record use to see how much of your time goes to content consumption',
  ),
  InsightEntry(
    icon: Icons.flight_outlined,
    title: 'Fuga maladaptativa',
    titleEn: 'Maladaptive Escape',
    body: 'Usar o smartphone para "matar o tempo" ou evitar emoções negativas '
        'frequentemente agrava a fadiga digital e o esgotamento mental a longo prazo.',
    bodyEn: 'Using your smartphone to "kill time" or avoid negative emotions '
        'frequently worsens digital fatigue and mental exhaustion in the long run.',
    reference: 'Cognitive Load Theory and Digital Fatigue Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+escapism+mental+fatigue',
    analysisFn: (d) => d.hasData
        ? 'você usou o celular ${d.weeklyMin} min total na semana passada — quanto foi intenção vs. fuga?'
        : 'registre uso por uma semana para avaliar padrões de fuga',
    analysisFnEn: (d) => d.hasData
        ? 'you used your phone for ${d.weeklyMin} min total last week — how much was intention vs. escape?'
        : 'record use for a week to evaluate escape patterns',
  ),
  InsightEntry(
    icon: Icons.arrow_downward_outlined,
    title: 'Pressão no pescoço',
    titleEn: 'Neck Pressure',
    body: 'Inclinar a cabeça 60 graus para olhar o celular exerce 27 kg de '
        'força sobre a coluna cervical.',
    bodyEn: 'Tilting your head 60 degrees to look at your phone places 27 kg of '
        'force on the cervical spine.',
    reference: '"Text Neck" Biomechanical Model Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=text+neck+cervical+spine+biomechanics',
    analysisFn: (d) => d.hasData
        ? 'você passou ${d.avgDailyMin} min/dia olhando para baixo — ${(d.avgDailyMin / 60).toStringAsFixed(1)}h de carga cervical diária'
        : 'registre uso para quantificar a carga mecânica diária no seu pescoço',
    analysisFnEn: (d) => d.hasData
        ? 'you spent ${d.avgDailyMin} min/day looking down — ${(d.avgDailyMin / 60).toStringAsFixed(1)}h of daily cervical load'
        : 'record use to quantify your daily mechanical load on your neck',
  ),
  InsightEntry(
    icon: Icons.visibility_outlined,
    title: 'Fadiga visual digital',
    titleEn: 'Digital Eye Strain',
    body: 'O uso prolongado de tela reduz a taxa de piscar em até 50%, causando '
        'olhos secos, visão turva e dores de cabeça persistentes.',
    bodyEn: 'Prolonged screen use reduces blink rate by up to 50%, causing '
        'dry eyes, blurred vision, and persistent headaches.',
    reference: 'Computer Vision Syndrome (CVS) — 20-20-20 Rule Research',
    url: 'https://www.aoa.org/healthy-eyes/eye-and-vision-conditions/computer-vision-syndrome',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyMin} min na tela na semana passada — seus olhos ficaram muito tempo sem descanso'
        : 'registre uso para calcular sua carga visual semanal',
    analysisFnEn: (d) => d.hasData
        ? '${d.weeklyMin} min on screen last week — your eyes spent a long time without rest'
        : 'record use to calculate your weekly visual load',
  ),
  InsightEntry(
    icon: Icons.healing_outlined,
    title: 'Risco de dor crônica',
    titleEn: 'Chronic Pain Risk',
    body: 'Usuários excessivos de smartphone têm risco seis vezes maior de '
        'desenvolver dores crônicas no pescoço e ombros.',
    bodyEn: 'Excessive smartphone users have a six-fold higher risk of '
        'developing chronic neck and shoulder pain.',
    reference: 'Longitudinal Population-Based Cohort Study (Gustafsson et al.)',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+chronic+neck+pain+Gustafsson',
    analysisFn: (d) => d.hasData
        ? '${d.avgDailyMin} min/dia — uso diário consistente acumula risco crônico ao longo do tempo'
        : 'registre uso diário para ver sua exposição acumulada',
    analysisFnEn: (d) => d.hasData
        ? '${d.avgDailyMin} min/day — consistent daily use accumulates chronic risk over time'
        : 'record daily use to see your cumulative exposure',
  ),
  InsightEntry(
    icon: Icons.group_outlined,
    title: 'A presença silenciosa',
    titleEn: 'The Silent Presence',
    body: 'Mesmo um celular virado para baixo sobre a mesa reduz a profundidade '
        'da conversa e a conexão emocional entre as pessoas presentes.',
    bodyEn: 'Even a phone face-down on the table reduces the depth of conversation '
        'and emotional connection between people present.',
    reference: 'Sherry Turkle — Reclaiming Conversation Research',
    url: 'https://www.penguinrandomhouse.com/books/312845/reclaiming-conversation-by-sherry-turkle/',
    analysisFn: (d) => d.hasData
        ? 'você pegou o celular ${d.mealUnlocks} vezes nos horários de refeição (12–14h, 19–21h) na semana passada'
        : 'registre uso para ver quantas refeições foram interrompidas pelo celular',
    analysisFnEn: (d) => d.hasData
        ? 'you picked up your phone ${d.mealUnlocks} times during meal hours (12–2pm, 7–9pm) last week'
        : 'record use to see how many meals were interrupted by the phone',
  ),
  InsightEntry(
    icon: Icons.person_remove_outlined,
    title: 'Solidão digital',
    titleEn: 'Digital Loneliness',
    body: 'O "phubbing" — ignorar outros pelo celular — desperta sentimentos de '
        'exclusão e ostracismo em parceiros e amigos, danificando a confiança a longo prazo.',
    bodyEn: '"Phubbing" — ignoring others because of your phone — triggers feelings of '
        'exclusion and ostracism in partners and friends, damaging trust in the long run.',
    reference: 'Seppala (2017) — Phubbing and Relationship Satisfaction Study',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=phubbing+relationship+satisfaction+ostracism',
    analysisFn: (d) => d.hasData
        ? '${d.mealUnlocks} desbloqueios nos horários de refeição na semana passada — cada um foi um momento de phubbing'
        : 'registre uso para quantificar momentos de interrupção de conexão social',
    analysisFnEn: (d) => d.hasData
        ? '${d.mealUnlocks} unlocks during meal hours last week — each one was a moment of phubbing'
        : 'record use to quantify moments of interrupted social connection',
  ),
  InsightEntry(
    icon: Icons.favorite_border_outlined,
    title: 'Declínio da empatia',
    titleEn: 'Empathy Decline',
    body: 'Estudantes universitários que cresceram com uso intenso de tecnologia '
        'demonstram 40% menos empatia do que gerações anteriores.',
    bodyEn: 'University students who grew up with heavy technology use show '
        '40% less empathy than previous generations.',
    reference: 'Sherry Turkle & University of Michigan — Empathy Meta-Analysis',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=technology+empathy+decline+college+students',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela na semana passada reduz o tempo de conexão face a face'
        : 'registre uso para ver quanto tempo o celular substitui interação humana',
    analysisFnEn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h of screen time last week reduces time for face-to-face connection'
        : 'record use to see how much time the phone replaces human interaction',
  ),
  InsightEntry(
    icon: Icons.psychology_alt_outlined,
    title: 'Brain-rot: atrofia cognitiva digital',
    titleEn: 'Brain-Rot: Digital Cognitive Atrophy',
    body: 'O consumo crônico de conteúdo curto e hipnótico (Reels, Shorts, TikTok) '
        'reduz a capacidade de tolerar tédio, ler textos longos e manter foco — '
        'um fenômeno chamado de "brain-rot" ou erosão cognitiva digital. '
        'Estudos mostram que após semanas de scroll intenso, o tempo médio de '
        'atenção voluntária cai para menos de 8 segundos.',
    bodyEn: 'Chronic consumption of short, hypnotic content (Reels, Shorts, TikTok) '
        'reduces the ability to tolerate boredom, read long texts, and sustain focus — '
        'a phenomenon called "brain-rot" or digital cognitive erosion. '
        'Studies show that after weeks of intense scrolling, the average voluntary '
        'attention span drops to under 8 seconds.',
    reference: 'Loh & Kanai (2016), "How Has the Internet Reshaped Human Cognition?", The Neuroscientist',
    url: 'https://doi.org/10.1177/1073858415595005',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} sessões abaixo de 1 min na semana — cada uma é um treino do cérebro para rejeitar conteúdo mais longo'
        : 'registre uso por alguns dias para ver sua proporção de sessões ultra-curtas',
    analysisFnEn: (d) => d.hasData
        ? '${d.microSessions} sessions under 1 min this week — each one trains the brain to reject longer content'
        : 'record use for a few days to see your proportion of ultra-short sessions',
  ),
  InsightEntry(
    icon: Icons.auto_graph_outlined,
    title: 'Conteúdo curto destrói a memória',
    titleEn: 'Short Content Destroys Memory',
    body: 'O consumo de vídeos de 15–60 segundos prejudica a consolidação da '
        'memória de trabalho: o cérebro não tem tempo suficiente para processar '
        'e arquivar o que vê, resultando em uma corrente de informações que não '
        'deixa rastro cognitivo — informação sem aprendizado.',
    bodyEn: 'Consuming 15–60 second videos impairs working memory consolidation: '
        'the brain does not have enough time to process and archive what it sees, '
        'resulting in a stream of information that leaves no cognitive trace — '
        'information without learning.',
    reference: 'Uncapher & Wagner (2018), "Minds and Brains of Media Multitaskers", PNAS',
    url: 'https://doi.org/10.1073/pnas.1611612115',
    analysisFn: (d) => d.hasData
        ? '${d.passiveMin} min em apps de vídeo/social na semana passada — quanto desse conteúdo você ainda lembra?'
        : 'registre uso para ver quanto tempo vai para consumo de conteúdo descartável',
    analysisFnEn: (d) => d.hasData
        ? '${d.passiveMin} min on video/social apps last week — how much of that content do you still remember?'
        : 'record use to see how much time goes to disposable content consumption',
  ),
  InsightEntry(
    icon: Icons.science_outlined,
    title: 'Celular = droga de design',
    titleEn: 'Phone = Designed Drug',
    body: 'Neuroimagens mostram que o uso compulsivo de smartphone ativa o '
        'núcleo accumbens da mesma forma que cocaína ou álcool. '
        'A diferença: o smartphone é legal, socialmente aceito e está no bolso '
        '24h por dia. Essa combinação o torna, segundo pesquisadores, '
        'potencialmente mais difícil de controlar do que substâncias ilegais.',
    bodyEn: 'Neuroimaging shows that compulsive smartphone use activates the '
        'nucleus accumbens in the same way as cocaine or alcohol. '
        'The difference: the smartphone is legal, socially accepted, and in your '
        'pocket 24h a day. This combination makes it, according to researchers, '
        'potentially harder to control than illegal substances.',
    reference: 'He et al. (2017), "Altered Small-World Brain Networks in Internet Addiction", Scientific Reports',
    url: 'https://doi.org/10.1038/srep41587',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyUnlocks} desbloqueios na semana passada — cada um é uma busca pelo próximo pico de dopamina'
        : 'registre uma semana de uso para ver com que frequência você busca essa recompensa',
    analysisFnEn: (d) => d.hasData
        ? '${d.weeklyUnlocks} unlocks last week — each one is a search for the next dopamine peak'
        : 'record a week of use to see how often you seek that reward',
  ),
  InsightEntry(
    icon: Icons.warning_amber_outlined,
    title: 'Tolerância e abstinência digital',
    titleEn: 'Digital Tolerance and Withdrawal',
    body: 'Usuários compulsivos de smartphone desenvolvem tolerância — precisam '
        'de doses crescentes (mais tempo de tela) para obter o mesmo prazer — '
        'e abstinência — ansiedade, irritabilidade e foco prejudicado quando o '
        'celular não está disponível. Esses são os critérios clínicos de dependência '
        'reconhecidos pela OMS para substâncias.',
    bodyEn: 'Compulsive smartphone users develop tolerance — needing increasing '
        'doses (more screen time) to get the same pleasure — and withdrawal — '
        'anxiety, irritability, and impaired focus when the phone is unavailable. '
        'These are the WHO\'s clinical criteria for substance dependence.',
    reference: 'Billieux et al. (2015), "Problematic Smartphone Use: Who and Why?", Current Addiction Reports',
    url: 'https://doi.org/10.1007/s40429-015-0054-y',
    analysisFn: (d) => d.hasData
        ? 'você usou ${d.avgDailyMin} min/dia esta semana — note se o padrão aumentou nos últimos meses'
        : 'registre uso por algumas semanas para identificar tendência de aumento de tolerância',
    analysisFnEn: (d) => d.hasData
        ? 'you used ${d.avgDailyMin} min/day this week — notice if the pattern has increased over recent months'
        : 'record use for several weeks to identify a trend of increasing tolerance',
  ),
];

// ─── Soluções (solution cards) ────────────────────────────────────────────────

final kSolucoes = <InsightEntry>[
  InsightEntry(
    icon: Icons.hourglass_empty_outlined,
    title: 'A regra do atrito',
    titleEn: 'The Friction Rule',
    body: 'Introduzir apenas 10 segundos de atraso antes de abrir um app-alvo '
        'é suficiente para dissipar a maioria dos impulsos de consumo inconsciente.',
    bodyEn: 'Introducing just 10 seconds of delay before opening a target app '
        'is enough to dissipate most unconscious consumption impulses.',
    reference: '"One Sec" App — Psychological Mechanism Study, PNAS 2023',
    url: 'https://doi.org/10.1073/pnas.2213580120',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} sessões impulsivas (< 1 min) na semana passada — um atraso de 10s poderia ter evitado a maioria'
        : 'registre uso por alguns dias para ver quantas aberturas são impulsivas',
    analysisFnEn: (d) => d.hasData
        ? '${d.microSessions} impulsive sessions (< 1 min) last week — a 10s delay could have prevented most of them'
        : 'record use for a few days to see how many openings are impulsive',
  ),
  InsightEntry(
    icon: Icons.invert_colors_off_outlined,
    title: 'O poder do escala de cinza',
    titleEn: 'The Power of Grayscale',
    body: 'Mudar a tela para preto e branco reduz o uso diário em '
        'aproximadamente 20–40 minutos, tornando os apps menos visualmente recompensadores.',
    bodyEn: 'Switching the screen to black and white reduces daily use by '
        'approximately 20–40 minutes, making apps less visually rewarding.',
    reference: 'Holte & Ferraro (2020) — Grayscale Screen Time Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=grayscale+screen+time+reduction',
    analysisFn: (d) => d.hasData
        ? 'sua média é ${d.avgDailyMin} min/dia — escala de cinza poderia economizar 20–40 min diários'
        : 'registre uso por uma semana e compare após ativar escala de cinza',
    analysisFnEn: (d) => d.hasData
        ? 'your average is ${d.avgDailyMin} min/day — grayscale could save 20–40 min daily'
        : 'record use for a week and compare after activating grayscale',
  ),
  InsightEntry(
    icon: Icons.visibility_off_outlined,
    title: 'Fora da vista',
    titleEn: 'Out of Sight',
    body: 'Manter o celular em outro cômodo enquanto trabalha melhora '
        'significativamente a memória de trabalho e a capacidade cognitiva.',
    bodyEn: 'Keeping your phone in another room while working significantly '
        'improves working memory and cognitive capacity.',
    reference: 'Ward et al. (2017) — "Brain Drain" Study',
    url: 'https://doi.org/10.1086/691462',
    analysisFn: (d) => d.hasData
        ? '${d.workUnlocks} vezes que o celular interrompeu seu trabalho (9h–18h) na semana passada'
        : 'registre uso em dias úteis para medir o impacto do celular na sua concentração',
    analysisFnEn: (d) => d.hasData
        ? '${d.workUnlocks} times the phone interrupted your work (9am–6pm) last week'
        : 'record use on weekdays to measure the phone\'s impact on your concentration',
  ),
  InsightEntry(
    icon: Icons.center_focus_strong_outlined,
    title: 'Treinamento unitarefa',
    titleEn: 'Unitasking Training',
    body: 'Reconstruir o tempo de atenção exige treinar o cérebro para focar '
        'em um único app ou tarefa por 25 minutos sem interrupção.',
    bodyEn: 'Rebuilding attention span requires training the brain to focus '
        'on a single app or task for 25 minutes without interruption.',
    reference: 'Reclaiming Conversation — Unitasking Principles',
    url: 'https://www.penguinrandomhouse.com/books/312845/reclaiming-conversation-by-sherry-turkle/',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} sessões abaixo de 1 min na semana passada — seu músculo de foco precisa ser treinado'
        : 'registre uso para ver sua capacidade atual de manter o foco',
    analysisFnEn: (d) => d.hasData
        ? '${d.microSessions} sessions under 1 min last week — your focus muscle needs training'
        : 'record use to see your current ability to sustain focus',
  ),
  InsightEntry(
    icon: Icons.spa_outlined,
    title: 'Detox de tela',
    titleEn: 'Screen Detox',
    body: 'Reduzir o tempo de tela por apenas 3 semanas pode melhorar '
        'indicadores de saúde mental com tamanho de efeito comparável ao de antidepressivos.',
    bodyEn: 'Reducing screen time for just 3 weeks can improve mental health '
        'indicators with an effect size comparable to antidepressants.',
    reference: 'Georgetown University — Digital Detox Study (Kushlev et al., 2025)',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=screen+time+reduction+mental+health+Kushlev',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela na semana passada — 3 semanas de redução já geram ganhos clínicos'
        : 'registre uma semana de uso para planejar seu detox',
    analysisFnEn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h of screen time last week — 3 weeks of reduction already yields clinical gains'
        : 'record a week of use to plan your detox',
  ),
  InsightEntry(
    icon: Icons.remove_circle_outline_outlined,
    title: 'Remoção de gatilhos',
    titleEn: 'Trigger Removal',
    body: 'Esconder apps de redes sociais em pastas fora da tela inicial reduz '
        'os estímulos visuais que disparam comportamentos automáticos de "checagem".',
    bodyEn: 'Hiding social media apps in folders off the home screen reduces '
        'the visual cues that trigger automatic "checking" behaviors.',
    reference: 'Fogg Behavior Model and Multifaceted Nudges',
    url: 'https://behaviordesign.stanford.edu',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} checagens impulsivas na semana passada — remova os gatilhos visuais da tela inicial'
        : 'registre uso para identificar quais apps você abre por impulso',
    analysisFnEn: (d) => d.hasData
        ? '${d.microSessions} impulsive checks last week — remove visual triggers from your home screen'
        : 'record use to identify which apps you open by impulse',
  ),
  InsightEntry(
    icon: Icons.lock_outlined,
    title: 'Senhas manuais',
    titleEn: 'Manual Passcodes',
    body: 'Desabilitar desbloqueio biométrico em favor de senhas longas adiciona '
        'uma camada de "atrito deliberado" que reduz aberturas impulsivas.',
    bodyEn: 'Disabling biometric unlock in favor of long passcodes adds a layer '
        'of "deliberate friction" that reduces impulsive openings.',
    reference: 'Nudge-Based Intervention — Randomized Controlled Trial',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=PIN+password+smartphone+impulsive+use',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyUnlocks} desbloqueios na semana passada — atrito adicional reduziria os impulsivos'
        : 'registre quantos desbloqueios você faz para avaliar o impacto do atrito',
    analysisFnEn: (d) => d.hasData
        ? '${d.weeklyUnlocks} unlocks last week — added friction would reduce the impulsive ones'
        : 'record how many unlocks you make to assess the impact of friction',
  ),
  InsightEntry(
    icon: Icons.hotel_outlined,
    title: 'A regra do quarto',
    titleEn: 'The Bedroom Rule',
    body: 'Carregar o celular fora do quarto melhora a qualidade do sono e '
        'previne o pico de cortisol associado ao scroll matinal.',
    bodyEn: 'Charging your phone outside the bedroom improves sleep quality and '
        'prevents the cortisol spike associated with morning scrolling.',
    reference: 'Digital Detox Benefits and Sleep Quality Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+bedroom+sleep+quality',
    analysisFn: (d) => d.hasData
        ? '${d.lateNightMin} min na tela após as 22h na semana passada — o carregador deveria estar em outro cômodo'
        : 'registre seu uso noturno para medir o impacto do celular no quarto',
    analysisFnEn: (d) => d.hasData
        ? '${d.lateNightMin} min on screen after 10pm last week — the charger should be in another room'
        : 'record your nighttime use to measure the phone\'s impact in the bedroom',
  ),
  InsightEntry(
    icon: Icons.notifications_off_outlined,
    title: 'Notificações seletivas',
    titleEn: 'Selective Notifications',
    body: 'Manter apenas alertas de humano para humano (mensagens) enquanto '
        'desativa "pings" de apps reduz o estresse ambiental constante.',
    bodyEn: 'Keeping only human-to-human alerts (messages) while disabling '
        'app "pings" reduces constant ambient stress.',
    reference: 'Intervention for Reducing Non-Essential Notification Disruptions',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=notification+reduction+stress+intervention',
    analysisFn: (d) => d.hasData
        ? '${d.workUnlocks} interrupções no horário de trabalho na semana passada — quantas foram notificações?'
        : 'registre uso para ver o impacto das notificações na sua atenção',
    analysisFnEn: (d) => d.hasData
        ? '${d.workUnlocks} interruptions during work hours last week — how many were notifications?'
        : 'record use to see the impact of notifications on your attention',
  ),
  InsightEntry(
    icon: Icons.pause_circle_outlined,
    title: 'Pausa de atenção plena',
    titleEn: 'Mindful Pause',
    body: 'Antes de abrir um app, perguntar "Por que estou pegando isso?" '
        'muda o estado do Sistema 1 (automático) para o Sistema 2 (deliberado).',
    bodyEn: 'Before opening an app, asking "Why am I picking this up?" '
        'shifts the state from System 1 (automatic) to System 2 (deliberate).',
    reference: 'Pratt Institute — Digital Wellbeing Journey Guidelines',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=mindful+smartphone+use+system+2+thinking',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyUnlocks} desbloqueios na semana passada — quantos foram conscientes?'
        : 'registre uso para descobrir a proporção de aberturas automáticas vs. intencionais',
    analysisFnEn: (d) => d.hasData
        ? '${d.weeklyUnlocks} unlocks last week — how many were conscious?'
        : 'record use to discover the proportion of automatic vs. intentional openings',
  ),
  InsightEntry(
    icon: Icons.remove_red_eye_outlined,
    title: 'A regra 20-20-20',
    titleEn: 'The 20-20-20 Rule',
    body: 'A cada 20 minutos de uso de tela, olhe para algo a 6 metros de '
        'distância por 20 segundos para relaxar os músculos oculares.',
    bodyEn: 'Every 20 minutes of screen use, look at something 6 meters away '
        'for 20 seconds to relax the eye muscles.',
    reference: 'Eye Care Practitioner — Clinical Guidelines for Digital Fatigue',
    url: 'https://www.aao.org/eye-health/tips-prevention/computer-usage',
    analysisFn: (d) => d.hasData
        ? '${d.avgDailyMin} min/dia na tela — isso significa ${d.avgDailyMin ~/ 20} pausas de 20s necessárias por dia'
        : 'registre uso para calcular quantas pausas visuais você deveria fazer',
    analysisFnEn: (d) => d.hasData
        ? '${d.avgDailyMin} min/day on screen — that means ${d.avgDailyMin ~/ 20} 20-second breaks needed per day'
        : 'record use to calculate how many visual breaks you should take',
  ),
  InsightEntry(
    icon: Icons.trending_up_outlined,
    title: 'Metas adaptativas',
    titleEn: 'Adaptive Goals',
    body: 'Reduzir o uso em incrementos semanais de 10% é mais eficaz para '
        'mudança permanente do que tentativas de cortes drásticos e repentinos.',
    bodyEn: 'Reducing use in weekly increments of 10% is more effective for '
        'permanent change than attempting drastic, sudden cuts.',
    reference: 'Rule-Based Adaptive Goals in Habit Formation',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=adaptive+goal+smartphone+habit+reduction',
    analysisFn: (d) => d.hasData
        ? 'você está em ${d.avgDailyMin} min/dia — uma meta de 10% a menos = ${(d.avgDailyMin * 0.9).round()} min/dia'
        : 'registre uso por uma semana para definir sua meta de redução de 10%',
    analysisFnEn: (d) => d.hasData
        ? 'you are at ${d.avgDailyMin} min/day — a 10% reduction goal = ${(d.avgDailyMin * 0.9).round()} min/day'
        : 'record use for a week to set your 10% reduction goal',
  ),
  InsightEntry(
    icon: Icons.access_time_outlined,
    title: 'Custo de oportunidade',
    titleEn: 'Opportunity Cost',
    body: 'Visualizar o tempo de tela como "horas perdidas" ajuda a priorizar '
        'hobbies do mundo real, exercícios e sono profundo.',
    bodyEn: 'Visualizing screen time as "lost hours" helps prioritize '
        'real-world hobbies, exercise, and deep sleep.',
    reference: 'PNAS Nexus (2025) — Blocking Mobile Internet Study',
    url: 'https://doi.org/10.1093/pnasnexus/pgae080',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela na semana passada — o equivalente a ${(d.weeklyMin / 60 * 30).round()} páginas lidas, ${(d.weeklyMin / 60 * 5).round()} km caminhados'
        : 'registre uso por uma semana para calcular o que você poderia ter feito',
    analysisFnEn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h of screen time last week — equivalent to ${(d.weeklyMin / 60 * 30).round()} pages read, ${(d.weeklyMin / 60 * 5).round()} km walked'
        : 'record use for a week to calculate what you could have done instead',
  ),
  InsightEntry(
    icon: Icons.park_outlined,
    title: 'Reinicialização pela natureza',
    titleEn: 'Nature Reset',
    body: 'Passar 3 dias na natureza sem celular pode aumentar a função '
        'cognitiva e a criatividade em até 50%.',
    bodyEn: 'Spending 3 days in nature without a phone can increase cognitive '
        'function and creativity by up to 50%.',
    reference: '"Three-Day Effect" and Attention Restoration Theory',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=nature+three+day+effect+attention+restoration',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela esta semana — seu córtex pré-frontal precisa de natureza para recuperar'
        : 'registre uso por uma semana para planejar seu próximo detox na natureza',
    analysisFnEn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h of screen time this week — your prefrontal cortex needs nature to recover'
        : 'record use for a week to plan your next nature detox',
  ),
  InsightEntry(
    icon: Icons.fitness_center_outlined,
    title: 'Fortalecimento pré-frontal',
    titleEn: 'Prefrontal Strengthening',
    body: 'Períodos diários de "jejum digital" ajudam a fortalecer o córtex '
        'pré-frontal, devolvendo o controle sobre decisões e reduzindo o vício.',
    bodyEn: 'Daily periods of "digital fasting" help strengthen the prefrontal cortex, '
        'restoring control over decisions and reducing addictive behavior.',
    reference: 'Mindfulness Practice for Behavioral Addiction Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=digital+fasting+prefrontal+cortex+addiction',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} impulsos de checagem na semana passada — o córtex pré-frontal pode retomar esse controle'
        : 'registre uso para medir o quanto o impulso digital domina suas escolhas',
    analysisFnEn: (d) => d.hasData
        ? '${d.microSessions} checking impulses last week — the prefrontal cortex can reclaim this control'
        : 'record use to measure how much the digital impulse dominates your choices',
  ),
  InsightEntry(
    icon: Icons.directions_walk_outlined,
    title: 'Recuperação ativa',
    titleEn: 'Active Recovery',
    body: 'Substituir 5 minutos de scroll por uma caminhada rápida rejuvenesce '
        'o cérebro e reduz a fadiga mental mais rápido que o entretenimento digital.',
    bodyEn: 'Replacing 5 minutes of scrolling with a brisk walk rejuvenates '
        'the brain and reduces mental fatigue faster than digital entertainment.',
    reference: 'CareerBuilder — Workplace Productivity Suggestion',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=walking+mental+fatigue+screen+replacement',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela esta semana — substituir 5 min de scroll por caminhada faz diferença real'
        : 'registre uso para identificar janelas onde uma caminhada substituiria o scroll',
    analysisFnEn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h of screen time this week — replacing 5 min of scrolling with walking makes a real difference'
        : 'record use to identify windows where a walk could replace scrolling',
  ),
  InsightEntry(
    icon: Icons.bar_chart_outlined,
    title: 'A lacuna da subestimação',
    titleEn: 'The Underestimation Gap',
    body: 'Usuários tipicamente subestimam seu uso real de smartphone em 20% '
        'a 50% — até que vejam dados objetivos de rastreamento.',
    bodyEn: 'Users typically underestimate their real smartphone use by 20% '
        'to 50% — until they see objective tracking data.',
    reference: 'Agreement Between Self-Reported and Objective Usage Study',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+self+report+underestimate+objective',
    analysisFn: (d) => d.hasData
        ? 'o rastreador registra ${d.avgDailyMin} min/dia — acima do que a maioria das pessoas estima para si mesma'
        : 'use o app para obter os dados reais e comparar com o que você imagina usar',
    analysisFnEn: (d) => d.hasData
        ? 'the tracker records ${d.avgDailyMin} min/day — more than most people estimate for themselves'
        : 'use the app to get the real data and compare with what you imagine you use',
  ),
  InsightEntry(
    icon: Icons.filter_list_outlined,
    title: 'Auditoria do feed',
    titleEn: 'Feed Audit',
    body: 'Deixar de seguir contas que geram emoções negativas pode '
        'transformar o uso passivo em uma experiência mais neutra ou positiva.',
    bodyEn: 'Unfollowing accounts that generate negative emotions can '
        'transform passive use into a more neutral or positive experience.',
    reference: 'Digital Wellness Guidelines for Doomscrolling',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=unfollow+negative+content+social+media+wellbeing',
    analysisFn: (d) => d.hasData
        ? '${d.passiveMin} min em apps passivos esta semana — vale auditar o que esse feed está te entregando'
        : 'registre uso para ver quanto tempo vai para consumo passivo de conteúdo',
    analysisFnEn: (d) => d.hasData
        ? '${d.passiveMin} min on passive apps this week — worth auditing what that feed is delivering to you'
        : 'record use to see how much time goes to passive content consumption',
  ),
  InsightEntry(
    icon: Icons.menu_book_outlined,
    title: 'Leitura longa como antídoto',
    titleEn: 'Long Reading as Antidote',
    body: 'Ler 20 minutos de texto contínuo por dia — livro, artigo, ensaio — '
        'reconstrói o músculo da atenção sustentada e reverte parcialmente '
        'os efeitos do consumo fragmentado. É o oposto estrutural do scroll: '
        'exige atenção linear, memória de trabalho e síntese ativa.',
    bodyEn: 'Reading 20 minutes of continuous text per day — book, article, essay — '
        'rebuilds the sustained attention muscle and partially reverses the effects '
        'of fragmented consumption. It is the structural opposite of scrolling: '
        'it requires linear attention, working memory, and active synthesis.',
    reference: 'Wolf (2018), "Reader, Come Home: The Reading Brain in a Digital World", HarperCollins',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=deep+reading+brain+attention+Wolf',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} checagens impulsivas na semana passada — cada sessão longa de leitura desfaz vários desses danos'
        : 'registre uso para medir a proporção de sessões fragmentadas vs. profundas',
    analysisFnEn: (d) => d.hasData
        ? '${d.microSessions} impulsive checks last week — each long reading session undoes several of those damages'
        : 'record use to measure the ratio of fragmented vs. deep sessions',
  ),
  InsightEntry(
    icon: Icons.self_improvement_outlined,
    title: 'Tédio como exercício cognitivo',
    titleEn: 'Boredom as Cognitive Exercise',
    body: 'Tolerar o tédio sem recorrer ao celular é, literalmente, um treino '
        'cerebral: ativa a rede de modo padrão (default mode network), '
        'responsável pela criatividade, autopercepção e consolidação de memórias. '
        'O scroll infinito suprime essa rede, empobrecendo o pensamento espontâneo.',
    bodyEn: 'Tolerating boredom without reaching for your phone is literally a '
        'brain workout: it activates the default mode network, responsible for '
        'creativity, self-awareness, and memory consolidation. '
        'Infinite scrolling suppresses this network, impoverishing spontaneous thinking.',
    reference: 'Smallwood & Schooler (2015), "The Science of Mind Wandering", Annual Review of Psychology',
    url: 'https://doi.org/10.1146/annurev-psych-010814-015331',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} vezes que você buscou o celular ao sentir tédio esta semana — experimente esperar 2 minutos antes de pegar'
        : 'registre uso para identificar quantas aberturas são respostas automáticas ao tédio',
    analysisFnEn: (d) => d.hasData
        ? '${d.microSessions} times you reached for your phone when bored this week — try waiting 2 minutes before picking it up'
        : 'record use to identify how many openings are automatic responses to boredom',
  ),
  InsightEntry(
    icon: Icons.spa_outlined,
    title: 'Protocolos de dependência aplicados ao celular',
    titleEn: 'Addiction Protocols Applied to the Phone',
    body: 'Técnicas validadas para dependência química funcionam para smartphones: '
        'identificar gatilhos situacionais, criar fricção para o comportamento-alvo '
        'e substituir por comportamento incompatível (caminhar, respirar, ler). '
        'A estrutura é a mesma — só o objeto da dependência muda.',
    bodyEn: 'Validated techniques for chemical dependency work for smartphones: '
        'identify situational triggers, create friction for the target behavior, '
        'and substitute with an incompatible behavior (walk, breathe, read). '
        'The framework is the same — only the object of dependency changes.',
    reference: 'Throuvala et al. (2019), "Motivational and Self-Control Mechanisms", Journal of Behavioral Addictions',
    url: 'https://doi.org/10.1556/2006.8.2019.43',
    analysisFn: (d) => d.hasData
        ? 'você tem ${d.weeklyUnlocks} desbloqueios semanais — identifique os 3 principais gatilhos e crie atrito para cada um'
        : 'registre uso por uma semana para mapear seus principais gatilhos de abertura',
    analysisFnEn: (d) => d.hasData
        ? 'you have ${d.weeklyUnlocks} weekly unlocks — identify the top 3 triggers and create friction for each'
        : 'record use for a week to map your main opening triggers',
  ),
  InsightEntry(
    icon: Icons.group_work_outlined,
    title: 'Responsabilidade social como âncora',
    titleEn: 'Social Accountability as Anchor',
    body: 'Em programas de recuperação de dependência, o suporte social é '
        'o preditor mais forte de sucesso a longo prazo. Aplicado ao uso digital: '
        'compartilhar metas de uso com um parceiro, amigo ou grupo aumenta '
        'significativamente a adesão e reduz recaídas.',
    bodyEn: 'In addiction recovery programs, social support is the strongest '
        'long-term predictor of success. Applied to digital use: '
        'sharing usage goals with a partner, friend, or group significantly '
        'increases adherence and reduces relapses.',
    reference: 'Kelly et al. (2020), "Mechanisms of Behavior Change in AA", Addiction',
    url: 'https://doi.org/10.1111/add.14906',
    analysisFn: (d) => d.hasData
        ? 'sua meta atual: se um amigo soubesse seus ${d.avgDailyMin} min/dia, isso mudaria seu comportamento?'
        : 'registre uso por uma semana e compartilhe os dados com alguém de confiança',
    analysisFnEn: (d) => d.hasData
        ? 'your current average: if a friend knew your ${d.avgDailyMin} min/day, would it change your behavior?'
        : 'record use for a week and share the data with someone you trust',
  ),
];
