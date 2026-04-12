import 'package:flutter/material.dart';
import '../services/service_channel.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.storage});
  final StorageService storage;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  int _step = 0; // 0 = welcome, 1 = overlay perm, 2 = usage perm
  bool _overlayGranted = false;
  bool _usageGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called every time the user returns from the system settings screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final results = await Future.wait([
      ServiceChannel.hasOverlayPermission(),
      ServiceChannel.hasUsagePermission(),
    ]);
    if (!mounted) return;
    setState(() {
      _overlayGranted = results[0];
      _usageGranted = results[1];
    });
    // Auto-advance to next pending step when the user returns with a new grant.
    if (_step == 1 && _overlayGranted) {
      setState(() => _step = 2);
    } else if (_step == 2 && _usageGranted) {
      _finish();
    }
    // If all permissions are already granted (e.g. re-install), skip straight through.
    if (_overlayGranted && _usageGranted) _finish();
  }

  void _finish() {
    widget.storage.onboardingDone = true;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainScreen(storage: widget.storage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStep(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    return switch (_step) {
      0 => _WelcomeStep(onNext: () => setState(() => _step = 1)),
      1 => _PermissionStep(
          key: const ValueKey(1),
          icon: Icons.picture_in_picture_outlined,
          title: 'Janela flutuante',
          description: 'O AppTime precisa desta permissão para mostrar o '
              'contador de uso em tempo real sobre outros apps, sem '
              'interromper o que você está fazendo.',
          granted: _overlayGranted,
          onGrant: ServiceChannel.requestOverlayPermission,
          onNext: _overlayGranted ? () => setState(() => _step = 2) : null,
        ),
      _ => _PermissionStep(
          key: const ValueKey(2),
          icon: Icons.bar_chart_outlined,
          title: 'Estatísticas de uso',
          description: 'Esta permissão permite que o AppTime acesse quais apps '
              'estão em primeiro plano para contabilizar seu tempo de uso com '
              'precisão.',
          granted: _usageGranted,
          onGrant: ServiceChannel.requestUsagePermission,
          onNext: _usageGranted ? _finish : null,
        ),
    };
  }
}

// ─── Step widgets ─────────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Icon(Icons.timer_outlined, size: 64, color: AppColors.primary),
        const SizedBox(height: AppSpacing.lg),
        Text('Bem-vindo ao AppTime',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Consciência sem bloqueio.\n\n'
          'O AppTime mostra, em tempo real, quantas vezes você abriu cada app '
          'e quanto tempo você passou nele — direto na sua tela, como um '
          'relógio discreto.\n\n'
          'Precisamos de 2 permissões para funcionar.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onNext,
            child: const Text('Começar'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _PermissionStep extends StatelessWidget {
  const _PermissionStep({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.onGrant,
    required this.onNext,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final Future<void> Function() onGrant;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Row(children: [
          Icon(icon, size: 40, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.headlineSmall),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        if (granted)
          Row(children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: AppSpacing.sm),
            Text('Permissão concedida',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.success)),
          ])
        else
          Text(
            'Você será direcionado para as configurações do sistema. '
            'Conceda a permissão e volte ao app.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        const Spacer(),
        if (!granted)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onGrant,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Abrir configurações'),
            ),
          ),
        if (granted && onNext != null) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Continuar'),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
