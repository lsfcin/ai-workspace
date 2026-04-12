import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class _Insight {
  const _Insight({
    required this.title,
    required this.body,
    required this.reference,
  });
  final String title;
  final String body;
  final String reference;
}

// ─── Content (PT-BR; add _alertasEn / _solucoesEn for EN translation) ────────

const _alertas = [
  // Impulsividade e hábito de checar
  _Insight(
    title: 'Frequência vs. Sono',
    body: 'Checar o celular mais de 400 vezes por semana aumenta o risco de '
        'baixa qualidade de sono em 61% — um preditor muito mais forte do que '
        'o tempo total de tela.',
    reference: 'Mental Health Journal — Estudo de uso objetivo de smartphone, 2025',
  ),
  _Insight(
    title: 'O ciclo da ansiedade',
    body: 'Checar notificações com frequência cria um ciclo de "recompensa '
        'intermitente" semelhante às caça-níqueis, condicionando o cérebro a '
        'buscar constantemente o próximo pico de dopamina.',
    reference: 'Psychology of Phone Addiction Research',
  ),
  _Insight(
    title: 'O custo de desbloquear',
    body: 'Cada vez que você desbloqueia o celular sem um objetivo claro, '
        'reforça vias neurais impulsivas que dificultam a manutenção do foco '
        'em tarefas de longo prazo.',
    reference: 'Longitudinal Investigation of Smartphone Interaction Patterns',
  ),
  _Insight(
    title: 'Estresse do micro-uso',
    body: 'Sessões de uso menores que 10 segundos são tipicamente "checagens '
        'por tédio" que fragmentam a atenção e aumentam os níveis basais de '
        'estresse.',
    reference: 'ARDUOUS User Interaction Analysis',
  ),
  // Sono e luz azul
  _Insight(
    title: 'Atraso da melatonina',
    body: 'Usar telas antes de dormir pode atrasar a liberação de melatonina '
        'em até 30 minutos, prejudicando a capacidade de recuperação cerebral '
        'durante a noite.',
    reference: 'Frontiers in Psychiatry — Digital Nudge Study, 2025',
  ),
  _Insight(
    title: 'Perda de sono REM',
    body: 'Pessoas que usam redes sociais na cama perdem em média 16 minutos '
        'de sono por noite devido à superestimulação cognitiva e à luz azul.',
    reference: 'University of Wisconsin-Madison Attention Research',
  ),
  _Insight(
    title: 'Acordar estressado',
    body: 'Checar o celular nos primeiros 5 minutos após acordar coloca o '
        'cérebro em estado de alerta de alto cortisol antes mesmo de sair '
        'da cama.',
    reference: 'Mindfulness and Digital Distraction Study',
  ),
  _Insight(
    title: 'Duração do sono',
    body: 'Uso intenso do smartphone (mais de 63h por semana) está diretamente '
        'ligado a uma redução de 6,66 minutos no descanso noturno total.',
    reference: 'Journal of Medical Internet Research, 2025',
  ),
  // Foco, produtividade e multitarefa
  _Insight(
    title: 'A regra dos 23 minutos',
    body: 'Após uma única interrupção por notificação, o cérebro leva em média '
        '23 minutos e 15 segundos para retomar o foco profundo na tarefa '
        'original.',
    reference: 'Gloria Mark, UCI — Cost of Interrupted Work',
  ),
  _Insight(
    title: 'Queda temporária de QI',
    body: 'A multitarefa digital pode reduzir o QI funcional em 10 pontos — '
        'um impacto cognitivo maior do que perder uma noite inteira de sono.',
    reference: 'American Psychological Association — Multitasking Research',
  ),
  _Insight(
    title: 'Dreno de produtividade',
    body: 'Alternar entre apps e trabalho pode consumir até 40% do seu tempo '
        'produtivo devido à carga cognitiva da reorientação mental.',
    reference: 'Rubinstein, Meyer & Evans (2001) — Task-Switching Study',
  ),
  _Insight(
    title: 'Erosão da atenção',
    body: 'Nos últimos 20 anos, o tempo médio de atenção em uma tarefa digital '
        'caiu de 150 segundos para apenas 47 segundos.',
    reference: 'Dr. Gloria Mark (2023) — Attention Span Data',
  ),
  _Insight(
    title: 'O mito do multitarefa',
    body: 'Apenas 2,5% da população consegue fazer multitarefa com eficiência; '
        'para os outros 97,5%, a taxa de erros aumenta 50% ao usar o celular '
        'durante o trabalho.',
    reference: 'Watson & Strayer (2010) — Supertasker Profiles',
  ),
  // Consumo passivo vs. ativo
  _Insight(
    title: 'Dreno emocional',
    body: 'Rolar feeds passivamente sem interagir está fortemente ligado ao '
        'aumento de sintomas de depressão, ansiedade e inveja social.',
    reference: 'Mobile Sensing Technology — Mental Health Study',
  ),
  _Insight(
    title: 'Fuga maladaptativa',
    body: 'Usar o smartphone para "matar o tempo" ou evitar emoções negativas '
        'frequentemente agrava a fadiga digital e o esgotamento mental '
        'a longo prazo.',
    reference: 'Cognitive Load Theory and Digital Fatigue Research',
  ),
  _Insight(
    title: 'Doomscrolling',
    body: 'Consumir notícias negativas sem fim ativa a amígdala, mantendo o '
        'corpo em estado constante de "luta ou fuga".',
    reference: 'Emerson Health — Digital Wellness Guidelines',
  ),
  // Saúde física e ergonomia
  _Insight(
    title: 'Pressão no pescoço',
    body: 'Inclinar a cabeça 60 graus para olhar o celular exerce 27 kg de '
        'força sobre a coluna cervical.',
    reference: '"Text Neck" Biomechanical Model Research',
  ),
  _Insight(
    title: 'Risco de dor crônica',
    body: 'Usuários excessivos de smartphone têm risco seis vezes maior de '
        'desenvolver dores crônicas no pescoço e ombros.',
    reference: 'Longitudinal Population-Based Cohort Study (Gustafsson et al.)',
  ),
  _Insight(
    title: 'Fadiga visual digital',
    body: 'O uso prolongado de tela reduz a taxa de piscar em até 50%, causando '
        'olhos secos, visão turva e dores de cabeça persistentes.',
    reference: 'Computer Vision Syndrome (CVS) — 20-20-20 Rule Research',
  ),
  // Impacto social (phubbing)
  _Insight(
    title: 'A presença silenciosa',
    body: 'Mesmo um celular virado para baixo sobre a mesa reduz a profundidade '
        'da conversa e a conexão emocional entre as pessoas presentes.',
    reference: 'Sherry Turkle — Reclaiming Conversation Research',
  ),
  _Insight(
    title: 'Solidão digital',
    body: 'O "phubbing" — ignorar outros pelo celular — desperta sentimentos de '
        'exclusão e ostracismo em parceiros e amigos, danificando a confiança '
        'a longo prazo.',
    reference: 'Seppala (2017) — Phubbing and Relationship Satisfaction Study',
  ),
  _Insight(
    title: 'Declínio da empatia',
    body: 'Estudantes universitários que cresceram com uso intenso de tecnologia '
        'demonstram 40% menos empatia do que gerações anteriores.',
    reference: 'Sherry Turkle & University of Michigan — Empathy Meta-Analysis',
  ),
];

