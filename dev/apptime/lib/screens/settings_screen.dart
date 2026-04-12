import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'goal_screen.dart';
import 'per_app_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.storage,
    required this.onLocaleChange,
  });

  final StorageService storage;
  final void Function(String?) onLocaleChange;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StorageService get _s => widget.storage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentCode = _s.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SectionHeader(l10n.sectionOverlay),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.showBorder),
                  value: _s.overlayShowBorder,
                  onChanged: (v) => setState(() => _s.overlayShowBorder = v),
                ),
                SwitchListTile(
                  title: Text(l10n.showBackground),
                  value: _s.overlayShowBackground,
                  onChanged: (v) => setState(() => _s.overlayShowBackground = v),
                ),
                ListTile(
                  title: Text(l10n.fontSize(_s.overlayFontSize.round())),
                  subtitle: Slider(
                    min: 10,
                    max: 30,
                    divisions: 20,
                    value: _s.overlayFontSize,
                    onChanged: (v) => setState(() => _s.overlayFontSize = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(l10n.sectionPositioning),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.verticalPosition(_s.overlayTopDp.round())),
                  subtitle: Slider(
                    min: 0,
                    max: 300,
                    value: _s.overlayTopDp,
                    onChanged: (v) => setState(() => _s.overlayTopDp = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(l10n.sectionBehavior),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.goalSettingsTile),
                  subtitle: Text(l10n.goalSettingsSub),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GoalScreen(storage: _s),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(l10n.perAppControlTitle),
                  subtitle: Text(l10n.perAppControlSub),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PerAppScreen(storage: _s),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(l10n.sectionLanguage),
          Card(
            child: RadioGroup<String?>(
              groupValue: currentCode,
              onChanged: (code) => _changeLocale(code, l10n),
              child: Column(
                children: [
                  RadioListTile<String?>(
                    title: Text(l10n.languageSystem),
                    value: null,
                  ),
                  RadioListTile<String?>(
                    title: Text(l10n.languagePtBr),
                    value: 'pt',
                  ),
                  RadioListTile<String?>(
                    title: Text(l10n.languageEn),
                    value: 'en',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeLocale(String? code, AppLocalizations l10n) {
    setState(() => _s.languageCode = code);
    widget.onLocaleChange(code);
  }


}

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
