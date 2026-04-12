import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/goal_config.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key, required this.storage});

  final StorageService storage;

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  StorageService get _s => widget.storage;

  int get _globalLevel => _s.goalLevel;

  List<String> _getUsedPackages() {
    final today = DateTime.now();
    final packages = <String>{};
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      packages.addAll(_s.packagesDailyMs(dateStr));
    }
    return packages.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final packages = _getUsedPackages();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SectionHeader(l10n.goalLevelSectionTitle),
          const SizedBox(height: AppSpacing.sm),
          _GoalLevelCard(
            level: 0,
            name: l10n.goalLevelNone,
            rationale: l10n.goalRationaleNone,
            thresholds: null,
            selected: _globalLevel == 0,
            onTap: () => setState(() => _s.goalLevel = 0),
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalLevelCard(
            level: 1,
            name: l10n.goalLevelMinimal,
            rationale: l10n.goalRationaleMinimal,
            thresholds: GoalThresholds.byLevel[GoalLevel.minimal]!,
            selected: _globalLevel == 1,
            onTap: () => setState(() => _s.goalLevel = 1),
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalLevelCard(
            level: 2,
            name: l10n.goalLevelNormal,
            rationale: l10n.goalRationaleNormal,
            thresholds: GoalThresholds.byLevel[GoalLevel.normal]!,
            selected: _globalLevel == 2,
            onTap: () => setState(() => _s.goalLevel = 2),
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalLevelCard(
            level: 3,
            name: l10n.goalLevelExtensive,
            rationale: l10n.goalRationaleExtensive,
            thresholds: GoalThresholds.byLevel[GoalLevel.extensive]!,
            selected: _globalLevel == 3,
            onTap: () => setState(() => _s.goalLevel = 3),
          ),
          if (packages.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(l10n.goalPerAppTitle),
            Text(
              l10n.goalPerAppSub,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  for (final pkg in packages)
                    _AppGoalRow(
                      packageName: pkg,
                      storage: _s,
                      l10n: l10n,
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Level card ─────────────────────────────────────────────────────────────────

class _GoalLevelCard extends StatelessWidget {
  const _GoalLevelCard({
    required this.level,
    required this.name,
    required this.rationale,
    required this.thresholds,
    required this.selected,
    required this.onTap,
  });

  final int level;
  final String name;
  final String rationale;
  final GoalThresholds? thresholds;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = selected
        ? BorderSide(color: AppColors.primary, width: 2)
        : BorderSide(color: scheme.outline.withValues(alpha: 0.3));

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md,
        side: border,
      ),
      child: InkWell(
        borderRadius: AppRadius.md,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selected)
                    const Icon(Icons.radio_button_checked,
                        color: AppColors.primary, size: 20)
                  else
                    Icon(Icons.radio_button_unchecked,
                        color: scheme.onSurface.withValues(alpha: 0.4),
                        size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.primary : null,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                rationale,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
              if (thresholds != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _Chip('${thresholds!.phoneLimitMinutes}min total'),
                    _Chip('${thresholds!.appLimitMinutes}min/app'),
                    _Chip('${thresholds!.unlockLimit}× unlocks'),
                    _Chip('${thresholds!.maxSessionMinutes}min session'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppRadius.sm,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

// ── Per-app row ────────────────────────────────────────────────────────────────

class _AppGoalRow extends StatefulWidget {
  const _AppGoalRow({
    required this.packageName,
    required this.storage,
    required this.l10n,
  });

  final String packageName;
  final StorageService storage;
  final AppLocalizations l10n;

  @override
  State<_AppGoalRow> createState() => _AppGoalRowState();
}

class _AppGoalRowState extends State<_AppGoalRow> {
  late int _level;

  @override
  void initState() {
    super.initState();
    _level = widget.storage.getAppGoalLevel(widget.packageName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final appLabel = widget.packageName.split('.').last;

    return ListTile(
      title: Text(
        appLabel,
        style: const TextStyle(fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.packageName,
        style: const TextStyle(fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: DropdownButton<int>(
        value: _level,
        underline: const SizedBox(),
        isDense: true,
        items: [
          DropdownMenuItem(value: 0, child: Text(l10n.goalOverrideGlobal)),
          DropdownMenuItem(value: 1, child: Text(l10n.goalLevelMinimal)),
          DropdownMenuItem(value: 2, child: Text(l10n.goalLevelNormal)),
          DropdownMenuItem(value: 3, child: Text(l10n.goalLevelExtensive)),
        ],
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _level = v;
            widget.storage.setAppGoalLevel(widget.packageName, v);
          });
        },
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
