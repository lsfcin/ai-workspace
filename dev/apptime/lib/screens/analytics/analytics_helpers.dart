import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_info.dart';
import '../../utils/time_utils.dart';

// ─── Data classes ─────────────────────────────────────────────────────────────

class AppAgg {
  AppAgg(this.packageName);
  final String packageName;
  int ms = 0;
  int opens = 0;
}

// ─── Helper functions ─────────────────────────────────────────────────────────

Widget analysisCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required Widget chart,
  required String text,
  double? chartHeight = 140,
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

Widget analyticsNoData(BuildContext context, String msg) => Center(
      child: Text(msg,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.outline)),
    );

/// Returns a short label for a date string: weekday abbreviation + "DD/M".
/// E.g. "2026-04-14" (PT) → "ter 14/4"   (EN) → "Tue 14/4"
String sevenDayLabel(String dateStr, {String languageCode = 'pt'}) {
  const ptWeekdays = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  const enWeekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weekdays = languageCode == 'pt' ? ptWeekdays : enWeekdays;
  try {
    final parts = dateStr.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final wd = weekdays[dt.weekday - 1];
    return '$wd ${dt.day}/${dt.month}';
  } catch (_) {
    return dateStr.substring(5);
  }
}

// ─── Shared chart widgets ─────────────────────────────────────────────────────

class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});
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

class LegendItem extends StatelessWidget {
  const LegendItem({super.key, required this.color, required this.label});
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

class Summary30dWidget extends StatelessWidget {
  const Summary30dWidget({
    super.key,
    required this.avgMinDay,
    required this.avgUnlocksDay,
    required this.totalMs,
    required this.totalUnlocks,
    required this.nDays,
    required this.l10n,
  });
  final int avgMinDay, avgUnlocksDay, totalMs, totalUnlocks, nDays;
  final AppLocalizations l10n;

  static const _timeLabels = ['< 1h/dia', '1–2h/dia', '2–4h/dia', '4–6h/dia', '> 6h/dia'];
  static const _timeColors = [
    Color(0xFF43A047), Color(0xFF7CB342), Color(0xFFFB8C00),
    Color(0xFFE53935), Color(0xFFB71C1C),
  ];
  static const _unlockLabels = ['< 30/dia', '30–60/dia', '60–100/dia', '> 100/dia'];
  static const _unlockColors = [
    Color(0xFF43A047), Color(0xFFFB8C00), Color(0xFFE53935), Color(0xFFB71C1C),
  ];

  int get _tI => avgMinDay < 60 ? 0 : avgMinDay < 120 ? 1 : avgMinDay < 240 ? 2 : avgMinDay < 360 ? 3 : 4;
  int get _uI => avgUnlocksDay < 30 ? 0 : avgUnlocksDay < 60 ? 1 : avgUnlocksDay < 100 ? 2 : 3;

  @override
  Widget build(BuildContext context) {
    final tColor = _timeColors[_tI];
    final uColor = _unlockColors[_uI];
    final ts = Theme.of(context).textTheme;
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(fmtDuration(totalMs ~/ nDays),
            style: ts.titleMedium?.copyWith(color: tColor, fontWeight: FontWeight.w700)),
        Text('${l10n.statTotalUsage} /${l10n.locale.languageCode == 'pt' ? 'dia' : 'day'}', style: ts.bodySmall),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: tColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4)),
          child: Text(_timeLabels[_tI],
              style: ts.bodySmall?.copyWith(color: tColor, fontSize: 9)),
        ),
      ])),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${(totalUnlocks / nDays).round()}',
            style: ts.titleMedium?.copyWith(color: uColor, fontWeight: FontWeight.w700)),
        Text('${l10n.statUnlocks} /${l10n.locale.languageCode == 'pt' ? 'dia' : 'day'}', style: ts.bodySmall),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: uColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4)),
          child: Text(_unlockLabels[_uI],
              style: ts.bodySmall?.copyWith(color: uColor, fontSize: 9)),
        ),
      ])),
    ]);
  }
}

class HorizontalAppBars extends StatelessWidget {
  const HorizontalAppBars({super.key, required this.apps, required this.maxOpens});
  final List<AppAgg> apps;
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
              child: Text(labelForApp(a.packageName),
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
                              color: Colors.orange.withValues(alpha: 0.85)),
                        ),
                      if (alertF <= 1.0)
                        Positioned(
                          left: (alertF * maxW - 0.75).clamp(0.0, maxW - 1.5),
                          top: -3, bottom: -3,
                          child: Container(width: 1.5,
                              color: AppColors.error.withValues(alpha: 0.85)),
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
      }).toList()
        ..add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(width: 12, height: 2,
                      color: Colors.orange.withValues(alpha: 0.85)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    '35×/semana — uso habitual · Rosen et al. (2013), "iDisorder", Computers in Human Behavior',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic),
                  )),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Container(width: 12, height: 2,
                      color: AppColors.error.withValues(alpha: 0.85)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    '70×/semana — padrão compulsivo · Greenfield (2020), Center for Internet & Technology Addiction, "Compulsive Technology Use"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: AppColors.error,
                        fontStyle: FontStyle.italic),
                  )),
                ]),
              ],
            ),
          ),
        ),
    );
  }
}

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
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
            LegendItem(color: AppColors.error, label: '${l10n.passive} (${fmtDuration(passiveMs)})'),
            const SizedBox(height: 10),
            LegendItem(color: AppColors.success, label: '${l10n.active} (${fmtDuration(activeMs)})'),
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
