import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

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
                  title: Text(l10n.showOverlay),
                  subtitle: Text(l10n.showOverlaySub),
                  value: _s.overlayEnabled,
                  onChanged: (v) => setState(() => _s.overlayEnabled = v),
                ),
                const Divider(height: 1, indent: 16),
                SwitchListTile(
                  title: Text(l10n.showBorder),
                  value: _s.overlayShowBorder,
                  onChanged: _s.overlayEnabled ? (v) => setState(() => _s.overlayShowBorder = v) : null,
                ),
                SwitchListTile(
                  title: Text(l10n.showBackground),
                  value: _s.overlayShowBackground,
                  onChanged: _s.overlayEnabled ? (v) => setState(() => _s.overlayShowBackground = v) : null,
                ),
                ListTile(
                  enabled: _s.overlayEnabled,
                  title: Text(l10n.fontSize(_s.overlayFontSize.round())),
                  subtitle: Slider(
                    min: 10,
                    max: 30,
                    divisions: 20,
                    value: _s.overlayFontSize,
                    onChanged: _s.overlayEnabled ? (v) => setState(() => _s.overlayFontSize = v) : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(l10n.sectionBehavior),
          Card(
            child: SwitchListTile(
              title: Text(l10n.monitorLauncherTitle),
              subtitle: Text(l10n.monitorLauncherSub),
              value: _s.monitorLauncher,
              onChanged: (v) => setState(() => _s.monitorLauncher = v),
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
