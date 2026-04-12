import 'package:flutter/material.dart';
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

  /// Retorna os packages que tiveram uso nos últimos 7 dias,
  /// lidos das chaves `daily_ms_{pkg}_{date}` em SharedPreferences.
  List<String> _getUsedPackages() {
    // Stub — o MonitoringService escreve as chaves em runtime.
    // Em produção isso seria lido via queryEvents do UsageStatsManager no lado Kotlin.
    // Retornamos os packages que já têm dados em prefs.
    final today = DateTime.now();
    final packages = <String>{};
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      // Os dados reais são escritos pelo Kotlin — aqui apenas mostramos o que existe
      packages.addAll(
        _packagesForDate(dateStr),
      );
    }
    return packages.toList()..sort();
  }

  List<String> _packagesForDate(String date) {
    // Lemos da StorageService os packages com dados para a data dada
    return _s.packagesDailyMs(date);
  }

  @override
  Widget build(BuildContext context) {
    final packages = _getUsedPackages();

    return Scaffold(
      appBar: AppBar(title: const Text('Controle por app')),
      body: packages.isEmpty
          ? const Center(
              child: Text('Nenhum app registrado nos últimos 7 dias.\n'
                  'Inicie o monitoramento e use o celular normalmente.'),
            )
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
                  subtitle: Text(disabled ? 'Overlay desabilitado' : 'Overlay ativo'),
                  value: !disabled,
                  onChanged: (_) => setState(() => _s.toggleApp(pkg)),
                );
              },
            ),
    );
  }
}
