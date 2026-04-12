import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

// ─── Passive app heuristic ────────────────────────────────────────────────────
const _passivePatterns = [
  'instagram', 'tiktok', 'youtube', 'netflix', 'twitter', 'facebook',
  'reddit', 'pinterest', 'snapchat', 'twitch', 'hulu', 'disneyplus',
  'kwai', 'likee', 'reels', 'shorts',
];

bool _isPassive(String pkg) {
  final lower = pkg.toLowerCase();
  return _passivePatterns.any(lower.contains);
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.storage});
  final StorageService storage;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final AnalyticsService _analytics;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _analytics = AnalyticsService(widget.storage);
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: '24h'),
            Tab(text: '7 dias'),
            Tab(text: '30 dias'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _Tab24h(storage: widget.storage, analytics: _analytics),
          _Tab7d(storage: widget.storage, analytics: _analytics),
          _Tab30d(storage: widget.storage, analytics: _analytics),
        ],
      ),
    );
  }
}

// ─── Tab helpers ─────────────────────────────────────────────────────────────

String _fmtDuration(int ms) {
  final totalMin = ms ~/ 60000;
  if (totalMin < 60) return '${totalMin}min';
  final h = totalMin ~/ 60;
  final m = totalMin % 60;
  return '${h}h${m.toString().padLeft(2, '0')}';
}

String _todayStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _dateStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Widget _analysisCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required Widget chart,
  required String text,
  double chartHeight = 140,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    )),
          ]),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(height: chartHeight, child: chart),
          const SizedBox(height: AppSpacing.sm),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

Widget _noData(BuildContext context, [String msg = 'Sem dados ainda.']) =>
    Center(
      child: Text(msg,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.outline)),
    );

// ─── TAB 24h ─────────────────────────────────────────────────────────────────

class _Tab24h extends StatelessWidget {
  const _Tab24h({required this.storage, required this.analytics});
  final StorageService storage;
  final AnalyticsService analytics;

  @override
  Widget build(BuildContext context) {
    final today = _todayStr();
    final summaries = analytics.getSummaries(1);
    final summary = summaries.isEmpty ? null : summaries.first;
    final totalMs = summary?.totalMs ?? 0;
    final unlocks = summary?.unlockCount ?? 0;

    final hourlyMs = storage.getDeviceHourlyBreakdown(today);
    final hourlyUnlocks = storage.getHourlyUnlockBreakdown(today);
    final sessionBuckets = storage.getSessionBuckets();
    final hasHourly = hourlyMs.any((v) => v > 0);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Summary row
        Row(children: [
          Expanded(child: _StatCard(label: 'Uso total', value: _fmtDuration(totalMs))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCard(label: 'Desbloqueios', value: '$unlocks')),
        ]),
        const SizedBox(height: AppSpacing.md),

        // Block 1 — Sleep Hygiene
        _analysisCard(
          context: context,
          icon: Icons.bedtime_outlined,
          title: 'Higiene do sono',
          chartHeight: 150,
          chart: hasHourly
              ? _HourlyBarChart(values: hourlyMs, highlightHours: {22, 23, 0, 1, 2, 3, 4, 5})
              : _noData(context, 'Coletando dados — volte mais tarde.'),
          text: _sleepText(hourlyMs, totalMs),
        ),

        // Block 2 — Impulsivity
        _analysisCard(
          context: context,
          icon: Icons.bolt_outlined,
          title: 'Índice de impulsividade',
          chart: hasHourly
              ? _HourlyBarChart(values: hourlyUnlocks, color: AppColors.error)
              : _noData(context, 'Coletando dados — volte mais tarde.'),
          text: 'Você desbloqueou o celular $unlocks vezes hoje. '
              'A frequência de desbloqueios é um preditor mais forte de ansiedade '
              'e baixa qualidade de sono do que o tempo total de tela.',
        ),

        // Block 3 — Focus Fragmentation
        _analysisCard(
          context: context,
          icon: Icons.grid_view_outlined,
          title: 'Fragmentação do foco',
          chart: sessionBuckets.any((v) => v > 0)
              ? _SessionHistogram(buckets: sessionBuckets)
              : _noData(context, 'Coletando dados — volte mais tarde.'),
          text: _focusText(sessionBuckets),
        ),

        // Block 7 — Opportunity Cost
        _analysisCard(
          context: context,
          icon: Icons.hourglass_empty_outlined,
          title: 'Custo de oportunidade',
          chartHeight: 80,
          chart: _OpportunityCostWidget(totalMs: totalMs),
          text: 'Cada hora de uso passivo é uma hora que poderia ser '
              'dedicada a sono reparador, exercício ou conexão presencial.',
        ),

        // Block 9 — Phubbing
        _analysisCard(
          context: context,
          icon: Icons.group_outlined,
          title: 'Alerta de phubbing',
          chart: hasHourly
              ? _HourlyBarChart(
                  values: hourlyUnlocks,
                  highlightHours: {12, 13, 14, 19, 20, 21},
                  color: AppColors.primary,
                )
              : _noData(context, 'Coletando dados — volte mais tarde.'),
          text: _phubbingText(hourlyUnlocks),
        ),
      ],
    );
  }

  String _sleepText(List<int> hourly, int totalMs) {
    final lateMs = [22, 23, 0, 1, 2, 3, 4, 5]
        .fold<int>(0, (sum, h) => sum + hourly[h]);
    final pct = totalMs > 0 ? (lateMs / totalMs * 100).round() : 0;
    return 'Seu uso entre 22h e 6h representa $pct% do tempo total. '
        'A luz azul nesse período pode atrasar a secreção de melatonina '
        'em até 30 minutos, prejudicando a fase REM do sono.';
  }

  String _focusText(List<int> buckets) {
    final total = buckets.fold(0, (a, b) => a + b);
    if (total == 0) return 'Nenhuma sessão registrada ainda.';
    final micro = buckets[0];
    final pct = (micro / total * 100).round();
    return '$pct% das suas sessões duraram menos de 60 segundos. '
        'Esse "hábito de checar" fragmenta a atenção e impede o estado de '
        'foco profundo (Flow). Usuários com alta fragmentação levam até 20% '
        'mais tempo para completar tarefas complexas.';
  }

  String _phubbingText(List<int> hourlyUnlocks) {
    final mealUnlocks = [12, 13, 14, 19, 20, 21]
        .fold<int>(0, (sum, h) => sum + hourlyUnlocks[h]);
    return 'Você desbloqueou o celular $mealUnlocks vezes nos horários de '
        'almoço e jantar. O phubbing — ignorar quem está presente para '
        'olhar o celular — enfraquece laços sociais e aumenta sentimentos '
        'de solidão a longo prazo.';
  }
}

