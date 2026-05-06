import 'dart:async';
import 'dart:math' as math;
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

// ─── TAB 30 dias ─────────────────────────────────────────────────────────────

class Tab30d extends StatefulWidget {
  const Tab30d({super.key, required this.storage, required this.analytics});
  final StorageService storage;
  final AnalyticsService analytics;

  @override
  State<Tab30d> createState() => _Tab30dState();
}

class _Tab30dState extends State<Tab30d> {
  late List<DaySummary> _summaries;
  Timer? _refreshTimer;
  String? _classificationMsg;

  void _refresh() {
    setState(() {
      _summaries = widget.analytics.getSummaries(30);
      _classificationMsg = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _summaries = widget.analytics.getSummaries(30);
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
    final nDays = summaries.length.clamp(1, 30);
    final totalMs = summaries.fold<int>(0, (acc, s) => acc + s.totalMs);
    final totalUnlocks = summaries.fold<int>(0, (acc, s) => acc + s.unlockCount);
    final avgMinDay = totalMs ~/ (nDays * 60000);
    final avgUnlocksDay = totalUnlocks ~/ nDays;

    final aggApps = <String, AppAgg>{};
    for (final s in summaries) {
      for (final a in s.apps) {
        if (!isUserFacingApp(a.packageName)) continue;
        final agg = aggApps.putIfAbsent(a.packageName, () => AppAgg(a.packageName));
        agg.ms += a.dailyMs;
        agg.opens += a.openCount;
      }
    }
    final passiveMs = aggApps.values
        .where((a) => isPassiveApp(a.packageName))
        .fold<int>(0, (s, a) => s + a.ms);
    final activeMs = totalMs - passiveMs;

    final sorted = (aggApps.values.toList()..sort((a, b) => b.ms.compareTo(a.ms)));
    final top3 = sorted.take(3).map((a) => a.packageName).toList();
    final dailyChron = summaries.reversed.toList();
    final appDailyMs = <String, List<int>>{
      for (final pkg in top3)
        pkg: dailyChron.map((s) {
          final match = s.apps.where((a) => a.packageName == pkg);
          return match.isEmpty ? 0 : match.first.dailyMs;
        }).toList(),
    };
    final dailyMs = dailyChron.map((s) => s.totalMs).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        analysisCard(
          context: context,
          icon: Icons.analytics_outlined,
          title: l10n.block30dSummaryTitle,
          chartHeight: null,
          chart: Summary30dWidget(
            avgMinDay: avgMinDay,
            avgUnlocksDay: avgUnlocksDay,
            totalMs: totalMs,
            totalUnlocks: totalUnlocks,
            nDays: nDays,
            l10n: l10n,
          ),
          text: _classificationMsg ??= classificationMessage(l10n, avgMinDay, avgUnlocksDay),
        ),

        analysisCard(
          context: context,
          icon: Icons.show_chart_outlined,
          title: l10n.block30dChartTitle,
          chartHeight: null,
          chart: dailyMs.isNotEmpty
              ? _UsageTrend30dWithLegend(
                  dailyMs: dailyMs,
                  appDailyMs: appDailyMs,
                  top3: top3,
                )
              : analyticsNoData(context, l10n.noData),
          text: l10n.block30dChartText,
        ),

        analysisCard(
          context: context,
          icon: Icons.balance_outlined,
          title: '${l10n.blockEngagementTitle} (30d)',
          chartHeight: 160,
          chart: (passiveMs + activeMs) > 0
              ? DonutChart(passiveMs: passiveMs, activeMs: activeMs, l10n: l10n)
              : analyticsNoData(context, l10n.noData),
          text: _engagementText30d(l10n, passiveMs, totalMs),
        ),
      ],
    );
  }

  String _engagementText30d(AppLocalizations l10n, int passiveMs, int totalMs) {
    if (totalMs == 0) return l10n.blockEngagementNoData;
    final pct = (passiveMs / totalMs * 100).round();
    return l10n.blockEngagementText(pct);
  }
}

// ─── Chart widgets (month tab) ────────────────────────────────────────────────

class _UsageTrend30d extends StatelessWidget {
  const _UsageTrend30d({
    required this.dailyMs,
    required this.appDailyMs,
    required this.top3,
  });
  final List<int> dailyMs;
  final Map<String, List<int>> appDailyMs;
  final List<String> top3;

