import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysisTitle),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.tab24h),
            Tab(text: l10n.tab7d),
            Tab(text: l10n.tab30d),
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

/// Day starts at 04:00 — mirrors the 4 AM boundary in MonitoringService.kt.
DateTime _dayAnchor(DateTime dt) =>
    dt.hour < 4 ? dt.subtract(const Duration(days: 1)) : dt;

String _todayStr() {
  final d = _dayAnchor(DateTime.now());
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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

Widget _noData(BuildContext context, String msg) => Center(
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
    final l10n = AppLocalizations.of(context);
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
        Row(children: [
          Expanded(child: _StatCard(label: l10n.statTotalUsage, value: _fmtDuration(totalMs))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCard(label: l10n.statUnlocks, value: '$unlocks')),
        ]),
        const SizedBox(height: AppSpacing.md),

        _analysisCard(
          context: context,
          icon: Icons.bedtime_outlined,
          title: l10n.blockSleepTitle,
          chartHeight: 150,
          chart: hasHourly
              ? _HourlyBarChart(values: hourlyMs, highlightHours: {22, 23, 0, 1, 2, 3, 4, 5})
              : _noData(context, l10n.collectingData),
          text: _sleepText(l10n, hourlyMs, totalMs),
        ),

        _analysisCard(
          context: context,
          icon: Icons.bolt_outlined,
          title: l10n.blockImpulsivityTitle,
          chart: hasHourly
              ? _HourlyBarChart(values: hourlyUnlocks, color: AppColors.error)
              : _noData(context, l10n.collectingData),
          text: l10n.blockImpulsivityText(unlocks),
        ),

        _analysisCard(
          context: context,
          icon: Icons.grid_view_outlined,
          title: l10n.blockFocusTitle,
          chart: sessionBuckets.any((v) => v > 0)
              ? _SessionHistogram(buckets: sessionBuckets)
              : _noData(context, l10n.collectingData),
          text: _focusText(l10n, sessionBuckets),
        ),

        _analysisCard(
          context: context,
          icon: Icons.hourglass_empty_outlined,
          title: l10n.blockOpportunityTitle,
          chartHeight: 80,
          chart: _OpportunityCostWidget(totalMs: totalMs, l10n: l10n),
          text: l10n.blockOpportunityText,
        ),

        _analysisCard(
          context: context,
          icon: Icons.group_outlined,
          title: l10n.blockPhubbingTitle,
          chart: hasHourly
              ? _HourlyBarChart(
                  values: hourlyUnlocks,
                  highlightHours: {12, 13, 14, 19, 20, 21},
                  color: AppColors.primary,
                )
              : _noData(context, l10n.collectingData),
          text: _phubbingText(l10n, hourlyUnlocks),
        ),
      ],
    );
  }

  String _sleepText(AppLocalizations l10n, List<int> hourly, int totalMs) {
    final lateMs = [22, 23, 0, 1, 2, 3, 4, 5]
        .fold<int>(0, (sum, h) => sum + hourly[h]);
    final pct = totalMs > 0 ? (lateMs / totalMs * 100).round() : 0;
    return l10n.blockSleepText(pct);
  }

  String _focusText(AppLocalizations l10n, List<int> buckets) {
    final total = buckets.fold(0, (a, b) => a + b);
    if (total == 0) return l10n.noSessions;
    final pct = (buckets[0] / total * 100).round();
    return l10n.blockFocusText(pct);
  }

  String _phubbingText(AppLocalizations l10n, List<int> hourlyUnlocks) {
    final mealUnlocks = [12, 13, 14, 19, 20, 21]
        .fold<int>(0, (sum, h) => sum + hourlyUnlocks[h]);
    return l10n.blockPhubbingText(mealUnlocks);
  }
}

// ─── TAB 7 dias ───────────────────────────────────────────────────────────────

class _Tab7d extends StatelessWidget {
  const _Tab7d({required this.storage, required this.analytics});
  final StorageService storage;
  final AnalyticsService analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

