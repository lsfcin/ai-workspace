import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/insight_content.dart';
import '../../l10n/app_localizations.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import 'insight_data.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key, required this.storage});
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = InsightData.compute(storage);
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
        body: TabBarView(
          children: [
            _InsightCarousel(insights: kAlertas, data: data),
            _InsightCarousel(insights: kSolucoes, data: data),
          ],
        ),
      ),
    );
  }
}

class _InsightCarousel extends StatefulWidget {
  const _InsightCarousel({required this.insights, required this.data});
  final List<InsightEntry> insights;
  final InsightData data;

  @override
  State<_InsightCarousel> createState() => _InsightCarouselState();
}

class _InsightCarouselState extends State<_InsightCarousel> {
  late final PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.insights.length;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
              child: _InsightCard(
                insight: widget.insights[i],
                data: widget.data,
                index: i,
                total: count,
              ),
            ),
          ),
        ),
        _DotIndicator(
            count: count, current: _current, controller: _controller),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator(
      {required this.count,
      required this.current,
      required this.controller});
  final int count;
  final int current;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return GestureDetector(
          onTap: () => controller.animateToPage(i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: active
                  ? AppColors.primary
                  : AppColors.primary.withAlpha(60),
            ),
          ),
        );
      }),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.insight,
    required this.data,
    required this.index,
    required this.total,
  });
  final InsightEntry insight;
  final InsightData data;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final analysis = insight.analysisFn(data);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(24),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(insight.icon,
                      size: 22, color: AppColors.primary),
                ),
                const Spacer(),
                Text(
                  '${index + 1} / $total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              insight.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primary.withAlpha(50), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.data_usage_outlined,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      analysis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              insight.body,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),

            const Divider(height: 1),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(insight.url);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.open_in_new,
                      size: 11, color: scheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      insight.reference,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: scheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
