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
  });

  final IconData icon;
  final String title;
  final String body;
  final String reference;
  final String url;
  final String Function(InsightData) analysisFn;
}

// ─── Alertas (problem-awareness cards) ───────────────────────────────────────

final kAlertas = <InsightEntry>[
  InsightEntry(
    icon: Icons.timer_outlined,
    title: 'A regra dos 23 minutos',
    body: 'Após uma única interrupção por notificação, o cérebro leva em média '
        '23 minutos e 15 segundos para retomar o foco profundo na tarefa original.',
    reference: 'Gloria Mark, UCI — Cost of Interrupted Work',
    url: 'https://www.ics.uci.edu/~gmark/chi08-mark.pdf',
    analysisFn: (d) => d.hasData
        ? 'você pegou o celular ~${d.workUnlocks} vezes entre 9h–18h na semana passada — cada uma custa 23 min de refoco'
        : 'registre uso por alguns dias para ver quantas interrupções você acumula no trabalho',
  ),
  InsightEntry(
    icon: Icons.psychology_outlined,
    title: 'Queda temporária de QI',
    body: 'A multitarefa digital pode reduzir o QI funcional em 10 pontos — '
        'um impacto cognitivo maior do que perder uma noite inteira de sono.',
    reference: 'American Psychological Association — Multitasking Research',
    url: 'https://www.apa.org/research/action/multitask',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} das suas sessões na semana passada duraram menos de 1 min — puro custo de multitarefa'
        : 'use o app por alguns dias para ver quantas sessões breves você acumula',
  ),
  InsightEntry(
    icon: Icons.hourglass_empty_outlined,
    title: 'Erosão da atenção',
    body: 'Nos últimos 20 anos, o tempo médio de atenção em uma tarefa digital '
        'caiu de 150 segundos para apenas 47 segundos.',
    reference: 'Dr. Gloria Mark (2023) — Attention Span Data',
    url: 'https://www.penguinrandomhouse.com/books/706203/attention-span-by-gloria-mark/',
    analysisFn: (d) => d.hasData
        ? 'você usou o celular em média ${d.avgDailyMin} min/dia na semana passada — cada sessão curta fragmenta mais a atenção'
        : 'registre alguns dias de uso para ver sua duração média de sessões',
  ),
  InsightEntry(
    icon: Icons.trending_down_outlined,
    title: 'Dreno de produtividade',
    body: 'Alternar entre apps e trabalho pode consumir até 40% do seu tempo '
        'produtivo devido à carga cognitiva da reorientação mental.',
    reference: 'Rubinstein, Meyer & Evans (2001) — Task-Switching Study',
    url: 'https://doi.org/10.1037/0096-3445.130.2.211',
    analysisFn: (d) => d.hasData
        ? 'você desbloqueou o celular ~${d.workUnlocks} vezes no horário de trabalho (9h–18h) na semana passada'
        : 'use o app em dias úteis para ver quantas vezes o celular interrompe seu trabalho',
  ),
  InsightEntry(
    icon: Icons.bedtime_outlined,
    title: 'Atraso da melatonina',
    body: 'Usar telas antes de dormir pode atrasar a liberação de melatonina '
        'em até 30 minutos, prejudicando a capacidade de recuperação cerebral.',
    reference: 'Frontiers in Psychiatry — Digital Nudge Study, 2025',
    url: 'https://www.frontiersin.org/journals/psychiatry',
    analysisFn: (d) => d.hasData
        ? 'você ficou ${d.lateNightMin} min na tela após as 22h na semana passada'
        : 'registre uso noturno para ver quanto do seu sono está sendo afetado',
  ),
  InsightEntry(
    icon: Icons.alarm_outlined,
    title: 'Acordar estressado',
    body: 'Checar o celular nos primeiros 5 minutos após acordar coloca o '
        'cérebro em estado de alto cortisol antes mesmo de sair da cama.',
    reference: 'Mindfulness and Digital Distraction Study',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+cortisol+morning',
    analysisFn: (d) => d.hasData
        ? 'você desbloqueou ${d.earlyUnlocks} vezes antes das 8h na semana passada'
        : 'registre seu uso matinal para ver como você começa os dias',
  ),
  InsightEntry(
    icon: Icons.airline_seat_flat_outlined,
    title: 'Perda de sono REM',
    body: 'Pessoas que usam redes sociais na cama perdem em média 16 minutos '
        'de sono por noite devido à superestimulação cognitiva e à luz azul.',
    reference: 'University of Wisconsin-Madison Attention Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=social+media+REM+sleep+loss',
    analysisFn: (d) => d.hasData
        ? '${d.lateNightMin} min do seu tempo de tela semanal aconteceu após as 22h'
        : 'use o app para rastrear quanto do seu uso cai no horário de sono',
  ),
  InsightEntry(
    icon: Icons.schedule_outlined,
    title: 'Duração do sono',
    body: 'Uso intenso do smartphone (mais de 63h por semana) está diretamente '
        'ligado a uma redução de 6,66 minutos no descanso noturno total.',
    reference: 'Journal of Medical Internet Research, 2025',
    url: 'https://www.jmir.org',
    analysisFn: (d) => d.hasData
        ? 'sua média foi ${d.avgDailyMin} min/dia (${(d.weeklyMin / 60).toStringAsFixed(0)}h na semana) — acima de 63h/semana há risco clínico'
        : 'registre uso por uma semana para comparar com o limite de risco',
  ),
  InsightEntry(
    icon: Icons.autorenew_outlined,
    title: 'O ciclo da ansiedade',
    body: 'Checar notificações com frequência cria um ciclo de "recompensa '
        'intermitente" semelhante às caça-níqueis, condicionando o cérebro a '
        'buscar constantemente o próximo pico de dopamina.',
    reference: 'Psychology of Phone Addiction Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+intermittent+reinforcement+dopamine',
    analysisFn: (d) => d.hasData
        ? 'você desbloqueou ${d.todayUnlocks}× hoje — média de ${d.weeklyUnlocks ~/ 7}/dia na semana passada'
        : 'registre uso hoje para ver quantas vezes você busca essa recompensa',
  ),
  InsightEntry(
    icon: Icons.lock_open_outlined,
    title: 'O custo de desbloquear',
    body: 'Cada vez que você desbloqueia o celular sem um objetivo claro, '
        'reforça vias neurais impulsivas que dificultam a manutenção do foco '
        'em tarefas de longo prazo.',
    reference: 'Longitudinal Investigation of Smartphone Interaction Patterns',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+unlock+impulsive+neural',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyUnlocks} desbloqueios na semana passada, ${d.microSessions} sessões abaixo de 1 min — provavelmente sem objetivo'
        : 'registre uso por alguns dias para ver quantos desbloqueios são impulsivos',
  ),
  InsightEntry(
    icon: Icons.phone_android_outlined,
    title: 'Frequência vs. Sono',
    body: 'Checar o celular mais de 400 vezes por semana aumenta o risco de '
        'baixa qualidade de sono em 61% — um preditor mais forte do que o tempo total.',
    reference: 'Mental Health Journal — Estudo de uso objetivo, 2025',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+check+frequency+sleep+quality',
    analysisFn: (d) => d.hasData
        ? 'você desbloqueou ~${d.weeklyUnlocks} vezes na semana passada${d.weeklyUnlocks > 400 ? " — acima do limiar de risco (400×)" : ""}'
        : 'registre uma semana completa para comparar com o limiar de risco',
  ),
  InsightEntry(
    icon: Icons.bolt_outlined,
    title: 'Estresse do micro-uso',
    body: 'Sessões de uso menores que 10 segundos são tipicamente "checagens '
        'por tédio" que fragmentam a atenção e aumentam os níveis basais de estresse.',
    reference: 'ARDUOUS User Interaction Analysis',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=micro+session+smartphone+stress',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} sessões abaixo de 1 min na semana passada — cada uma é uma checagem por tédio'
        : 'use o app por alguns dias para ver quantas checagens breves você faz',
  ),
  InsightEntry(
    icon: Icons.sentiment_dissatisfied_outlined,
    title: 'Dreno emocional',
    body: 'Rolar feeds passivamente sem interagir está fortemente ligado ao '
        'aumento de sintomas de depressão, ansiedade e inveja social.',
    reference: 'Mobile Sensing Technology — Mental Health Study',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=passive+scrolling+depression+anxiety',
    analysisFn: (d) => d.hasData
        ? 'você passou ${d.passiveMin} min em apps passivos (social, vídeo) na semana passada'
        : 'registre uso por uma semana para ver quanto tempo vai para consumo passivo',
  ),
  InsightEntry(
    icon: Icons.compare_arrows_outlined,
    title: 'O mito do multitarefa',
    body: 'Apenas 2,5% da população consegue fazer multitarefa com eficiência; '
        'para os outros 97,5%, a taxa de erros aumenta 50% ao usar o celular durante o trabalho.',
    reference: 'Watson & Strayer (2010) — Supertasker Profiles',
    url: 'https://doi.org/10.1177/1071181310541514',
    analysisFn: (d) => d.hasData
        ? 'você alternou contexto ~${d.workUnlocks} vezes no horário de trabalho na semana passada'
        : 'registre uso em dias úteis para ver seu padrão de multitarefa',
  ),
  InsightEntry(
    icon: Icons.dynamic_feed_outlined,
    title: 'Doomscrolling',
    body: 'Consumir notícias negativas sem fim ativa a amígdala, mantendo o '
        'corpo em estado constante de "luta ou fuga".',
    reference: 'Emerson Health — Digital Wellness Guidelines',
    url: 'https://www.emersonhospital.org/services/behavioral-health/digital-wellness',
    analysisFn: (d) => d.hasData
        ? '${d.passiveMin} min em apps de social, vídeo e notícias na semana passada'
        : 'registre uso para ver quanto do seu tempo vai para consumo de conteúdo',
  ),
  InsightEntry(
    icon: Icons.flight_outlined,
    title: 'Fuga maladaptativa',
    body: 'Usar o smartphone para "matar o tempo" ou evitar emoções negativas '
        'frequentemente agrava a fadiga digital e o esgotamento mental a longo prazo.',
    reference: 'Cognitive Load Theory and Digital Fatigue Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+escapism+mental+fatigue',
    analysisFn: (d) => d.hasData
        ? 'você usou o celular ${d.weeklyMin} min total na semana passada — quanto foi intenção vs. fuga?'
        : 'registre uso por uma semana para avaliar padrões de fuga',
  ),
  InsightEntry(
    icon: Icons.arrow_downward_outlined,
    title: 'Pressão no pescoço',
    body: 'Inclinar a cabeça 60 graus para olhar o celular exerce 27 kg de '
        'força sobre a coluna cervical.',
    reference: '"Text Neck" Biomechanical Model Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=text+neck+cervical+spine+biomechanics',
    analysisFn: (d) => d.hasData
        ? 'você passou ${d.avgDailyMin} min/dia olhando para baixo — ${(d.avgDailyMin / 60).toStringAsFixed(1)}h de carga cervical diária'
        : 'registre uso para quantificar a carga mecânica diária no seu pescoço',
  ),
  InsightEntry(
    icon: Icons.visibility_outlined,
    title: 'Fadiga visual digital',
    body: 'O uso prolongado de tela reduz a taxa de piscar em até 50%, causando '
        'olhos secos, visão turva e dores de cabeça persistentes.',
    reference: 'Computer Vision Syndrome (CVS) — 20-20-20 Rule Research',
    url: 'https://www.aoa.org/healthy-eyes/eye-and-vision-conditions/computer-vision-syndrome',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyMin} min na tela na semana passada — seus olhos ficaram muito tempo sem descanso'
        : 'registre uso para calcular sua carga visual semanal',
  ),
  InsightEntry(
    icon: Icons.healing_outlined,
    title: 'Risco de dor crônica',
    body: 'Usuários excessivos de smartphone têm risco seis vezes maior de '
        'desenvolver dores crônicas no pescoço e ombros.',
    reference: 'Longitudinal Population-Based Cohort Study (Gustafsson et al.)',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+chronic+neck+pain+Gustafsson',
    analysisFn: (d) => d.hasData
        ? '${d.avgDailyMin} min/dia — uso diário consistente acumula risco crônico ao longo do tempo'
        : 'registre uso diário para ver sua exposição acumulada',
  ),
  InsightEntry(
    icon: Icons.group_outlined,
    title: 'A presença silenciosa',
    body: 'Mesmo um celular virado para baixo sobre a mesa reduz a profundidade '
        'da conversa e a conexão emocional entre as pessoas presentes.',
    reference: 'Sherry Turkle — Reclaiming Conversation Research',
    url: 'https://www.penguinrandomhouse.com/books/312845/reclaiming-conversation-by-sherry-turkle/',
    analysisFn: (d) => d.hasData
        ? 'você pegou o celular ${d.mealUnlocks} vezes nos horários de refeição (12–14h, 19–21h) na semana passada'
        : 'registre uso para ver quantas refeições foram interrompidas pelo celular',
  ),
  InsightEntry(
    icon: Icons.person_remove_outlined,
    title: 'Solidão digital',
    body: 'O "phubbing" — ignorar outros pelo celular — desperta sentimentos de '
        'exclusão e ostracismo em parceiros e amigos, danificando a confiança a longo prazo.',
    reference: 'Seppala (2017) — Phubbing and Relationship Satisfaction Study',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=phubbing+relationship+satisfaction+ostracism',
    analysisFn: (d) => d.hasData
        ? '${d.mealUnlocks} desbloqueios nos horários de refeição na semana passada — cada um foi um momento de phubbing'
        : 'registre uso para quantificar momentos de interrupção de conexão social',
  ),
  InsightEntry(
    icon: Icons.favorite_border_outlined,
    title: 'Declínio da empatia',
    body: 'Estudantes universitários que cresceram com uso intenso de tecnologia '
        'demonstram 40% menos empatia do que gerações anteriores.',
    reference: 'Sherry Turkle & University of Michigan — Empathy Meta-Analysis',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=technology+empathy+decline+college+students',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela na semana passada reduz o tempo de conexão face a face'
        : 'registre uso para ver quanto tempo o celular substitui interação humana',
  ),
  InsightEntry(
    icon: Icons.psychology_alt_outlined,
    title: 'Brain-rot: atrofia cognitiva digital',
    body: 'O consumo crônico de conteúdo curto e hipnótico (Reels, Shorts, TikTok) '
        'reduz a capacidade de tolerar tédio, ler textos longos e manter foco — '
        'um fenômeno chamado de "brain-rot" ou erosão cognitiva digital. '
        'Estudos mostram que após semanas de scroll intenso, o tempo médio de '
        'atenção voluntária cai para menos de 8 segundos.',
    reference: 'Loh & Kanai (2016), "How Has the Internet Reshaped Human Cognition?", The Neuroscientist',
    url: 'https://doi.org/10.1177/1073858415595005',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} sessões abaixo de 1 min na semana — cada uma é um treino do cérebro para rejeitar conteúdo mais longo'
        : 'registre uso por alguns dias para ver sua proporção de sessões ultra-curtas',
  ),
  InsightEntry(
    icon: Icons.auto_graph_outlined,
    title: 'Conteúdo curto destrói a memória',
    body: 'O consumo de vídeos de 15–60 segundos prejudica a consolidação da '
        'memória de trabalho: o cérebro não tem tempo suficiente para processar '
        'e arquivar o que vê, resultando em uma corrente de informações que não '
        'deixa rastro cognitivo — informação sem aprendizado.',
    reference: 'Uncapher & Wagner (2018), "Minds and Brains of Media Multitaskers", PNAS',
    url: 'https://doi.org/10.1073/pnas.1611612115',
    analysisFn: (d) => d.hasData
        ? '${d.passiveMin} min em apps de vídeo/social na semana passada — quanto desse conteúdo você ainda lembra?'
        : 'registre uso para ver quanto tempo vai para consumo de conteúdo descartável',
  ),
  InsightEntry(
    icon: Icons.science_outlined,
    title: 'Celular = droga de design',
    body: 'Neuroimagens mostram que o uso compulsivo de smartphone ativa o '
        'núcleo accumbens da mesma forma que cocaína ou álcool. '
        'A diferença: o smartphone é legal, socialmente aceito e está no bolso '
        '24h por dia. Essa combinação o torna, segundo pesquisadores, '
        'potencialmente mais difícil de controlar do que substâncias ilegais.',
    reference: 'He et al. (2017), "Altered Small-World Brain Networks in Internet Addiction", Scientific Reports',
    url: 'https://doi.org/10.1038/srep41587',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyUnlocks} desbloqueios na semana passada — cada um é uma busca pelo próximo pico de dopamina'
        : 'registre uma semana de uso para ver com que frequência você busca essa recompensa',
  ),
  InsightEntry(
    icon: Icons.warning_amber_outlined,
    title: 'Tolerância e abstinência digital',
    body: 'Usuários compulsivos de smartphone desenvolvem tolerância — precisam '
        'de doses crescentes (mais tempo de tela) para obter o mesmo prazer — '
        'e abstinência — ansiedade, irritabilidade e foco prejudicado quando o '
        'celular não está disponível. Esses são os critérios clínicos de dependência '
        'reconhecidos pela OMS para substâncias.',
    reference: 'Billieux et al. (2015), "Problematic Smartphone Use: Who and Why?", Current Addiction Reports',
    url: 'https://doi.org/10.1007/s40429-015-0054-y',
    analysisFn: (d) => d.hasData
        ? 'você usou ${d.avgDailyMin} min/dia esta semana — note se o padrão aumentou nos últimos meses'
        : 'registre uso por algumas semanas para identificar tendência de aumento de tolerância',
  ),
];