const _solucoes = [
  // Técnicas de mudança de hábito
  _Insight(
    title: 'O poder do escala de cinza',
    body: 'Mudar a tela para preto e branco reduz o uso diário em '
        'aproximadamente 20–40 minutos, tornando os apps menos '
        'visualmente recompensadores.',
    reference: 'Holte & Ferraro (2020) — Grayscale Screen Time Research',
  ),
  _Insight(
    title: 'A regra do atrito',
    body: 'Introduzir apenas 10 segundos de atraso antes de abrir um app-alvo '
        'é suficiente para dissipar a maioria dos impulsos de consumo '
        'inconsciente.',
    reference: '"One Sec" App — Psychological Mechanism Study, PNAS 2023',
  ),
  _Insight(
    title: 'Fora da vista',
    body: 'Manter o celular em outro cômodo enquanto trabalha melhora '
        'significativamente a memória de trabalho e a capacidade cognitiva.',
    reference: 'Ward et al. (2017) — "Brain Drain" Study',
  ),
  _Insight(
    title: 'Senhas manuais',
    body: 'Desabilitar desbloqueio biométrico em favor de senhas longas adiciona '
        'uma camada de "atrito deliberado" que reduz aberturas impulsivas.',
    reference: 'Nudge-Based Intervention — Randomized Controlled Trial',
  ),
  _Insight(
    title: 'A regra 20-20-20',
    body: 'A cada 20 minutos de uso de tela, olhe para algo a 6 metros de '
        'distância por 20 segundos para relaxar os músculos oculares.',
    reference: 'Eye Care Practitioner — Clinical Guidelines for Digital Fatigue',
  ),
  // Bem-estar e recuperação
  _Insight(
    title: 'Reinicialização pela natureza',
    body: 'Passar 3 dias na natureza sem celular pode aumentar a função '
        'cognitiva e a criatividade em até 50%.',
    reference: '"Three-Day Effect" and Attention Restoration Theory',
  ),
  _Insight(
    title: 'Detox de tela',
    body: 'Reduzir o tempo de tela por apenas 3 semanas pode melhorar '
        'indicadores de saúde mental com tamanho de efeito comparável '
        'ao de antidepressivos.',
    reference: 'Georgetown University — Digital Detox Study (Kushlev et al., 2025)',
  ),
  _Insight(
    title: 'Fortalecimento pré-frontal',
    body: 'Períodos diários de "jejum digital" ajudam a fortalecer o córtex '
        'pré-frontal, devolvendo o controle sobre decisões e reduzindo '
        'o vício em internet.',
    reference: 'Mindfulness Practice for Behavioral Addiction Research',
  ),
  _Insight(
    title: 'Treinamento unitarefa',
    body: 'Reconstruir o tempo de atenção exige treinar o cérebro para focar '
        'em um único app ou tarefa por 25 minutos sem interrupção.',
    reference: 'Reclaiming Conversation — Unitasking Principles',
  ),
  // Consciência e ambiente
  _Insight(
    title: 'A lacuna da subestimação',
    body: 'Usuários tipicamente subestimam seu uso real de smartphone em 20% '
        'a 50% — até que vejam dados objetivos de rastreamento.',
    reference: 'Agreement Between Self-Reported and Objective Usage Study',
  ),
  _Insight(
    title: 'Metas adaptativas',
    body: 'Reduzir o uso em incrementos semanais de 10% é mais eficaz para '
        'mudança permanente do que tentativas de cortes drásticos e '
        'repentinos.',
    reference: 'Rule-Based Adaptive Goals in Habit Formation',
  ),
  _Insight(
    title: 'Custo de oportunidade',
    body: 'Visualizar o tempo de tela como "horas perdidas" ajuda a priorizar '
        'hobbies do mundo real, exercícios e sono profundo.',
    reference: 'PNAS Nexus (2025) — Blocking Mobile Internet Study',
  ),
  _Insight(
    title: 'Remoção de gatilhos',
    body: 'Esconder apps de redes sociais em pastas fora da tela inicial reduz '
        'os estímulos visuais que disparam comportamentos automáticos de '
        '"checagem".',
    reference: 'Fogg Behavior Model and Multifaceted Nudges',
  ),
  _Insight(
    title: 'Auditoria do feed',
    body: 'Deixar de seguir contas que geram emoções negativas pode '
        'transformar o uso passivo em uma experiência mais neutra ou positiva.',
    reference: 'Digital Wellness Guidelines for Doomscrolling',
  ),
  _Insight(
    title: 'Recuperação ativa',
    body: 'Substituir 5 minutos de scroll por uma caminhada rápida rejuvenesce '
        'o cérebro e reduz a fadiga mental mais rápido que o entretenimento '
        'digital.',
    reference: 'CareerBuilder — Workplace Productivity Suggestion',
  ),
  _Insight(
    title: 'A regra do quarto',
    body: 'Carregar o celular fora do quarto melhora a qualidade do sono e '
        'previne o pico de cortisol associado ao scroll matinal.',
    reference: 'Digital Detox Benefits and Sleep Quality Research',
  ),
  _Insight(
    title: 'Notificações seletivas',
    body: 'Manter apenas alertas de humano para humano (mensagens) enquanto '
        'desativa "pings" de apps reduz o estresse ambiental constante.',
    reference: 'Intervention for Reducing Non-Essential Notification Disruptions',
  ),
  _Insight(
    title: 'Pausa de atenção plena',
    body: 'Antes de abrir um app, perguntar "Por que estou pegando isso?" '
        'muda o estado do Sistema 1 (automático) para o Sistema 2 '
        '(deliberado).',
    reference: 'Pratt Institute — Digital Wellbeing Journey Guidelines',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.insightsTitle),
          bottom: TabBar(tabs: [
            Tab(text: l10n.tabAlerts),
            Tab(text: l10n.tabSolutions),
          ]),
        ),
        body: const TabBarView(
          children: [
            _InsightList(insights: _alertas),
            _InsightList(insights: _solucoes),
          ],
        ),
      ),
    );
  }
}

class _InsightList extends StatelessWidget {
  const _InsightList({required this.insights});
  final List<_Insight> insights;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: insights.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _InsightTile(insight: insights[i]),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});
  final _Insight insight;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insight.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(insight.body, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              insight.reference,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