// ─── TAB 7 dias ───────────────────────────────────────────────────────────────

class _Tab7d extends StatelessWidget {
  const _Tab7d({required this.storage, required this.analytics});
  final StorageService storage;
  final AnalyticsService analytics;

  @override
  Widget build(BuildContext context) {
    final summaries = analytics.getSummaries(7);
    final totalMs = summaries.fold<int>(0, (acc, s) => acc + s.totalMs);
    final totalUnlocks = summaries.fold<int>(0, (acc, s) => acc + s.unlockCount);

    final aggApps = <String, _AppAgg>{};
    for (final s in summaries) {
      for (final a in s.apps) {
        final agg = aggApps.putIfAbsent(a.packageName, () => _AppAgg(a.packageName));
        agg.ms += a.dailyMs;
        agg.opens += a.openCount;
      }
    }
    final sorted = aggApps.values.toList()..sort((a, b) => b.opens.compareTo(a.opens));
    final topFive = sorted.take(5).toList();

    final passiveMs = aggApps.values
        .where((a) => _isPassive(a.packageName))
        .fold<int>(0, (s, a) => s + a.ms);
    final activeMs = totalMs - passiveMs;

    // 7d daily bars
    final dailyBars = summaries.reversed.toList();

    // Trend vs previous week
    final prevSummaries = _prevWeekSummaries();
    final prevAvgMs = prevSummaries.isEmpty
        ? 0
        : prevSummaries.fold<int>(0, (s, d) => s + d) ~/ prevSummaries.length;
    final thisAvgMs = summaries.isEmpty ? 0 : totalMs ~/ summaries.length;
    final trendPct = prevAvgMs > 0
        ? ((thisAvgMs - prevAvgMs) / prevAvgMs * 100).round()
        : 0;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(children: [
          Expanded(child: _StatCard(label: 'Tempo total', value: _fmtDuration(totalMs))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCard(label: 'Desbloqueios', value: '$totalUnlocks')),
        ]),
        const SizedBox(height: AppSpacing.md),

        // Daily bar chart
        if (dailyBars.isNotEmpty) ...[
          Text('Uso diário', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 120,
            child: BarChart(BarChartData(
              barGroups: dailyBars.asMap().entries.map((e) {
                final hours = e.value.totalMs / 3_600_000;
                return BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(
                    toY: hours,
                    color: AppColors.primary,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ]);
              }).toList(),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            )),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Block 5 — Dopamine Drain
        _analysisCard(
          context: context,
          icon: Icons.psychology_outlined,
          title: 'Dreno de dopamina',
          chartHeight: topFive.isEmpty ? 60 : (topFive.length * 44.0),
          chart: topFive.isEmpty
              ? _noData(context)
              : _HorizontalAppBars(apps: topFive, maxMs: topFive.first.ms),
          text: topFive.isEmpty
              ? 'Nenhum dado ainda.'
              : 'O app "${topFive.first.packageName.split('.').last}" foi seu '
                  'maior gatilho: ${topFive.first.opens} aberturas em 7 dias. '
                  'Apps de scroll infinito são projetados como "caça-níqueis" — '
                  'recompensa intermitente que cria ciclos compulsivos difíceis de quebrar.',
        ),

        // Block 4 — Engagement Balance
        _analysisCard(
          context: context,
          icon: Icons.balance_outlined,
          title: 'Balanço de engajamento',
          chartHeight: 160,
          chart: (passiveMs + activeMs) > 0
              ? _DonutChart(passiveMs: passiveMs, activeMs: activeMs)
              : _noData(context),
          text: _engagementText(passiveMs, totalMs),
        ),

        // Block 6 — Trend
        _analysisCard(
          context: context,
          icon: Icons.trending_down_outlined,
          title: 'Tendência semanal',
          chart: _TrendBars(
            thisWeek: dailyBars.map((s) => s.totalMs).toList(),
            prevAvgMs: prevAvgMs,
          ),
          text: trendPct <= 0
              ? 'Você reduziu seu uso em ${trendPct.abs()}% vs. a semana anterior. '
                  'Manter essa tendência por 21 dias é o marco científico '
                  'para a reformulação de hábitos neurais.'
              : 'Seu uso aumentou $trendPct% vs. a semana anterior. '
                  'Tente identificar os gatilhos que levaram ao aumento.',
        ),
      ],
    );
  }

  String _engagementText(int passiveMs, int totalMs) {
    if (totalMs == 0) return 'Sem dados ainda.';
    final pct = (passiveMs / totalMs * 100).round();
    return 'Seu uso foi $pct% passivo esta semana. '
        'O consumo passivo de feed (sem interagir) está ligado a ruminação '
        'e sintomas de depressão, enquanto o uso ativo (mensagens reais) '
        'pode ter efeito protetor na saúde mental.';
  }

  List<int> _prevWeekSummaries() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = _dateStr(today.subtract(Duration(days: i + 7)));
      return storage.getDeviceDailyMs(date: date);
    });
  }
}

