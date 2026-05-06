import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/insights/insights_screen.dart';
import 'screens/monitoring_screen.dart';
import 'screens/settings_screen.dart';
import 'services/app_info_service.dart';
import 'services/storage_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.storage,
    required this.onLocaleChange,
  });

  final StorageService storage;
  final void Function(String?) onLocaleChange;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final AppInfoService _appInfo;
  // Screens are built lazily on first visit — avoids running initState (and
  // prefs reads) for tabs the user never opens in a given session.
  final _screens = <int, Widget>{};

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return SettingsScreen(
          storage: widget.storage,
          onLocaleChange: widget.onLocaleChange,
        );
      case 1:
        return MonitoringScreen(storage: widget.storage, appInfo: _appInfo);
      case 2:
        return AnalyticsScreen(storage: widget.storage, appInfo: _appInfo);
      default:
        return InsightsScreen(storage: widget.storage);
    }
  }

  @override
  void initState() {
    super.initState();
    _appInfo = AppInfoService();
    _screens[0] = _buildScreen(0);   // initial tab always built at startup
    // Single load point — seeds labelForApp() + isLauncherPkg() globals.
    _appInfo.load().then((_) { if (mounted) setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          for (int i = 0; i < 4; i++)
            Offstage(
              offstage: _selectedIndex != i,
              child: _screens.containsKey(i)
                  ? _screens[i]!
                  : const SizedBox.shrink(),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          // Build the screen widget on first visit only.
          _screens.putIfAbsent(i, () => _buildScreen(i));
          setState(() => _selectedIndex = i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.monitor_heart_outlined),
            selectedIcon: const Icon(Icons.monitor_heart),
            label: l10n.navMonitoring,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navAnalysis,
          ),
          NavigationDestination(
            icon: const Icon(Icons.lightbulb_outlined),
            selectedIcon: const Icon(Icons.lightbulb),
            label: l10n.navInsights,
          ),
        ],
      ),
    );
  }
}
