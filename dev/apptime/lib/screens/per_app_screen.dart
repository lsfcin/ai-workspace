import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class PerAppScreen extends StatefulWidget {
  const PerAppScreen({super.key, required this.storage});

  final StorageService storage;

  @override
  State<PerAppScreen> createState() => _PerAppScreenState();
}

class _PerAppScreenState extends State<PerAppScreen> {
  StorageService get _s => widget.storage;

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
      appBar: AppBar(title: Text(l10n.perAppTitle)),
      body: packages.isEmpty
          ? Center(child: Text(l10n.noAppsMsg))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: packages.length,
              itemBuilder: (_, i) {
                final pkg = packages[i];
                final disabled = _s.disabledApps.contains(pkg);
                return SwitchListTile(
                  title: Text(
                    pkg,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                      disabled ? l10n.overlayDisabled : l10n.overlayActive),
                  value: !disabled,
                  onChanged: (_) => setState(() => _s.toggleApp(pkg)),
                );
              },
            ),
    );
  }
}