// ─── TAB 30 dias ─────────────────────────────────────────────────────────────

class _Tab30d extends StatelessWidget {
  const _Tab30d({required this.storage, required this.analytics});
  final StorageService storage;
  final AnalyticsService analytics;

  @override
  Widget build(BuildContext context) {
    final summaries = analytics.getSummaries(30);
    final totalMs = summaries.fold<int>(0, (acc, s) => acc + s.totalMs);
    final totalUnlocks = summaries.fold<int>(0, (acc, s) => acc + s.unlockCount);

    final dailyMs = summaries.reversed.map((s) => s.totalMs).toList();

    // Weekend spike: Sat (6) and Sun (7) vs weekdays
    final today = DateTime.now();
    int weekendMs = 0, weekdayMs = 0, weekendDays = 0, weekdayDays = 0;
    for (int i = 0; i < summaries.length; i++) {
      final date = today.subtract(Duration(days: i));
      final ms = summaries[i].totalMs;
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        weekendMs += ms;
        weekendDays++;
      } else {
        weekdayMs += ms;
        weekdayDays++;
      }
    }
    final avgWeekend = weekendDays > 0 ? weekendMs ~/ weekendDays : 0;
    final avgWeekday = weekdayDays > 0 ? weekdayMs ~/ weekdayDays : 0;
    final weekendSpike = avgWeekday > 0
        ? ((avgWeekend - avgWeekday) / avgWeekday * 100).round()
        : 0;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(children: [
          Expanded(child: _StatCard(label: 'Tempo total', value: _fmtDuration(totalMs))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCard(label: 'Desbloqueios', value: '$totalUnlocks')),
        ]),
        const SizedBox(height: AppSpacing.md),

