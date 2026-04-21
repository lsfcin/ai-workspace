import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics_service.dart';
import '../../services/app_info_service.dart';
import '../../services/storage_service.dart';
import 'tab_day.dart';
import 'tab_month.dart';
import 'tab_week.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.storage, required this.appInfo});
  final StorageService storage;
  final AppInfoService appInfo;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final AnalyticsService _analytics;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _analytics = AnalyticsService(widget.storage);
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysisTitle),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.tab1d),
            Tab(text: l10n.tab7d),
            Tab(text: l10n.tab30d),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          Tab1d(storage: widget.storage, analytics: _analytics),
          Tab7d(storage: widget.storage, analytics: _analytics),
          Tab30d(storage: widget.storage, analytics: _analytics),
        ],
      ),
    );
  }
}