    final dailyBars = summaries.reversed.toList();

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
          Expanded(child: _StatCard(label: l10n.statTotalTime, value: _fmtDuration(totalMs))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCard(label: l10n.statUnlocks, value: '$totalUnlocks')),
        ]),
        const SizedBox(height: AppSpacing.md),

        if (dailyBars.isNotEmpty) ...[
          Text(l10n.dailyUsageLabel, style: Theme.of(context).textTheme.titleSmall),
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

        _analysisCard(
          context: context,
          icon: Icons.psychology_outlined,
          title: l10n.blockDopamineTitle,
          chartHeight: topFive.isEmpty ? 60 : (topFive.length * 44.0),
          chart: topFive.isEmpty
              ? _noData(context, l10n.noData)
              : _HorizontalAppBars(apps: topFive, maxMs: topFive.first.ms),
          text: topFive.isEmpty
              ? l10n.blockDopamineNoData
              : l10n.blockDopamineText(
                  topFive.first.packageName.split('.').last,
                  topFive.first.opens,
                ),
        ),

        _analysisCard(
          context: context,
          icon: Icons.balance_outlined,
          title: l10n.blockEngagementTitle,
          chartHeight: 160,
          chart: (passiveMs + activeMs) > 0
              ? _DonutChart(passiveMs: passiveMs, activeMs: activeMs, l10n: l10n)
              : _noData(context, l10n.noData),
          text: _engagementText(l10n, passiveMs, totalMs),
        ),

        _analysisCard(
          context: context,
          icon: Icons.trending_down_outlined,
          title: l10n.blockTrendTitle,
          chart: _TrendBars(
            thisWeek: dailyBars.map((s) => s.totalMs).toList(),
            prevAvgMs: prevAvgMs,
            prevWeekLabel: l10n.prevWeekLabel,
          ),
          text: trendPct <= 0
              ? l10n.blockTrendReduced(trendPct.abs())
              : l10n.blockTrendIncreased(trendPct),
        ),
      ],
    );
  }

  String _engagementText(AppLocalizations l10n, int passiveMs, int totalMs) {
    if (totalMs == 0) return l10n.blockEngagementNoData;
    final pct = (passiveMs / totalMs * 100).round();
    return l10n.blockEngagementText(pct);
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
    final l10n = AppLocalizations.of(context);
    final summaries = analytics.getSummaries(30);
    final totalMs = summaries.fold<int>(0, (acc, s) => acc + s.totalMs);
    final totalUnlocks = summaries.fold<int>(0, (acc, s) => acc + s.unlockCount);

    final dailyMs = summaries.reversed.map((s) => s.totalMs).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(children: [
          Expanded(child: _StatCard(label: l10n.statTotalTime, value: _fmtDuration(totalMs))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCard(label: l10n.statUnlocks, value: '$totalUnlocks')),
        ]),
        const SizedBox(height: AppSpacing.md),

        _analysisCard(
          context: context,
          icon: Icons.show_chart_outlined,
          title: l10n.blockTrend30Title,
          chartHeight: 160,
          chart: dailyMs.isNotEmpty
              ? _LineChart30d(dailyMs: dailyMs)
              : _noData(context, l10n.noData),
          text: l10n.blockTrend30Text,
        ),

        _analysisCard(
          context: context,
          icon: Icons.grid_4x4_outlined,
          title: l10n.blockWeekendTitle,
          chartHeight: _WeekdayHeatmap.kHeight,
          chart: _WeekdayHeatmap(storage: storage),
          text: 'Average usage per hour for each day of the week (last 4 weeks).',
        ),
      ],
    );
  }
}

// ─── Chart widgets ────────────────────────────────────────────────────────────

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
              return Text('${h}h', style: const TextStyle(fontSize: 9));
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
    ));
  }
}

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
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: buckets[i].toDouble(),
            color: i == 0 ? AppColors.error : AppColors.primary,
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