        // Block 6 — 30d trend line
        _analysisCard(
          context: context,
          icon: Icons.show_chart_outlined,
          title: 'Tendência 30 dias',
          chartHeight: 160,
          chart: dailyMs.isNotEmpty
              ? _LineChart30d(dailyMs: dailyMs)
              : _noData(context),
          text: 'Manter uma tendência de queda por 21 dias consecutivos é '
              'o marco científico para a reformulação de circuitos de hábito '
              'e fortalecimento do córtex pré-frontal.',
        ),

        // Block 8 — Weekend Spike / Heatmap
        _analysisCard(
          context: context,
          icon: Icons.beach_access_outlined,
          title: 'Padrão de fim de semana',
          chartHeight: 180,
          chart: summaries.isNotEmpty
              ? _HeatmapCalendar(summaries: summaries, storage: storage)
              : _noData(context),
          text: weekendSpike > 0
              ? 'Seu uso aumenta ${weekendSpike.abs()}% nos finais de semana. '
                  'Embora pareça lazer, o uso excessivo nos dias de descanso '
                  'impede a recuperação cognitiva do estresse semanal.'
              : 'Seu uso no fim de semana é similar ao dos dias úteis. '
                  'Isso pode indicar um padrão de uso crônico ou '
                  'uma rotina saudável e consistente.',
        ),
      ],
    );
  }
}

// ─── Chart widgets ────────────────────────────────────────────────────────────

/// 24-bar chart colored by hour; [highlightHours] shown in a different color.
class _HourlyBarChart extends StatelessWidget {
  const _HourlyBarChart({
    required this.values,
    this.highlightHours = const {},
    this.color,
  });
  final List<int> values;
  final Set<int> highlightHours;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final maxVal = values.fold(0, (a, b) => a > b ? a : b).toDouble();
    return BarChart(BarChartData(
      maxY: maxVal > 0 ? maxVal * 1.2 : 1,
      barGroups: List.generate(24, (h) {
        final isHighlight = highlightHours.contains(h);
        return BarChartGroupData(x: h, barRods: [
          BarChartRodData(
            toY: values[h].toDouble(),
            color: color ??
                (isHighlight
                    ? const Color(0xFF7C3AED)
                    : AppColors.primary.withAlpha(180)),
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
        ]);
      }),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 18,
            getTitlesWidget: (v, _) {
              final h = v.toInt();
              if (h % 6 != 0) return const SizedBox.shrink();
              return Text('${h}h',
                  style: const TextStyle(fontSize: 9));
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
    ));
  }
}

/// 4-bar histogram: <1min, 1-5min, 5-15min, >15min
class _SessionHistogram extends StatelessWidget {
  const _SessionHistogram({required this.buckets});
  final List<int> buckets;

  static const _labels = ['<1min', '1-5m', '5-15m', '>15m'];

  @override
  Widget build(BuildContext context) {
    final maxVal = buckets.fold(0, (a, b) => a > b ? a : b).toDouble();
    return BarChart(BarChartData(
      maxY: maxVal > 0 ? maxVal * 1.2 : 1,
      barGroups: List.generate(4, (i) {
        final isAlert = i == 0; // < 1 min = "micro-usage" alert
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: buckets[i].toDouble(),
            color: isAlert ? AppColors.error : AppColors.primary,
            width: 36,
            borderRadius: BorderRadius.circular(4),
          ),
        ]);
      }),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 18,
            getTitlesWidget: (v, _) => Text(
              _labels[v.toInt()],
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
    ));
  }
}

/// Text-only infographic for opportunity cost.
class _OpportunityCostWidget extends StatelessWidget {
  const _OpportunityCostWidget({required this.totalMs});
  final int totalMs;

  @override
  Widget build(BuildContext context) {
    final hours = totalMs / 3_600_000;
    final pages = (hours * 30).round();
    final km = (hours * 5).round();
    final sleepCycles = (hours / 1.5).round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _CostItem(icon: Icons.menu_book_outlined, label: '$pages páginas'),
        _CostItem(icon: Icons.directions_walk_outlined, label: '${km}km'),
        _CostItem(icon: Icons.airline_seat_flat_outlined, label: '$sleepCycles ciclos'),
      ],
    );
  }
}

class _CostItem extends StatelessWidget {
  const _CostItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: AppColors.success),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

