import 'dart:async';
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

// ─── TAB 7 dias ───────────────────────────────────────────────────────────────

class Tab7d extends StatefulWidget {
  const Tab7d({super.key, required this.storage, required this.analytics});
  final StorageService storage;
  final AnalyticsService analytics;

  @override
  State<Tab7d> createState() => _Tab7dState();
}

class _Tab7dState extends State<Tab7d> {
  StorageService get storage => widget.storage;
  AnalyticsService get analytics => widget.analytics;

  late List<DaySummary> _summaries;
  Timer? _refreshTimer;
  String? _classificationMsg;

  void _refresh() {
    setState(() {
      _summaries = widget.analytics.getSummaries(7);
      _classificationMsg = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _summaries = widget.analytics.getSummaries(7);
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => _refresh());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _classificationMsg = null;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaries = _summaries;
    final totalMs = summaries.fold<int>(0, (acc, s) => acc + s.totalMs);
    final totalUnlocks = summaries.fold<int>(0, (acc, s) => acc + s.unlockCount);

    final aggApps = <String, AppAgg>{};
    for (final s in summaries) {
      for (final a in s.apps) {
        final agg = aggApps.putIfAbsent(a.packageName, () => AppAgg(a.packageName));
        agg.ms += a.dailyMs;
        agg.opens += a.openCount;
      }
    }
    final sorted = aggApps.values
        .where((a) => isUserFacingApp(a.packageName))
        .toList()
      ..sort((a, b) => b.opens.compareTo(a.opens));
    final topFive = sorted.take(5).toList();

    final passiveMs = aggApps.values
        .where((a) => isPassiveApp(a.packageName))
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

    final sevenDates = List.generate(7, (i) =>
        fmtDate(dayAnchor(DateTime.now()).subtract(Duration(days: 6 - i))));
    final sevenDayHourly = [
      for (final d in sevenDates)
        (d, storage.getAppHourlyBreakdown(d)),
    ];

    final avgMinDay7d = summaries.isEmpty ? 0 : totalMs ~/ (summaries.length * 60000);
    final avgUnlocksDay7d = summaries.isEmpty ? 0 : totalUnlocks ~/ summaries.length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        analysisCard(
          context: context,
          icon: Icons.analytics_outlined,
          title: l10n.block30dSummaryTitle,
          chartHeight: null,
          chart: Summary30dWidget(
            avgMinDay: avgMinDay7d,
            avgUnlocksDay: avgUnlocksDay7d,
            totalMs: totalMs,
            totalUnlocks: totalUnlocks,
            nDays: summaries.length.clamp(1, 7),
            l10n: l10n,
          ),
          text: _classificationMsg ??= classificationMessage(l10n, avgMinDay7d, avgUnlocksDay7d),
        ),

        analysisCard(
          context: context,
          icon: Icons.calendar_view_week_outlined,
          title: l10n.blockLastDaysPatternTitle,
          chartHeight: null,
          chart: _LastDaysPatternChart(
            daysData: sevenDayHourly,
            l10n: l10n,
            disabledApps: storage.disabledApps,
          ),
          text: l10n.blockLastDaysPatternText,
        ),

        if (dailyBars.isNotEmpty) ...[
          Text(l10n.dailyUsageLabel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 130,
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
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) {
                      if (v == 0 || v % 1 != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text('${v.toInt()}h',
                            style: const TextStyle(fontSize: 9),
                            textAlign: TextAlign.right),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0x22FFFFFF),
                  strokeWidth: 0.5,
                ),
              ),
            )),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        analysisCard(
          context: context,
          icon: Icons.psychology_outlined,
          title: l10n.blockDopamineTitle,
          chartHeight: topFive.isEmpty ? 60 : (topFive.length * 44.0),
          chart: topFive.isEmpty
              ? analyticsNoData(context, l10n.noData)
              : HorizontalAppBars(apps: topFive, maxOpens: topFive.first.opens),
          text: topFive.isEmpty
              ? l10n.blockDopamineNoData
              : l10n.blockDopamineText(
                  labelForApp(topFive.first.packageName),
                  topFive.first.opens,
                ),
        ),

        analysisCard(
          context: context,
          icon: Icons.balance_outlined,
          title: l10n.blockEngagementTitle,
          chartHeight: 160,
          chart: (passiveMs + activeMs) > 0
              ? DonutChart(passiveMs: passiveMs, activeMs: activeMs, l10n: l10n)
              : analyticsNoData(context, l10n.noData),
          text: _engagementText(l10n, passiveMs, totalMs),
        ),

        analysisCard(
          context: context,
          icon: Icons.trending_down_outlined,
          title: l10n.blockTrendTitle,
          chartHeight: 175,
          chart: _TrendBars(
            thisWeek: dailyBars.map((s) => s.totalMs).toList(),
            dates: sevenDates,
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
      final date = fmtDate(today.subtract(Duration(days: i + 7)));
      return storage.getDeviceDailyMs(date: date);
    });
  }
}

// ─── Chart widgets (week tab) ─────────────────────────────────────────────────

class _LastDaysPatternChart extends StatefulWidget {
  const _LastDaysPatternChart({
    required this.daysData,
    required this.l10n,
    this.disabledApps = const {},
  });
  final List<(String, Map<String, List<int>>)> daysData;
  final AppLocalizations l10n;
  final Set<String> disabledApps;

  @override
  State<_LastDaysPatternChart> createState() => _LastDaysPatternChartState();
}

class _LastDaysPatternChartState extends State<_LastDaysPatternChart> {
  bool _zoomedOut = false;
  late final ScrollController _scroll;