class _OpportunityCostWidget extends StatelessWidget {
  const _OpportunityCostWidget({required this.totalMs, required this.l10n});
  final int totalMs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hours = totalMs / 3_600_000;
    final pages = (hours * 30).round();
    final km = (hours * 5).round();
    final sleepCycles = (hours / 1.5).round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _CostItem(icon: Icons.menu_book_outlined, label: l10n.pagesLabel(pages)),
        _CostItem(icon: Icons.directions_walk_outlined, label: l10n.kmLabel(km)),
        _CostItem(icon: Icons.airline_seat_flat_outlined, label: l10n.sleepCyclesLabel(sleepCycles)),
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
            Text('${a.opens}×', style: Theme.of(context).textTheme.bodySmall),
          ]),
        );
      }).toList(),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.passiveMs,
    required this.activeMs,
    required this.l10n,
  });
  final int passiveMs;
  final int activeMs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 110,
        child: PieChart(PieChartData(
          centerSpaceRadius: 28,
          sectionsSpace: 2,
          sections: [
            PieChartSectionData(
              value: passiveMs.toDouble(),
              color: AppColors.error,
              title: '',
              radius: 38,
            ),
            PieChartSectionData(
              value: activeMs.toDouble(),
              color: AppColors.success,
              title: '',
              radius: 38,
            ),
          ],
        )),
      ),
      const SizedBox(width: AppSpacing.lg),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Legend(color: AppColors.error, label: '${l10n.passive} (${_fmtDuration(passiveMs)})'),
            const SizedBox(height: 10),
            _Legend(color: AppColors.success, label: '${l10n.active} (${_fmtDuration(activeMs)})'),
            const SizedBox(height: 12),
            Text(
              'Passive: social, video, news apps.\nActive: all others.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
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
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _TrendBars extends StatelessWidget {
  const _TrendBars({
    required this.thisWeek,
    required this.prevAvgMs,
    required this.prevWeekLabel,
  });
  final List<int> thisWeek;
  final int prevAvgMs;
  final String prevWeekLabel;

  @override
  Widget build(BuildContext context) {
    final maxVal =
        [...thisWeek, prevAvgMs].fold(0, (a, b) => a > b ? a : b).toDouble();
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
            labelResolver: (_) => prevWeekLabel,
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

// ─── Weekday × Hour heatmap ───────────────────────────────────────────────────
// 7 columns (Mon–Sun) × 24 rows (0 h–23 h).
// Each cell is a horizontal stacked bar: top-5 apps + grey "other".
// Data = average over the last 4 occurrences of each weekday.

class _WeekdayHeatmap extends StatelessWidget {
  static const kHeight = 380.0;

  const _WeekdayHeatmap({required this.storage});
  final StorageService storage;

  static Color _pkgColor(String pkg) {
    final hue = (pkg.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.65, 0.48).toColor();
  }

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const maxMs = 3_600_000; // 60 min per hour ceiling

    // Precompute per-weekday data (weekday 1=Mon … 7=Sun)
    final weekdayDevice = <List<int>>[];   // [7][24]
    final weekdayApps = <Map<String, List<int>>>[];  // [7] pkg→[24]
    for (int i = 0; i < 7; i++) {
      final dates = storage.lastNDatesForWeekday(i + 1, 4);
      weekdayDevice.add(storage.avgDeviceHourlyMs(dates));
      weekdayApps.add(storage.avgAppHourlyMs(dates));
    }

    // Top-5 apps by total ms across all days/hours
    final totals = <String, int>{};
    for (final dayMap in weekdayApps) {
      for (final e in dayMap.entries) {
        totals[e.key] = (totals[e.key] ?? 0) + e.value.fold(0, (s, v) => s + v);
      }
    }
    final topApps = (totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .map((e) => e.key)
        .toList();

    final greyOther = Colors.grey.withAlpha(100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Column headers ──────────────────────────────────────────────
        Row(children: [
          const SizedBox(width: 22),
          ...List.generate(7, (i) => Expanded(
                child: Center(
                  child: Text(dayLabels[i],
                      style: const TextStyle(
                          fontSize: 8, fontWeight: FontWeight.w700)),
                ),
              )),
        ]),
        const SizedBox(height: 2),
        // ── Grid ────────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(24, (h) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text('${h}h',
                            style: const TextStyle(
                                fontSize: 7,
                                color: Colors.grey)),
                      ),
                      ...List.generate(7, (d) {
                        final total = weekdayDevice[d][h];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: LayoutBuilder(builder: (_, box) {
                              if (total == 0) {
                                return Container(
                                    height: 10,
                                    color: Colors.transparent);
                              }
                              // Build proportional segments (capped at maxMs)
                              final segments = <(Color, double)>[];
                              double usedFrac = 0;
                              for (final pkg in topApps) {
                                final ms = weekdayApps[d][pkg]?[h] ?? 0;
                                if (ms <= 0) continue;
                                final frac =
                                    (ms / maxMs).clamp(0.0, 1.0 - usedFrac);
                                segments.add((_pkgColor(pkg), frac));
                                usedFrac += frac;
                              }
                              final rest = (total / maxMs).clamp(0.0, 1.0) -
                                  usedFrac;
                              if (rest > 0.005) {
                                segments.add((greyOther, rest));
                              }
                              return SizedBox(
                                height: 10,
                                child: Row(
                                  children: segments.map((seg) {
                                    return Flexible(
                                      flex: (seg.$2 * 1000).round(),
                                      child: Container(color: seg.$1),
                                    );
                                  }).toList(),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        // ── Caption ─────────────────────────────────────────────────────
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          children: [
            ...topApps.map((pkg) => Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 8, height: 8, color: _pkgColor(pkg)),
                  const SizedBox(width: 3),
                  Text(pkg.split('.').last,
                      style: const TextStyle(fontSize: 8)),
                ])),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, color: greyOther),
              const SizedBox(width: 3),
              const Text('other', style: TextStyle(fontSize: 8)),
            ]),
          ],
        ),
      ],
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
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
