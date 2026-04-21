import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_info.dart';
import '../../utils/date_utils.dart';
import 'analytics_helpers.dart';
import 'classification_message.dart';

// ─── TAB 1 dia ───────────────────────────────────────────────────────────────

class Tab1d extends StatelessWidget {
  const Tab1d({super.key, required this.storage, required this.analytics});
  final StorageService storage;
  final AnalyticsService analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = todayKey();
    final yesterday = yesterdayKey();
    final summaries = analytics.getSummaries(1);
    final summary = summaries.isEmpty ? null : summaries.first;
    final totalMs = summary?.totalMs ?? 0;
    final unlocks = summary?.unlockCount ?? 0;

    final hourlyMs = storage.getDeviceHourlyBreakdown(today);
    final hourlyUnlocks = storage.getHourlyUnlockBreakdown(today);
    final sessionBuckets = storage.getSessionBuckets();
    final hasHourly = hourlyMs.any((v) => v > 0);

    final avgMinDay1d = totalMs ~/ 60000;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        analysisCard(
          context: context,
          icon: Icons.analytics_outlined,
          title: l10n.block30dSummaryTitle,
          chartHeight: null,
          chart: Summary30dWidget(
            avgMinDay: avgMinDay1d,
            avgUnlocksDay: unlocks,
            totalMs: totalMs,
            totalUnlocks: unlocks,
            nDays: 1,
            l10n: l10n,
          ),
          text: classificationMessage(l10n, avgMinDay1d, unlocks),
        ),

        analysisCard(
          context: context,
          icon: Icons.bedtime_outlined,
          title: l10n.blockSleepTitle,
          chartHeight: 150,
          chart: hasHourly
              ? _HourlyBarChart(
                  values: hourlyMs,
                  highlightHours:  {21, 22, 23},
                  highlightColor:  const Color(0xFFE65100),
                  highlightHours2: {0, 1, 2, 3, 4, 5, 6, 7, 8},
                  highlightColor2: const Color(0xFF4527A0),
                )
              : analyticsNoData(context, l10n.collectingData),
          text: _sleepText(l10n, hourlyMs, totalMs),
        ),

        analysisCard(
          context: context,
          icon: Icons.view_timeline_outlined,
          title: l10n.blockYesterdayPatternTitle,
          chartHeight: null,
          chart: _YesterdayPatternChart(
            appHourly: storage.getAppHourlyBreakdown(yesterday),
            l10n: l10n,
            disabledApps: storage.disabledApps,
          ),
          text: l10n.blockYesterdayPatternText,
        ),

        analysisCard(
          context: context,
          icon: Icons.bolt_outlined,
          title: l10n.blockImpulsivityTitle,
          chart: hasHourly
              ? _HourlyBarChart(values: hourlyUnlocks, color: AppColors.error)
              : analyticsNoData(context, l10n.collectingData),
          text: l10n.blockImpulsivityText(unlocks),
        ),

        analysisCard(
          context: context,
          icon: Icons.grid_view_outlined,
          title: l10n.blockFocusTitle,
          chart: sessionBuckets.any((v) => v > 0)
              ? _SessionHistogram(buckets: sessionBuckets)
              : analyticsNoData(context, l10n.collectingData),
          text: _focusText(l10n, sessionBuckets),
        ),

        analysisCard(
          context: context,
          icon: Icons.hourglass_empty_outlined,
          title: l10n.blockOpportunityTitle,
          chartHeight: 80,
          chart: _OpportunityCostWidget(totalMs: totalMs, l10n: l10n),
          text: l10n.blockOpportunityText,
        ),

