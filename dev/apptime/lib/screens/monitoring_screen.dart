import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/goal_config.dart';
import '../services/service_channel.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'per_app_screen.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key, required this.storage});
  final StorageService storage;

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
    with WidgetsBindingObserver {
  StorageService get _s => widget.storage;

  bool _isRunning = false;
  bool _hasOverlayPermission = false;
  bool _hasUsagePermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final results = await Future.wait([
      ServiceChannel.isRunning(),
      ServiceChannel.hasOverlayPermission(),
      ServiceChannel.hasUsagePermission(),
    ]);
    if (mounted) {
      setState(() {
        _isRunning = results[0];
        _hasOverlayPermission = results[1];
        _hasUsagePermission = results[2];
      });
    }
  }

  bool get _allPermissionsGranted =>
      _hasOverlayPermission && _hasUsagePermission;

  Future<void> _toggleMonitoring() async {
    if (!_allPermissionsGranted) return;
    if (_isRunning) {
      await ServiceChannel.stopMonitoring();
    } else {
      await ServiceChannel.startMonitoring();
    }
    await _refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final globalLevel = _s.goalLevel;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMonitoring)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Monitoring start/stop ──────────────────────────────────────
          _SectionHeader(l10n.monitoringTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRunning
                        ? l10n.monitoringActive
                        : _allPermissionsGranted
                            ? l10n.monitoringInactive
                            : l10n.monitoringNoPerms,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.monitoringDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed:
                        _allPermissionsGranted ? _toggleMonitoring : null,
                    icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                    label:
                        Text(_isRunning ? l10n.actionStop : l10n.actionStart),
                    style: _isRunning
                        ? FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Goal level ─────────────────────────────────────────────────
          _SectionHeader(l10n.goalLevelSectionTitle),
          const SizedBox(height: AppSpacing.sm),
          _GoalLevelCard(
            level: 0,
            name: l10n.goalLevelNone,
            rationale: l10n.goalRationaleNone,
            thresholds: null,
            selected: globalLevel == 0,
            onTap: () => setState(() => _s.goalLevel = 0),
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalLevelCard(
            level: 1,
            name: l10n.goalLevelMinimal,
            rationale: l10n.goalRationaleMinimal,
            thresholds: GoalThresholds.byLevel[GoalLevel.minimal]!,
            selected: globalLevel == 1,
            onTap: () => setState(() => _s.goalLevel = 1),
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalLevelCard(
            level: 2,
            name: l10n.goalLevelNormal,
            rationale: l10n.goalRationaleNormal,
            thresholds: GoalThresholds.byLevel[GoalLevel.normal]!,
            selected: globalLevel == 2,
            onTap: () => setState(() => _s.goalLevel = 2),
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalLevelCard(
            level: 3,
            name: l10n.goalLevelExtensive,
            rationale: l10n.goalRationaleExtensive,
            thresholds: GoalThresholds.byLevel[GoalLevel.extensive]!,
            selected: globalLevel == 3,
            onTap: () => setState(() => _s.goalLevel = 3),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Per-app control ────────────────────────────────────────────
          _SectionHeader(l10n.perAppControlTitle),
          Card(
            child: ListTile(
              title: Text(l10n.perAppControlTitle),
              subtitle: Text(l10n.perAppControlSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PerAppScreen(storage: _s),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Goal level card ────────────────────────────────────────────────────────────

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

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
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
