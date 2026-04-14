import 'dart:math' as math;
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
            Tab(text: l10n.tab1d),
            Tab(text: l10n.tab7d),
            Tab(text: l10n.tab30d),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _Tab1d(storage: widget.storage, analytics: _analytics),
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

String _yesterdayStr() {
  final d = _dayAnchor(DateTime.now()).subtract(const Duration(days: 1));
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
  double? chartHeight = 140, // null = let chart size itself
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
          chartHeight != null
              ? SizedBox(height: chartHeight, child: chart)
              : chart,
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

// ─── TAB 1 dia ───────────────────────────────────────────────────────────────

class _Tab1d extends StatelessWidget {
  const _Tab1d({required this.storage, required this.analytics});
  final StorageService storage;
  final AnalyticsService analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = _todayStr();
    final yesterday = _yesterdayStr();
    final summaries = analytics.getSummaries(1);
    final summary = summaries.isEmpty ? null : summaries.first;
    final totalMs = summary?.totalMs ?? 0;
    final unlocks = summary?.unlockCount ?? 0;
    final yesterdayMs = storage.getDeviceYesterdayMs();
    final yesterdayUnlocks = storage.getUnlockYesterday();

    final hourlyMs = storage.getDeviceHourlyBreakdown(today);
    final hourlyUnlocks = storage.getHourlyUnlockBreakdown(today);
    final sessionBuckets = storage.getSessionBuckets();
    final hasHourly = hourlyMs.any((v) => v > 0);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(children: [
          Expanded(child: _StatCard(
            label: l10n.statTotalUsage,
            value: _fmtDuration(totalMs),
            subLabel: l10n.statYesterday,
            subValue: _fmtDuration(yesterdayMs),
          )),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCard(
            label: l10n.statUnlocks,
            value: '$unlocks',
            subLabel: l10n.statYesterday,
            subValue: '$yesterdayUnlocks',
          )),
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
          icon: Icons.view_timeline_outlined,
          title: l10n.blockYesterdayPatternTitle,
          chartHeight: null,
          chart: _YesterdayPatternChart(
            appHourly: storage.getAppHourlyBreakdown(yesterday),
            l10n: l10n,
          ),
          text: l10n.blockYesterdayPatternText,
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

        // Day-boundary note
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
    // Exclude launchers from dopamine drain — they're transitions, not triggers.
    final sorted = aggApps.values
        .where((a) => !_isLauncher(a.packageName))
        .toList()
      ..sort((a, b) => b.opens.compareTo(a.opens));
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

    // Data for 7-day hourly pattern chart (oldest first)
    final sevenDates = List.generate(7, (i) =>
        _dateStr(_dayAnchor(DateTime.now()).subtract(Duration(days: 6 - i))));
    final sevenDayHourly = [
      for (final d in sevenDates)
        (d.substring(5), storage.getAppHourlyBreakdown(d)), // label = MM-DD
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(children: [
          Expanded(child: _StatCard(label: l10n.statTotalTime, value: _fmtDuration(totalMs))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _StatCard(label: l10n.statUnlocks, value: '$totalUnlocks')),
        ]),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: AppSpacing.md),
          child: Text(l10n.statLast7Days,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontStyle: FontStyle.italic)),
        ),

        _analysisCard(
          context: context,
          icon: Icons.calendar_view_week_outlined,
          title: l10n.blockLastDaysPatternTitle,
          chartHeight: null,
          chart: _LastDaysPatternChart(daysData: sevenDayHourly, l10n: l10n),
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

        _analysisCard(
          context: context,
          icon: Icons.psychology_outlined,
          title: l10n.blockDopamineTitle,
          chartHeight: topFive.isEmpty ? 60 : (topFive.length * 44.0),
          chart: topFive.isEmpty
              ? _noData(context, l10n.noData)
              : _HorizontalAppBars(apps: topFive, maxOpens: topFive.first.opens),
          text: topFive.isEmpty
              ? l10n.blockDopamineNoData
              : l10n.blockDopamineText(
                  _labelForApp(topFive.first.packageName),
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
          title: l10n.blockWeekPatternTitle,
          chartHeight: _WeekdayHeatmap.kHeight,
          chart: _WeekdayHeatmap(storage: storage, l10n: l10n),
          text: l10n.blockWeekPatternText,
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
    // Day starts at 04:00 — position i maps to actual hour (i + 4) % 24.
    // Labels at positions 0, 6, 12, 18 → "4h", "10h", "16h", "22h".
    final maxVal = values.fold(0, (a, b) => a > b ? a : b).toDouble();
    return BarChart(BarChartData(
      maxY: maxVal > 0 ? maxVal * 1.2 : 1,
      barGroups: List.generate(24, (i) {
        final h = (i + 4) % 24;
        final isHighlight = highlightHours.contains(h);
        return BarChartGroupData(x: i, barRods: [
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
              final pos = v.toInt();
              if (pos % 2 != 0) return const SizedBox.shrink();
              final h = (pos + 4) % 24;
              return Text(h.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 8));
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
    ));
  }
}

// ─── Yesterday pattern chart ──────────────────────────────────────────────────

// Static brand colors keyed by package name.
// Source: official brand guidelines / seekcolors.com / brandcolorcode.com
// Color uniqueness: pairs with CIE76 ΔE < 15 were adjusted — see _debugCheckColorConflicts().
// Adjustment axis order when resolving conflicts: H first, then S, then L.
// Run the app in debug mode to verify — conflicts are printed to the console.
const _kAppColors = <String, Color>{
  'com.whatsapp':                            Color(0xFF25D366), // WhatsApp green
  'com.instagram.android':                   Color(0xFFE1306C), // Instagram pink
  'com.instagram.barcelona':                 Color(0xFFE1306C), // Threads (same brand)
  'com.tinder':                              Color(0xFFFF5F40), // Tinder coral-orange (shifted H: was #FD267A pink, too close to Instagram)
  'org.telegram.messenger':                  Color(0xFF2AABEE), // Telegram blue
  'com.spotify.music':                       Color(0xFF1DB954), // Spotify green
  'com.google.android.apps.maps':            Color(0xFF009688), // Maps teal (shifted H: was #34A853 green, too close to WhatsApp/Spotify)
  'com.android.chrome':                      Color(0xFF4285F4), // Chrome blue
  'com.google.android.youtube':              Color(0xFFFF0000), // YouTube red
  'com.supercell.clashroyale':               Color(0xFF2B59C3), // Clash Royale blue
  'com.supercell.clashofclans':              Color(0xFFFBBC04), // Clash of Clans gold
  'com.bumble.app':                          Color(0xFFFFC629), // Bumble yellow
  'com.openai.chatgpt':                      Color(0xFF10A37F), // ChatGPT teal
  'com.nu.production':                       Color(0xFF8A05BE), // Nubank purple
  'com.studiosol.cifraclub':                 Color(0xFFFF6600), // CifraClub orange
  'com.google.android.keep':                 Color(0xFFFF7043), // Keep deep-orange (was #FBBC04, exact dup of Clash of Clans)
  'com.lucasf.apptime':                      Color(0xFF6366F1), // AppTime indigo
  'com.google.android.gm':                   Color(0xFFD44638), // Gmail red-orange
  'com.facebook.katana':                     Color(0xFF1877F2), // Facebook blue
  'com.miui.home':                           Color(0xFF78909C), // Launcher grey-blue
  'com.google.android.apps.messaging':       Color(0xFF1A73E8), // Messages blue
  'br.com.brainweb.ifood':                   Color(0xFFEA1D2C), // iFood red
  'com.android.deskclock':                   Color(0xFF607D8B), // Clock blue-grey
  'com.google.android.googlequicksearchbox': Color(0xFFDB4437), // Google red (was #4285F4, exact dup of Chrome)
  'com.google.android.apps.bard':            Color(0xFFF48FB1), // Gemini pink (shifted H: was #8E77FA violet, too close to AppTime/Stremio)
  'com.google.android.apps.docs':            Color(0xFF1565C0), // Docs dark-blue (was #1A73E8, exact dup of Messages)
  'com.ovelin.guitartuna':                   Color(0xFFAA00FF), // GuitarTuna deep-purple (shifted H: was #E91E63 pink, too close to Instagram)
  'com.stremio.one':                         Color(0xFF26C6DA), // Stremio cyan (shifted H: was #7B4FFF purple, too close to Nubank/AppTime)
  'br.com.bradseg.segurobradescosaude':      Color(0xFFCC092F), // Bradesco red
};

// Human-readable labels for known packages.
const _kAppLabels = <String, String>{
  'com.whatsapp':                            'WhatsApp',
  'com.instagram.android':                   'Instagram',
  'com.instagram.barcelona':                 'Threads',
  'com.tinder':                              'Tinder',
  'org.telegram.messenger':                  'Telegram',
  'com.spotify.music':                       'Spotify',
  'com.google.android.apps.maps':            'Maps',
  'com.android.chrome':                      'Chrome',
  'com.google.android.youtube':              'YouTube',
  'com.supercell.clashroyale':               'Clash Royale',
  'com.supercell.clashofclans':              'Clash of Clans',
  'com.bumble.app':                          'Bumble',
  'com.openai.chatgpt':                      'ChatGPT',
  'com.nu.production':                       'Nubank',
  'com.studiosol.cifraclub':                 'CifraClub',
  'com.google.android.keep':                 'Keep',
  'com.lucasf.apptime':                      'AppTime',
  'com.google.android.gm':                   'Gmail',
  'com.facebook.katana':                     'Facebook',
  'com.miui.home':                           'Início',
  'com.google.android.apps.messaging':       'Messages',
  'br.com.brainweb.ifood':                   'iFood',
  'com.android.deskclock':                   'Relógio',
  'com.google.android.googlequicksearchbox': 'Google',
  'com.google.android.apps.bard':            'Gemini',
  'com.google.android.apps.docs':            'Docs',
  'com.ovelin.guitartuna':                   'GuitarTuna',
  'com.stremio.one':                         'Stremio',
  'br.com.bradseg.segurobradescosaude':      'Bradesco',
};

Color _colorForApp(String pkg) =>
    _kAppColors[pkg] ?? const Color(0xFFB0BEC5);

String _labelForApp(String pkg) =>
    _kAppLabels[pkg] ?? pkg.split('.').where((s) => s != 'android' && s != 'app' && s != 'mobile').last;

bool _isLauncher(String pkg) =>
    pkg == 'com.miui.home' ||
    pkg.contains('.launcher') ||
    pkg.endsWith('.home') ||
    pkg == 'com.android.systemui';

/// Top [n] apps by usage in a specific hour, launchers excluded.
List<String> _hourTopN(Map<String, List<int>> hourly, int h, {int n = 5}) =>
    (hourly.entries
        .where((e) => !_isLauncher(e.key) && e.value[h] > 0)
        .toList()
          ..sort((a, b) => b.value[h].compareTo(a.value[h])))
        .take(n)
        .map((e) => e.key)
        .toList();

// ── Color uniqueness helpers ─────────────────────────────────────────────────

/// CIE76 Delta E between two colors. 0 = identical, ~100 = maximum distance.
/// Pairs with ΔE < 15 are considered "too similar" for a stacked bar chart.
double _deltaE(Color a, Color b) {
  double lin(int c) {
    final f = c / 255.0;
    return f <= 0.04045 ? f / 12.92 : math.pow((f + 0.055) / 1.055, 2.4).toDouble();
  }

  List<double> toLab(Color c) {
    final r = lin((c.r * 255).round()), g = lin((c.g * 255).round()), bl = lin((c.b * 255).round());
    final x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * bl) / 0.95047;
    final y = (0.2126729 * r + 0.7151522 * g + 0.0721750 * bl) / 1.00000;
    final z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * bl) / 1.08883;
    double f(double t) =>
        t > 0.008856 ? math.pow(t, 1 / 3.0).toDouble() : 7.787 * t + 16 / 116;
    final fx = f(x), fy = f(y), fz = f(z);
    return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
  }

  final la = toLab(a), lb = toLab(b);
  return math.sqrt(
    math.pow(la[0] - lb[0], 2) +
    math.pow(la[1] - lb[1], 2) +
    math.pow(la[2] - lb[2], 2),
  );
}

/// In debug builds, prints any pairs in _kAppColors with ΔE < 15.
/// Call this whenever _kAppColors is modified.
void _debugCheckColorConflicts() {
  assert(() {
    const minDeltaE = 15.0;
    final entries = _kAppColors.entries.toList();
    var found = false;
    for (int i = 0; i < entries.length; i++) {
      for (int j = i + 1; j < entries.length; j++) {
        final de = _deltaE(entries[i].value, entries[j].value);
        if (de < minDeltaE) {
          debugPrint(
            'AppColors conflict: ${_kAppLabels[entries[i].key] ?? entries[i].key}'
            ' ↔ ${_kAppLabels[entries[j].key] ?? entries[j].key}'
            ' ΔE=${de.toStringAsFixed(1)} (< $minDeltaE)',
          );
          found = true;
        }
      }
    }
    if (!found) debugPrint('AppColors: all pairs ΔE ≥ $minDeltaE ✓');
    return true;
  }());
}

class _YesterdayPatternChart extends StatelessWidget {
  const _YesterdayPatternChart({
    required this.appHourly,
    required this.l10n,
  });

  final Map<String, List<int>> appHourly;
  final AppLocalizations l10n;

  static const double _rowHeight = 15.0; // 18 × 0.85 ≈ 15
  static const double _labelWidth = 30.0;
  static const double _barHeight = 9.0;  // 10 × 0.85 ≈ 9
  static const int _hourMs = 60 * 60 * 1000;
  static const int _topN = 5;

  @override
  Widget build(BuildContext context) {
    _debugCheckColorConflicts();

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

    // Thin separator between adjacent colored segments.
    final sep = Container(width: 1.5, color: const Color(0x99000000));

    // Legend: union of all apps appearing in any hour's per-hour top N.
    // Launchers are excluded from top-N and grouped into "outros".
    final legendApps = <String>{
      for (int hh = 0; hh < 24; hh++) ..._hourTopN(appHourly, hh, n: _topN),
    };

    // Build one row per hour, all 24, in 4am-first order
    final rows = <Widget>[];
    for (int i = 0; i < 24; i++) {
      final h = (i + 4) % 24;
      final total = appHourly.values.fold(0, (s, e) => s + e[h]);
      final topNForHour = _hourTopN(appHourly, h, n: _topN);
      final topNMs = topNForHour.fold<int>(0, (s, p) => s + (appHourly[p]?[h] ?? 0));
      final outrosMs = total - topNMs; // includes launcher time + non-top apps

      // Build segments with separators between each adjacent pair
      final segments = <Widget>[];
      for (final pkg in topNForHour) {
        final ms = appHourly[pkg]![h];
        if (ms > 0) {
          if (segments.isNotEmpty) segments.add(sep);
          segments.add(Flexible(
            flex: toFlex(ms),
            child: Container(color: _colorForApp(pkg)),
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
      // Unused fraction of the hour (no separator — transparent)
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

    // Legend: all apps that appeared in any hour's top N + always show "outros"
    final legendItems = [
      for (final pkg in legendApps)
        _LegendDot(color: _colorForApp(pkg), label: _labelForApp(pkg)),
      _LegendDot(color: const Color(0xFFB0BEC5), label: l10n.yesterdayPatternOther),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(spacing: 10, runSpacing: 4, children: legendItems),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 10)),
        ],
      );
}

// ─── Last 7 days hourly pattern chart ──────────────────────────────────────────

class _LastDaysPatternChart extends StatefulWidget {
  const _LastDaysPatternChart({required this.daysData, required this.l10n});
  final List<(String, Map<String, List<int>>)> daysData;
  final AppLocalizations l10n;

  @override
  State<_LastDaysPatternChart> createState() => _LastDaysPatternChartState();
}

class _LastDaysPatternChartState extends State<_LastDaysPatternChart> {
  bool _zoomedOut = false;

  static const double _barH   = 56.0;
  static const double _labelH = 14.0;
  static const int    _topN   = 5;
  static const int    _hourMs = 60 * 60 * 1000;

  List<String> _hourTopNForDay(Map<String, List<int>> hourly, int h) =>
      _hourTopN(hourly, h, n: _topN);

  Widget _hourColumn(Map<String, List<int>> hourly, int h, double colW) {
    final topN   = _hourTopNForDay(hourly, h);
    final total  = hourly.values.fold<int>(0, (s, e) => s + e[h]);
    final topNMs = topN.fold<int>(0, (s, p) => s + (hourly[p]?[h] ?? 0));
    final outros = total - topNMs;
    if (total == 0) return SizedBox(width: colW, height: _barH);
    return SizedBox(
      width: colW,
      height: _barH,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final pkg in topN.reversed)
            if ((hourly[pkg]?[h] ?? 0) > 0)
              SizedBox(
                height: ((hourly[pkg]![h] / _hourMs) * _barH).clamp(0.5, _barH),
                child: ColoredBox(color: _colorForApp(pkg)),
              ),
          if (outros > 0)
            SizedBox(
              height: ((outros / _hourMs) * _barH).clamp(0.5, _barH),
              child: const ColoredBox(color: Color(0xFFB0BEC5)),
            ),
        ],
      ),
    );
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

    final screenW = MediaQuery.of(context).size.width - 2 * AppSpacing.md - 32;
    final nDays   = widget.daysData.length;
    final colW    = _zoomedOut
        ? (screenW / (nDays * 24)).clamp(2.0, 10.0)
        : (screenW / (2.5 * 24)).clamp(4.0, 14.0);
    final totalW  = nDays * 24 * colW;

    final legendApps = <String>{
      for (final (_, hourly) in widget.daysData)
        for (int h = 0; h < 24; h++) ..._hourTopNForDay(hourly, h),
    };

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
                Icon(_zoomedOut ? Icons.zoom_in : Icons.zoom_out_map, size: 14,
                    color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text(_zoomedOut ? '2.5d' : '7d',
                    style: TextStyle(fontSize: 10,
                        color: Theme.of(context).colorScheme.outline)),
              ]),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: _barH,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int di = 0; di < widget.daysData.length; di++) ...[
                        for (int i = 0; i < 24; i++)
                          _hourColumn(widget.daysData[di].$2, (i + 4) % 24, colW),
                        if (di < widget.daysData.length - 1)
                          Container(width: 1, height: _barH,
                              color: const Color(0x55FFFFFF)),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  height: _labelH,
                  child: Row(
                    children: [
                      for (final (label, _) in widget.daysData)
                        SizedBox(
                          width: 24 * colW,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(label,
                                style: const TextStyle(
                                    fontSize: 8, color: Color(0xFF9E9E9E)),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (legendApps.isNotEmpty)
          Wrap(spacing: 8, runSpacing: 4, children: [
            for (final pkg in legendApps)
              _LegendDot(color: _colorForApp(pkg), label: _labelForApp(pkg)),
            _LegendDot(color: const Color(0xFFB0BEC5),
                label: widget.l10n.yesterdayPatternOther),
          ]),
      ],
    );
  }
}

// ─── Session histogram ────────────────────────────────────────────────────────

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
  const _HorizontalAppBars({required this.apps, required this.maxOpens});
  final List<_AppAgg> apps;
  final int maxOpens;

  // Research-based thresholds (opens per 7-day period).
  // Rosen et al. (2013): frequent checkers average 40-60 phone checks/day.
  // Greenfield (2020, Center for Internet & Technology Addiction):
  //   >20 opens/day of a single app = compulsive checking pattern.
  // Warning  ~5 opens/day x7 = 35  (noticeable habitual use)
  // Alert   ~10 opens/day x7 = 70  (compulsive threshold, Greenfield 2020)
  static const int _warnOpens = 35;
  static const int _alertOpens = 70;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: apps.map((a) {
        final fraction = maxOpens > 0 ? a.opens / maxOpens : 0.0;
        final warnF  = maxOpens > 0 ? _warnOpens  / maxOpens : 2.0;
        final alertF = maxOpens > 0 ? _alertOpens / maxOpens : 2.0;
        final barColor = a.opens >= _alertOpens
            ? AppColors.error
            : a.opens >= _warnOpens
                ? Colors.orange
                : AppColors.primary;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            SizedBox(
              width: 80,
              child: Text(_labelForApp(a.packageName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(builder: (ctx, constraints) {
                final maxW = constraints.maxWidth;
                return SizedBox(
                  height: 10,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: fraction.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      if (warnF <= 1.0)
                        Positioned(
                          left: (warnF * maxW - 0.75).clamp(0.0, maxW - 1.5),
                          top: -3, bottom: -3,
                          child: Container(width: 1.5,
                              color: Colors.orange.withOpacity(0.85)),
                        ),
                      if (alertF <= 1.0)
                        Positioned(
                          left: (alertF * maxW - 0.75).clamp(0.0, maxW - 1.5),
                          top: -3, bottom: -3,
                          child: Container(width: 1.5,
                              color: AppColors.error.withOpacity(0.85)),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            Text('${a.opens}x', style: Theme.of(context).textTheme.bodySmall),
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
              l10n.blockEngagementClassification,
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

  const _WeekdayHeatmap({required this.storage, required this.l10n});
  final StorageService storage;
  final AppLocalizations l10n;

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
                              // usedFraction = total device ms capped at 60 min
                              final usedFraction =
                                  (total / maxMs).clamp(0.0, 1.0);
                              if (usedFraction == 0) {
                                return Container(
                                    height: 10,
                                    color: Colors.transparent);
                              }
                              // Build app segments within usedFraction
                              final segments = <(Color, double)>[];
                              double appFrac = 0;
                              for (final pkg in topApps) {
                                final ms = weekdayApps[d][pkg]?[h] ?? 0;
                                if (ms <= 0) continue;
                                final frac =
                                    (ms / maxMs).clamp(0.0, usedFraction - appFrac);
                                segments.add((_pkgColor(pkg), frac));
                                appFrac += frac;
                              }
                              // "Other" fills remaining used time not attributed to top apps
                              final otherFrac = usedFraction - appFrac;
                              if (otherFrac > 0.005) {
                                segments.add((greyOther, otherFrac));
                              }
                              // Transparent remainder = unused minutes in that hour
                              final unusedFrac = 1.0 - usedFraction;
                              return SizedBox(
                                height: 10,
                                child: Row(
                                  children: [
                                    ...segments.map((seg) => Flexible(
                                          flex: (seg.$2 * 1000).round(),
                                          child: Container(color: seg.$1),
                                        )),
                                    if (unusedFrac > 0.005)
                                      Flexible(
                                        flex: (unusedFrac * 1000).round(),
                                        child: Container(
                                            color: Colors.transparent),
                                      ),
                                  ],
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
              Text(l10n.weekdayOtherLabel, style: const TextStyle(fontSize: 8)),
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
  const _StatCard({
    required this.label,
    required this.value,
    this.subLabel,
    this.subValue,
  });
  final String label;
  final String value;
  final String? subLabel;
  final String? subValue;

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
          if (subLabel != null && subValue != null) ...[
            const SizedBox(height: 2),
            Row(children: [
              Text('$subLabel: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline)),
              Text(subValue!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline)),
            ]),
          ],
        ]),
      ),
    );
  }
}
