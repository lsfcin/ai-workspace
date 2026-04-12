import 'dart:async';
import 'package:flutter/material.dart';
import '../data/insights.dart';
import '../services/service_channel.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isRunning = false;
  bool _hasOverlayPermission = false;
  bool _hasUsagePermission = false;

  late int _insightIndex;
  Timer? _insightTimer;

  static int _currentInsightIndex() {
    // Rotate every 3 minutes based on wall-clock time so all sessions agree
    final minutes = DateTime.now().millisecondsSinceEpoch ~/ (3 * 60 * 1000);
    return minutes % kInsights.length;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _insightIndex = _currentInsightIndex();
    // Re-check every 30s so the switch happens within 30s of the 3-min boundary
    _insightTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final next = _currentInsightIndex();
      if (next != _insightIndex) setState(() => _insightIndex = next);
    });
    _refreshStatus();
  }

  @override
  void dispose() {
    _insightTimer?.cancel();
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

  bool get _allPermissionsGranted => _hasOverlayPermission && _hasUsagePermission;

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
    return Scaffold(
      appBar: AppBar(title: const Text('AppTime')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _PermissionCard(
            label: 'Janela flutuante',
            granted: _hasOverlayPermission,
            onRequest: () async {
              await ServiceChannel.requestOverlayPermission();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _PermissionCard(
            label: 'Estatísticas de uso',
            granted: _hasUsagePermission,
            onRequest: () async {
              await ServiceChannel.requestUsagePermission();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _InsightCard(insight: kInsights[_insightIndex]),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contador',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _isRunning
                        ? 'Ativo — overlay mostrando uso em tempo real.'
                        : _allPermissionsGranted
                            ? 'Inativo. Toque em Iniciar.'
                            : 'Conceda as permissões acima para iniciar.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'O overlay exibe quantas vezes você abriu o app (5s) e o tempo acumulado.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: _allPermissionsGranted ? _toggleMonitoring : null,
                    icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(_isRunning ? 'Parar' : 'Iniciar'),
                    style: _isRunning
                        ? FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final String insight;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Insight do dia',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              insight,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.label,
    required this.granted,
    required this.onRequest,
  });

  final String label;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          granted ? Icons.check_circle : Icons.warning_amber_rounded,
          color: granted ? AppColors.success : Theme.of(context).colorScheme.error,
        ),
        title: Text(label),
        subtitle: Text(granted ? 'Concedida' : 'Necessária'),
        trailing: granted
            ? null
            : TextButton(onPressed: onRequest, child: const Text('Conceder')),
      ),
    );
  }
}