// ─── Soluções (solution cards) ────────────────────────────────────────────────

final kSolucoes = <InsightEntry>[
  InsightEntry(
    icon: Icons.hourglass_empty_outlined,
    title: 'A regra do atrito',
    body: 'Introduzir apenas 10 segundos de atraso antes de abrir um app-alvo '
        'é suficiente para dissipar a maioria dos impulsos de consumo inconsciente.',
    reference: '"One Sec" App — Psychological Mechanism Study, PNAS 2023',
    url: 'https://doi.org/10.1073/pnas.2213580120',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} sessões impulsivas (< 1 min) na semana passada — um atraso de 10s poderia ter evitado a maioria'
        : 'registre uso por alguns dias para ver quantas aberturas são impulsivas',
  ),
  InsightEntry(
    icon: Icons.invert_colors_off_outlined,
    title: 'O poder do escala de cinza',
    body: 'Mudar a tela para preto e branco reduz o uso diário em '
        'aproximadamente 20–40 minutos, tornando os apps menos visualmente recompensadores.',
    reference: 'Holte & Ferraro (2020) — Grayscale Screen Time Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=grayscale+screen+time+reduction',
    analysisFn: (d) => d.hasData
        ? 'sua média é ${d.avgDailyMin} min/dia — escala de cinza poderia economizar 20–40 min diários'
        : 'registre uso por uma semana e compare após ativar escala de cinza',
  ),
  InsightEntry(
    icon: Icons.visibility_off_outlined,
    title: 'Fora da vista',
    body: 'Manter o celular em outro cômodo enquanto trabalha melhora '
        'significativamente a memória de trabalho e a capacidade cognitiva.',
    reference: 'Ward et al. (2017) — "Brain Drain" Study',
    url: 'https://doi.org/10.1086/691462',
    analysisFn: (d) => d.hasData
        ? '${d.workUnlocks} vezes que o celular interrompeu seu trabalho (9h–18h) na semana passada'
        : 'registre uso em dias úteis para medir o impacto do celular na sua concentração',
  ),
  InsightEntry(
    icon: Icons.center_focus_strong_outlined,
    title: 'Treinamento unitarefa',
    body: 'Reconstruir o tempo de atenção exige treinar o cérebro para focar '
        'em um único app ou tarefa por 25 minutos sem interrupção.',
    reference: 'Reclaiming Conversation — Unitasking Principles',
    url: 'https://www.penguinrandomhouse.com/books/312845/reclaiming-conversation-by-sherry-turkle/',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} sessões abaixo de 1 min na semana passada — seu músculo de foco precisa ser treinado'
        : 'registre uso para ver sua capacidade atual de manter o foco',
  ),
  InsightEntry(
    icon: Icons.spa_outlined,
    title: 'Detox de tela',
    body: 'Reduzir o tempo de tela por apenas 3 semanas pode melhorar '
        'indicadores de saúde mental com tamanho de efeito comparável ao de antidepressivos.',
    reference: 'Georgetown University — Digital Detox Study (Kushlev et al., 2025)',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=screen+time+reduction+mental+health+Kushlev',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela na semana passada — 3 semanas de redução já geram ganhos clínicos'
        : 'registre uma semana de uso para planejar seu detox',
  ),
  InsightEntry(
    icon: Icons.remove_circle_outline_outlined,
    title: 'Remoção de gatilhos',
    body: 'Esconder apps de redes sociais em pastas fora da tela inicial reduz '
        'os estímulos visuais que disparam comportamentos automáticos de "checagem".',
    reference: 'Fogg Behavior Model and Multifaceted Nudges',
    url: 'https://behaviordesign.stanford.edu',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} checagens impulsivas na semana passada — remova os gatilhos visuais da tela inicial'
        : 'registre uso para identificar quais apps você abre por impulso',
  ),
  InsightEntry(
    icon: Icons.lock_outlined,
    title: 'Senhas manuais',
    body: 'Desabilitar desbloqueio biométrico em favor de senhas longas adiciona '
        'uma camada de "atrito deliberado" que reduz aberturas impulsivas.',
    reference: 'Nudge-Based Intervention — Randomized Controlled Trial',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=PIN+password+smartphone+impulsive+use',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyUnlocks} desbloqueios na semana passada — atrito adicional reduziria os impulsivos'
        : 'registre quantos desbloqueios você faz para avaliar o impacto do atrito',
  ),
  InsightEntry(
    icon: Icons.hotel_outlined,
    title: 'A regra do quarto',
    body: 'Carregar o celular fora do quarto melhora a qualidade do sono e '
        'previne o pico de cortisol associado ao scroll matinal.',
    reference: 'Digital Detox Benefits and Sleep Quality Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+bedroom+sleep+quality',
    analysisFn: (d) => d.hasData
        ? '${d.lateNightMin} min na tela após as 22h na semana passada — o carregador deveria estar em outro cômodo'
        : 'registre seu uso noturno para medir o impacto do celular no quarto',
  ),
  InsightEntry(
    icon: Icons.notifications_off_outlined,
    title: 'Notificações seletivas',
    body: 'Manter apenas alertas de humano para humano (mensagens) enquanto '
        'desativa "pings" de apps reduz o estresse ambiental constante.',
    reference: 'Intervention for Reducing Non-Essential Notification Disruptions',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=notification+reduction+stress+intervention',
    analysisFn: (d) => d.hasData
        ? '${d.workUnlocks} interrupções no horário de trabalho na semana passada — quantas foram notificações?'
        : 'registre uso para ver o impacto das notificações na sua atenção',
  ),
  InsightEntry(
    icon: Icons.pause_circle_outlined,
    title: 'Pausa de atenção plena',
    body: 'Antes de abrir um app, perguntar "Por que estou pegando isso?" '
        'muda o estado do Sistema 1 (automático) para o Sistema 2 (deliberado).',
    reference: 'Pratt Institute — Digital Wellbeing Journey Guidelines',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=mindful+smartphone+use+system+2+thinking',
    analysisFn: (d) => d.hasData
        ? '${d.weeklyUnlocks} desbloqueios na semana passada — quantos foram conscientes?'
        : 'registre uso para descobrir a proporção de aberturas automáticas vs. intencionais',
  ),
  InsightEntry(
    icon: Icons.remove_red_eye_outlined,
    title: 'A regra 20-20-20',
    body: 'A cada 20 minutos de uso de tela, olhe para algo a 6 metros de '
        'distância por 20 segundos para relaxar os músculos oculares.',
    reference: 'Eye Care Practitioner — Clinical Guidelines for Digital Fatigue',
    url: 'https://www.aao.org/eye-health/tips-prevention/computer-usage',
    analysisFn: (d) => d.hasData
        ? '${d.avgDailyMin} min/dia na tela — isso significa ${d.avgDailyMin ~/ 20} pausas de 20s necessárias por dia'
        : 'registre uso para calcular quantas pausas visuais você deveria fazer',
  ),
  InsightEntry(
    icon: Icons.trending_up_outlined,
    title: 'Metas adaptativas',
    body: 'Reduzir o uso em incrementos semanais de 10% é mais eficaz para '
        'mudança permanente do que tentativas de cortes drásticos e repentinos.',
    reference: 'Rule-Based Adaptive Goals in Habit Formation',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=adaptive+goal+smartphone+habit+reduction',
    analysisFn: (d) => d.hasData
        ? 'você está em ${d.avgDailyMin} min/dia — uma meta de 10% a menos = ${(d.avgDailyMin * 0.9).round()} min/dia'
        : 'registre uso por uma semana para definir sua meta de redução de 10%',
  ),
  InsightEntry(
    icon: Icons.access_time_outlined,
    title: 'Custo de oportunidade',
    body: 'Visualizar o tempo de tela como "horas perdidas" ajuda a priorizar '
        'hobbies do mundo real, exercícios e sono profundo.',
    reference: 'PNAS Nexus (2025) — Blocking Mobile Internet Study',
    url: 'https://doi.org/10.1093/pnasnexus/pgae080',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela na semana passada — o equivalente a ${(d.weeklyMin / 60 * 30).round()} páginas lidas, ${(d.weeklyMin / 60 * 5).round()} km caminhados'
        : 'registre uso por uma semana para calcular o que você poderia ter feito',
  ),
  InsightEntry(
    icon: Icons.park_outlined,
    title: 'Reinicialização pela natureza',
    body: 'Passar 3 dias na natureza sem celular pode aumentar a função '
        'cognitiva e a criatividade em até 50%.',
    reference: '"Three-Day Effect" and Attention Restoration Theory',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=nature+three+day+effect+attention+restoration',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela esta semana — seu córtex pré-frontal precisa de natureza para recuperar'
        : 'registre uso por uma semana para planejar seu próximo detox na natureza',
  ),
  InsightEntry(
    icon: Icons.fitness_center_outlined,
    title: 'Fortalecimento pré-frontal',
    body: 'Períodos diários de "jejum digital" ajudam a fortalecer o córtex '
        'pré-frontal, devolvendo o controle sobre decisões e reduzindo o vício.',
    reference: 'Mindfulness Practice for Behavioral Addiction Research',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=digital+fasting+prefrontal+cortex+addiction',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} impulsos de checagem na semana passada — o córtex pré-frontal pode retomar esse controle'
        : 'registre uso para medir o quanto o impulso digital domina suas escolhas',
  ),
  InsightEntry(
    icon: Icons.directions_walk_outlined,
    title: 'Recuperação ativa',
    body: 'Substituir 5 minutos de scroll por uma caminhada rápida rejuvenesce '
        'o cérebro e reduz a fadiga mental mais rápido que o entretenimento digital.',
    reference: 'CareerBuilder — Workplace Productivity Suggestion',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=walking+mental+fatigue+screen+replacement',
    analysisFn: (d) => d.hasData
        ? '${(d.weeklyMin / 60).toStringAsFixed(0)}h de tela esta semana — substituir 5 min de scroll por caminhada faz diferença real'
        : 'registre uso para identificar janelas onde uma caminhada substituiria o scroll',
  ),
  InsightEntry(
    icon: Icons.bar_chart_outlined,
    title: 'A lacuna da subestimação',
    body: 'Usuários tipicamente subestimam seu uso real de smartphone em 20% '
        'a 50% — até que vejam dados objetivos de rastreamento.',
    reference: 'Agreement Between Self-Reported and Objective Usage Study',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=smartphone+self+report+underestimate+objective',
    analysisFn: (d) => d.hasData
        ? 'o rastreador registra ${d.avgDailyMin} min/dia — acima do que a maioria das pessoas estima para si mesma'
        : 'use o app para obter os dados reais e comparar com o que você imagina usar',
  ),
  InsightEntry(
    icon: Icons.filter_list_outlined,
    title: 'Auditoria do feed',
    body: 'Deixar de seguir contas que geram emoções negativas pode '
        'transformar o uso passivo em uma experiência mais neutra ou positiva.',
    reference: 'Digital Wellness Guidelines for Doomscrolling',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=unfollow+negative+content+social+media+wellbeing',
    analysisFn: (d) => d.hasData
        ? '${d.passiveMin} min em apps passivos esta semana — vale auditar o que esse feed está te entregando'
        : 'registre uso para ver quanto tempo vai para consumo passivo de conteúdo',
  ),
  InsightEntry(
    icon: Icons.menu_book_outlined,
    title: 'Leitura longa como antídoto',
    body: 'Ler 20 minutos de texto contínuo por dia — livro, artigo, ensaio — '
        'reconstrói o músculo da atenção sustentada e reverte parcialmente '
        'os efeitos do consumo fragmentado. É o oposto estrutural do scroll: '
        'exige atenção linear, memória de trabalho e síntese ativa.',
    reference: 'Wolf (2018), "Reader, Come Home: The Reading Brain in a Digital World", HarperCollins',
    url: 'https://pubmed.ncbi.nlm.nih.gov/?term=deep+reading+brain+attention+Wolf',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} checagens impulsivas na semana passada — cada sessão longa de leitura desfaz vários desses danos'
        : 'registre uso para medir a proporção de sessões fragmentadas vs. profundas',
  ),
  InsightEntry(
    icon: Icons.self_improvement_outlined,
    title: 'Tédio como exercício cognitivo',
    body: 'Tolerar o tédio sem recorrer ao celular é, literalmente, um treino '
        'cerebral: ativa a rede de modo padrão (default mode network), '
        'responsável pela criatividade, autopercepção e consolidação de memórias. '
        'O scroll infinito suprime essa rede, empobrecendo o pensamento espontâneo.',
    reference: 'Smallwood & Schooler (2015), "The Science of Mind Wandering", Annual Review of Psychology',
    url: 'https://doi.org/10.1146/annurev-psych-010814-015331',
    analysisFn: (d) => d.hasData
        ? '${d.microSessions} vezes que você buscou o celular ao sentir tédio esta semana — experimente esperar 2 minutos antes de pegar'
        : 'registre uso para identificar quantas aberturas são respostas automáticas ao tédio',
  ),
  InsightEntry(
    icon: Icons.spa_outlined,
    title: 'Protocolos de dependência aplicados ao celular',
    body: 'Técnicas validadas para dependência química funcionam para smartphones: '
        'identificar gatilhos situacionais, criar fricção para o comportamento-alvo '
        'e substituir por comportamento incompatível (caminhar, respirar, ler). '
        'A estrutura é a mesma — só o objeto da dependência muda.',
    reference: 'Throuvala et al. (2019), "Motivational and Self-Control Mechanisms", Journal of Behavioral Addictions',
    url: 'https://doi.org/10.1556/2006.8.2019.43',
    analysisFn: (d) => d.hasData
        ? 'você tem ${d.weeklyUnlocks} desbloqueios semanais — identifique os 3 principais gatilhos e crie atrito para cada um'
        : 'registre uso por uma semana para mapear seus principais gatilhos de abertura',
  ),
  InsightEntry(
    icon: Icons.group_work_outlined,
    title: 'Responsabilidade social como âncora',
    body: 'Em programas de recuperação de dependência, o suporte social é '
        'o preditor mais forte de sucesso a longo prazo. Aplicado ao uso digital: '
        'compartilhar metas de uso com um parceiro, amigo ou grupo aumenta '
        'significativamente a adesão e reduz recaídas.',
    reference: 'Kelly et al. (2020), "Mechanisms of Behavior Change in AA", Addiction',
    url: 'https://doi.org/10.1111/add.14906',
    analysisFn: (d) => d.hasData
        ? 'sua meta atual: se um amigo soubesse seus ${d.avgDailyMin} min/dia, isso mudaria seu comportamento?'
        : 'registre uso por uma semana e compartilhe os dados com alguém de confiança',
  ),
];