  static const double _idealH = 2.0;
  static const double _criticalH = 4.0;

  List<FlSpot> _spots(List<int> ms) => ms.asMap().entries
      .map((e) => FlSpot(e.key.toDouble(), e.value / 3_600_000))
      .toList();

  List<FlSpot> _trendSpots(List<int> ms) {
    final ys = ms.map((v) => v / 3_600_000).toList();
    final n = ys.length;
    if (n < 2) return [];
    final xMean = (n - 1) / 2.0;
    final yMean = ys.fold(0.0, (s, v) => s + v) / n;
    double num = 0, den = 0;
    for (int i = 0; i < n; i++) {
      num += (i - xMean) * (ys[i] - yMean);
      den += (i - xMean) * (i - xMean);
    }
    final slope = den != 0 ? num / den : 0;
    final intercept = yMean - slope * xMean;
    return [
      FlSpot(0, (intercept).clamp(0.0, 24.0)),
      FlSpot((n - 1).toDouble(), (intercept + slope * (n - 1)).clamp(0.0, 24.0)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final n = dailyMs.length;
    final maxH = dailyMs.fold(0, (a, b) => a > b ? a : b) / 3_600_000;
    final maxY = math.max(maxH * 1.15, _criticalH + 0.5);
    final trendSpots = _trendSpots(dailyMs);
    final outline = Theme.of(context).colorScheme.outline;

    return LineChart(LineChartData(
      minX: 0,
      maxX: (n - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      clipData: const FlClipData.all(),
      lineBarsData: [
        for (final pkg in top3)
          LineChartBarData(
            spots: _spots(appDailyMs[pkg] ?? []),
            isCurved: true,
            curveSmoothness: 0.35,
            color: colorForApp(pkg),
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        LineChartBarData(
          spots: _spots(dailyMs),
          isCurved: true,
          curveSmoothness: 0.35,
          color: Colors.white,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        if (trendSpots.length == 2)
          LineChartBarData(
            spots: trendSpots,
            isCurved: false,
            color: outline.withValues(alpha: 0.7),
            barWidth: 1,
            dotData: const FlDotData(show: false),
            dashArray: [6, 4],
            belowBarData: BarAreaData(show: false),
          ),
      ],
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
          y: _idealH,
          color: const Color(0xFF43A047).withValues(alpha: 0.7),
          strokeWidth: 1,
          dashArray: [5, 4],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            labelResolver: (_) => l10n.trendIdealLabel,
            style: const TextStyle(fontSize: 8, color: Color(0xFF43A047)),
          ),
        ),
        HorizontalLine(
          y: _criticalH,
          color: const Color(0xFFE53935).withValues(alpha: 0.7),
          strokeWidth: 1,
          dashArray: [5, 4],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            labelResolver: (_) => l10n.trendCriticalLabel,
            style: const TextStyle(fontSize: 8, color: Color(0xFFE53935)),
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
            interval: 1,
            getTitlesWidget: (v, _) {
              if (v == 0 || v != v.roundToDouble()) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text('${v.toInt()}h',
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.right),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 18,
            interval: 7,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i % 7 != 0) return const SizedBox.shrink();
              final dt = dayAnchor(DateTime.now())
                  .subtract(Duration(days: (n - 1 - i)));
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${dt.day}/${dt.month}',
                    style: const TextStyle(fontSize: 8, color: Color(0xFF9E9E9E))),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: Color(0x18FFFFFF),
          strokeWidth: 0.5,
        ),
      ),
    ));
  }
}

class _UsageTrend30dWithLegend extends StatelessWidget {
  const _UsageTrend30dWithLegend({
    required this.dailyMs,
    required this.appDailyMs,
    required this.top3,
  });
  final List<int> dailyMs;
  final Map<String, List<int>> appDailyMs;
  final List<String> top3;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: _UsageTrend30d(
            dailyMs: dailyMs,
            appDailyMs: appDailyMs,
            top3: top3,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 4, children: [
          const LegendDot(color: Colors.white, label: 'Total'),
          for (final pkg in top3)
            LegendDot(color: colorForApp(pkg), label: labelForApp(pkg)),
        ]),
      ],
    );
  }
}