/// Horizontal bar chart for top apps by opens.
class _HorizontalAppBars extends StatelessWidget {
  const _HorizontalAppBars({required this.apps, required this.maxMs});
  final List<_AppAgg> apps;
  final int maxMs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: apps.map((a) {
        final pct = maxMs > 0 ? a.ms / maxMs : 0.0;
        final label = a.packageName.split('.').last;
        final isDanger = a.opens > 20 && a.ms < 5 * 60 * 1000 * a.opens;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                color: isDanger ? AppColors.error : AppColors.primary,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(width: 8),
            Text('${a.opens}×',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        );
      }).toList(),
    );
  }
}

/// Donut chart: active vs passive.
class _DonutChart extends StatelessWidget {
  const _DonutChart({required this.passiveMs, required this.activeMs});
  final int passiveMs;
  final int activeMs;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: PieChart(PieChartData(
          centerSpaceRadius: 36,
          sectionsSpace: 2,
          sections: [
            PieChartSectionData(
              value: passiveMs.toDouble(),
              color: AppColors.error,
              title: 'Passivo',
              radius: 48,
              titleStyle: const TextStyle(fontSize: 9, color: Colors.white),
            ),
            PieChartSectionData(
              value: activeMs.toDouble(),
              color: AppColors.success,
              title: 'Ativo',
              radius: 48,
              titleStyle: const TextStyle(fontSize: 9, color: Colors.white),
            ),
          ],
        )),
      ),
      const SizedBox(width: AppSpacing.md),
      Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Legend(color: AppColors.error, label: 'Passivo (${_fmtDuration(passiveMs)})'),
        const SizedBox(height: 8),
        _Legend(color: AppColors.success, label: 'Ativo (${_fmtDuration(activeMs)})'),
      ]),
    ]);
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

/// Overlaid bars: each day this week + a horizontal reference line for prev avg.
class _TrendBars extends StatelessWidget {
  const _TrendBars({required this.thisWeek, required this.prevAvgMs});
  final List<int> thisWeek;
  final int prevAvgMs;

  @override
  Widget build(BuildContext context) {
    final maxVal = [...thisWeek, prevAvgMs].fold(0, (a, b) => a > b ? a : b).toDouble();
    return BarChart(BarChartData(
      maxY: maxVal > 0 ? maxVal * 1.2 : 1,
      barGroups: thisWeek.asMap().entries.map((e) {
        final hours = e.value / 3_600_000;
        return BarChartGroupData(x: e.key, barRods: [
          BarChartRodData(
            toY: hours,
            color: e.value > prevAvgMs ? AppColors.error : AppColors.success,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ]);
      }).toList(),
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
          y: prevAvgMs / 3_600_000,
          color: AppColors.primary.withAlpha(180),
          strokeWidth: 1.5,
          dashArray: [4, 4],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => 'semana anterior',
            style: const TextStyle(fontSize: 9),
          ),
        ),
      ]),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
    ));
  }
}

/// 30-day line chart.
class _LineChart30d extends StatelessWidget {
  const _LineChart30d({required this.dailyMs});
  final List<int> dailyMs;

  @override
  Widget build(BuildContext context) {
    final maxVal = dailyMs.fold(0, (a, b) => a > b ? a : b).toDouble();
    final spots = dailyMs.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value / 3_600_000))
        .toList();
    return LineChart(LineChartData(
      maxY: maxVal > 0 ? maxVal / 3_600_000 * 1.2 : 1,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withAlpha(40),
          ),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
    ));
  }
}

/// Calendar heatmap: 5 weeks × 7 days grid, color by usage intensity.
class _HeatmapCalendar extends StatelessWidget {
  const _HeatmapCalendar({required this.summaries, required this.storage});
  final List<DaySummary> summaries;
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    final maxMs = summaries.fold<int>(1, (m, s) => s.totalMs > m ? s.totalMs : m);
    final goal = storage.dailyGoalMinutes * 60 * 1000;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
      ),
      itemCount: summaries.length.clamp(0, 30),
      itemBuilder: (_, i) {
        final s = summaries[i];
        final intensity = s.totalMs / maxMs;
        final overGoal = goal > 0 && s.totalMs > goal;
        final color = overGoal
            ? Color.lerp(AppColors.error.withAlpha(80), AppColors.error, intensity)!
            : Color.lerp(AppColors.primary.withAlpha(30), AppColors.primary, intensity)!;
        return Tooltip(
          message: '${s.date}: ${_fmtDuration(s.totalMs)}',
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      },
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _AppAgg {
  _AppAgg(this.packageName);
  final String packageName;
  int ms = 0;
  int opens = 0;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppColors.primary)),
        ]),
      ),
    );
  }
}
