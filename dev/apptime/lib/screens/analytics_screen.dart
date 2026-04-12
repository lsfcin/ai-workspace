import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.storage});

  final StorageService storage;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _period = 1; // 1, 7, 30

  late final AnalyticsService _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = AnalyticsService(widget.storage);
  }

  @override
  Widget build(BuildContext context) {
    final summaries = _analytics.getSummaries(_period);
    final totalMs = summaries.fold<int>(0, (acc, s) => acc + s.totalMs);
    final totalUnlocks = summaries.fold<int>(0, (acc, s) => acc + s.unlockCount);

    // Top apps agregados no período
    final aggApps = <String, int>{};
    for (final s in summaries) {
      for (final a in s.apps) {
        aggApps[a.packageName] = (aggApps[a.packageName] ?? 0) + a.dailyMs;
      }
    }
    final topApps = aggApps.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topFive = topApps.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Análise')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Period selector
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('Hoje')),
              ButtonSegment(value: 7, label: Text('7 dias')),
              ButtonSegment(value: 30, label: Text('30 dias')),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: AppSpacing.md),

          // Resumo
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Tempo total',
                  value: _formatDuration(totalMs),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  label: 'Desbloqueios',
                  value: '$totalUnlocks',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Top apps
          if (topFive.isNotEmpty) ...[
            Text('Top apps',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: topFive.map((e) {
                  final pct = totalMs > 0 ? e.value / totalMs : 0.0;
                  return ListTile(
                    dense: true,
                    title: Text(
                      e.key.split('.').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      color: AppColors.primary,
                    ),
                    trailing: Text(_formatDuration(e.value),
                        style: Theme.of(context).textTheme.bodySmall),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Uso diário (BarChart — apenas para 7 e 30 dias)
          if (_period > 1 && summaries.isNotEmpty) ...[
            Text('Uso diário',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  barGroups: summaries.reversed.toList().asMap().entries.map((e) {
                    final hours = e.value.totalMs / 3_600_000;
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: hours,
                          color: AppColors.primary,
                          width: _period == 7 ? 18 : 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          if (summaries.isEmpty || totalMs == 0)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl),
              child: Center(
                child: Text(
                  'Nenhum dado ainda.\nInicie o monitoramento e use o celular normalmente.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatDuration(int ms) {
    final totalMin = ms ~/ 60000;
    if (totalMin < 60) return '${totalMin}min';
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '${h}h${m.toString().padLeft(2, '0')}';
  }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
