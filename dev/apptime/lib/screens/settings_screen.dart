import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'per_app_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.storage});

  final StorageService storage;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StorageService get _s => widget.storage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SectionHeader('Overlay'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mostrar borda'),
                  value: _s.overlayShowBorder,
                  onChanged: (v) => setState(() => _s.overlayShowBorder = v),
                ),
                SwitchListTile(
                  title: const Text('Mostrar fundo'),
                  value: _s.overlayShowBackground,
                  onChanged: (v) => setState(() => _s.overlayShowBackground = v),
                ),
                ListTile(
                  title: Text('Tamanho da fonte: ${_s.overlayFontSize.round()}sp'),
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
          _SectionHeader('Posicionamento'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                      'Posição vertical: ${_s.overlayTopDp.round()}dp'),
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
          _SectionHeader('Comportamento'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Meta diária de uso'),
                  subtitle: Text(
                    _s.dailyGoalMinutes == 0
                        ? 'Sem meta definida'
                        : '${_s.dailyGoalMinutes} minutos / dia',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showGoalDialog,
                ),
                ListTile(
                  title: const Text('Controle por app'),
                  subtitle: const Text('Habilitar / desabilitar overlay por app'),
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
        ],
      ),
    );
  }

  void _showGoalDialog() {
    int tempGoal = _s.dailyGoalMinutes;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Meta diária'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tempGoal == 0 ? 'Sem meta' : '$tempGoal min / dia',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              Slider(
                min: 0,
                max: 360,
                divisions: 24,
                value: tempGoal.toDouble(),
                onChanged: (v) => setLocal(() => tempGoal = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _s.dailyGoalMinutes = tempGoal);
                Navigator.pop(ctx);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.sm, bottom: AppSpacing.sm),
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