  static const double _rowH    = 15.0;
  static const double _barH    =  9.0;
  static const double _labelW  = 44.0;
  static const int    _topN    =  4;
  static const int    _hourMs  = 60 * 60 * 1000;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<String> _dayTopN(Map<String, List<int>> hourly) {
    final totals = <String, int>{
      for (final e in hourly.entries)
        if (isUserFacingApp(e.key) &&
            !widget.disabledApps.contains(e.key))
          e.key: e.value.fold(0, (s, v) => s + v),
    };
    return (totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(_topN)
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = widget.daysData.any((d) => d.$2.isNotEmpty);
    if (!hasData) {
      return Center(
        child: Text(widget.l10n.collectingData,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline)),
      );
    }

    final nDays   = widget.daysData.length;
    final screenW = MediaQuery.of(context).size.width - 2 * AppSpacing.md - 32;
    final dayW = _zoomedOut
        ? ((screenW - _labelW) / nDays).clamp(40.0, 120.0)
        : ((screenW - _labelW) / 2.5).clamp(60.0, 140.0);
    final totalW = nDays * dayW + (nDays - 1);

    final sep = Container(width: 1.5, color: const Color(0x99000000));

    final dayTopApps = [
      for (final (_, hourly) in widget.daysData) _dayTopN(hourly),
    ];

    final legendApps = <String>{
      for (final list in dayTopApps) ...list,
    }.toList();

    int toFlex(int ms) => (ms ~/ 1000).clamp(1, 3600);

    final rows = <Widget>[];
    for (int i = 0; i < 24; i++) {
      final h = (i + 4) % 24;

      final dayCells = <Widget>[];
      for (int di = 0; di < nDays; di++) {
        final hourly = widget.daysData[di].$2;
        final topApps = dayTopApps[di];
        final total   = hourly.values.fold(0, (s, e) => s + e[h]);
        final topNMs  = topApps.fold<int>(0, (s, p) => s + (hourly[p]?[h] ?? 0));
        final outrosMs = total - topNMs;

        if (di > 0) {
          dayCells.add(Container(width: 1, color: const Color(0x44FFFFFF)));
        }

        if (total == 0) {
          dayCells.add(SizedBox(width: dayW));
          continue;
        }

        final segments = <Widget>[];
        for (final pkg in topApps) {
          final ms = hourly[pkg]?[h] ?? 0;
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

        dayCells.add(SizedBox(
          width: dayW,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: _barH,
              child: Row(children: segments),
            ),
          ),
        ));
      }

      rows.add(SizedBox(
        height: _rowH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: dayCells,
        ),
      ));
    }

    final hourLabels = <Widget>[
      for (int i = 0; i < 24; i++)
        SizedBox(
          height: _rowH,
          width: _labelW,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${(i + 4) % 24}h',
                style: const TextStyle(fontSize: 9, color: Color(0xFF757575))),
          ),
        ),
    ];

    final dayLabels = [
      for (final (dateStr, _) in widget.daysData)
        SizedBox(
          width: dayW,
          child: Text(
            sevenDayLabel(dateStr, languageCode: widget.l10n.locale.languageCode),
            style: const TextStyle(fontSize: 8, color: Color(0xFF9E9E9E)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() => _zoomedOut = !_zoomedOut),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_zoomedOut ? Icons.zoom_in : Icons.zoom_out_map, size: 20,
                    color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text(_zoomedOut ? '2.5d' : '7d',
                    style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.outline)),
              ]),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: hourLabels),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...rows,
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          for (int di = 0; di < nDays; di++) ...[
                            if (di > 0) const SizedBox(width: 1),
                            SizedBox(
                              width: dayW,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: ['0', '30m', '1h']
                                    .map((t) => Text(t,
                                        style: const TextStyle(
                                            fontSize: 7,
                                            color: Color(0xFF9E9E9E))))
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(children: dayLabels),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 4, children: [
          for (final pkg in legendApps)
            LegendDot(color: colorForApp(pkg), label: labelForApp(pkg)),
          LegendDot(
              color: const Color(0xFFB0BEC5),
              label: widget.l10n.yesterdayPatternOther),
        ]),
      ],
    );
  }
}

class _TrendBars extends StatelessWidget {
  const _TrendBars({
    required this.thisWeek,
    required this.dates,
    required this.prevAvgMs,
    required this.prevWeekLabel,
  });
  final List<int> thisWeek;
  final List<String> dates;
  final int prevAvgMs;
  final String prevWeekLabel;

  @override
  Widget build(BuildContext context) {
    final maxValH =
        [...thisWeek, prevAvgMs].fold(0, (a, b) => a > b ? a : b) / 3_600_000;
    final interval = maxValH <= 0 ? 1.0
        : maxValH <= 2 ? 0.5
        : maxValH <= 6 ? 1.0
        : 2.0;

    return BarChart(BarChartData(
      maxY: maxValH > 0 ? maxValH * 1.2 : 1,
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
            alignment: Alignment.topRight,
            labelResolver: (_) => prevWeekLabel,
            style: TextStyle(
                fontSize: 9,
                color: AppColors.primary.withAlpha(180)),
          ),
        ),
      ]),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: interval,
            getTitlesWidget: (v, _) {
              if (v == 0) return const SizedBox.shrink();
              final label = v == v.truncateToDouble()
                  ? '${v.toInt()}h'
                  : '${(v * 60).round()}m';
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(label,
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.right),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= dates.length) return const SizedBox.shrink();
              final full = sevenDayLabel(dates[i], languageCode: Localizations.localeOf(context).languageCode);
              final parts = full.split(' ');
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(parts[0],
                        style: const TextStyle(fontSize: 8)),
                    if (parts.length > 1)
                      Text(parts[1],
                          style: const TextStyle(fontSize: 7,
                              color: Color(0xFF9E9E9E))),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: Color(0x22FFFFFF),
          strokeWidth: 0.5,
        ),
      ),
    ));
  }
}