        analysisCard(
          context: context,
          icon: Icons.group_outlined,
          title: l10n.blockPhubbingTitle,
          chart: hasHourly
              ? _HourlyBarChart(
                  values: hourlyUnlocks,
                  highlightHours: {12, 13, 14, 19, 20, 21},
                  color: AppColors.primary,
                )
              : analyticsNoData(context, l10n.collectingData),
          text: _phubbingText(l10n, hourlyUnlocks),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  size: 12,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.dayBoundaryNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
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

// ─── Chart widgets (day tab) ──────────────────────────────────────────────────

class _HourlyBarChart extends StatelessWidget {
  const _HourlyBarChart({
    required this.values,
    this.highlightHours = const {},
    this.highlightColor,
    this.highlightHours2 = const {},
    this.highlightColor2,
    this.color,
  });
  final List<int> values;
  final Set<int> highlightHours;
  final Color? highlightColor;
  final Set<int> highlightHours2;
  final Color? highlightColor2;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Day starts at 04:00 — position i maps to actual hour (i + 4) % 24.
    // Labels at positions 0, 6, 12, 18 → "4h", "10h", "16h", "22h".
    final maxVal = values.fold(0, (a, b) => a > b ? a : b).toDouble();
    return BarChart(BarChartData(
      maxY: maxVal > 0 ? maxVal * 1.2 : 1,
      barGroups: List.generate(24, (i) {
        final h = (i + 4) % 24;
        final isHighlight  = highlightHours.contains(h);
        final isHighlight2 = highlightHours2.contains(h);
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: values[h].toDouble(),
            color: color ??
                (isHighlight  ? (highlightColor  ?? const Color(0xFFE65100))
                : isHighlight2 ? (highlightColor2 ?? const Color(0xFF4527A0))
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
              final i = v.toInt();
              if (i % 6 != 0) return const SizedBox.shrink();
              final h = (i + 4) % 24;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${h}h',
                    style: const TextStyle(fontSize: 8)));
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
    ));
  }
}

class _YesterdayPatternChart extends StatelessWidget {
  const _YesterdayPatternChart({
    required this.appHourly,
    required this.l10n,
    this.disabledApps = const {},
  });

  final Map<String, List<int>> appHourly;
  final AppLocalizations l10n;
  final Set<String> disabledApps;

  static const double _rowHeight = 15.0;
  static const double _labelWidth = 30.0;
  static const double _barHeight = 9.0;
  static const int _hourMs = 60 * 60 * 1000;
  static const int _topN = 7;

  @override
  Widget build(BuildContext context) {
    if (appHourly.isEmpty) {
      return Center(
        child: Text(l10n.collectingData,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline)),
      );
    }

    int toFlex(int ms) => (ms ~/ 1000).clamp(1, 3600);
    final sep = Container(width: 1.5, color: const Color(0x99000000));

    final dailyTotals = <String, int>{
      for (final e in appHourly.entries)
        if (isUserFacingApp(e.key) &&
            !disabledApps.contains(e.key))
          e.key: e.value.fold(0, (s, v) => s + v),
    };
    final topApps = (dailyTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(_topN)
        .map((e) => e.key)
        .toList();

    final legendApps = topApps;

    final rows = <Widget>[];
    for (int i = 0; i < 24; i++) {
      final h = (i + 4) % 24;
      final total = appHourly.values.fold(0, (s, e) => s + e[h]);
      final topNMs = topApps.fold<int>(0, (s, p) => s + (appHourly[p]?[h] ?? 0));
      final outrosMs = total - topNMs;

      final segments = <Widget>[];
      for (final pkg in topApps) {
        final ms = appHourly[pkg]![h];
        if (ms > 0) {
          if (segments.isNotEmpty) segments.add(sep);
          segments.add(Flexible(
            flex: toFlex(ms),
            child: Container(color: colorForApp(pkg)),
          ));
        }
      }
      if (outrosMs > 0) {
        if (segments.isNotEmpty) segments.add(sep);
        segments.add(Flexible(
          flex: toFlex(outrosMs),
          child: Container(color: const Color(0xFFB0BEC5)),
        ));
      }
      if (total < _hourMs) {
        segments.add(Flexible(
          flex: toFlex(_hourMs - total),
          child: const SizedBox.shrink(),
        ));
      }

      rows.add(SizedBox(
        height: _rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _labelWidth,
              child: Text('${h}h',
                  style: TextStyle(
                      fontSize: 9,
                      color: total > 0
                          ? const Color(0xFF757575)
                          : const Color(0xFFBDBDBD))),
            ),
            Expanded(
              child: total == 0
                  ? const SizedBox.shrink()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        height: _barHeight,
                        child: Row(children: segments),
                      ),
                    ),
            ),
          ],
        ),
      ));
    }

    final legendItems = [
      for (final pkg in legendApps)
        LegendDot(color: colorForApp(pkg), label: labelForApp(pkg)),
      LegendDot(color: const Color(0xFFB0BEC5), label: l10n.yesterdayPatternOther),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(spacing: 10, runSpacing: 4, children: legendItems),
        const SizedBox(height: 8),
        ...rows,
        const SizedBox(height: 2),
        Row(
          children: [
            const SizedBox(width: _labelWidth),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['0', '15m', '30m', '45m', '1h']
                    .map((t) => Text(t,
                        style: const TextStyle(
                            fontSize: 8, color: Color(0xFF757575))))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
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
