import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper tipado sobre SharedPreferences.
/// Também é a interface de leitura/escrita usada pelos serviços Kotlin via prefs nativas.
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // ── Overlay state (escrito pelo MonitoringService Kotlin, lido pelo OverlayService) ──

  String get overlayText => _prefs.getString('overlay_text') ?? '';
  set overlayText(String v) => _prefs.setString('overlay_text', v);

  bool get overlayVisible => _prefs.getBool('overlay_visible') ?? false;
  set overlayVisible(bool v) => _prefs.setBool('overlay_visible', v);

  // ── Overlay appearance (escrito pelo Flutter, lido pelo OverlayService) ──

  double get overlayFontSize => _prefs.getDouble('overlay_font_size') ?? 14.0;
  set overlayFontSize(double v) => _prefs.setDouble('overlay_font_size', v);

  double get overlayTopDp => _prefs.getDouble('overlay_top_dp') ?? 40.0;
  set overlayTopDp(double v) => _prefs.setDouble('overlay_top_dp', v);

  bool get overlayShowBorder => _prefs.getBool('overlay_show_border') ?? false;
  set overlayShowBorder(bool v) => _prefs.setBool('overlay_show_border', v);

  bool get overlayShowBackground => _prefs.getBool('overlay_show_background') ?? false;
  set overlayShowBackground(bool v) => _prefs.setBool('overlay_show_background', v);

  // ── Session data (escrito pelo MonitoringService Kotlin) ──

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int getDailyMs(String packageName, {String? date}) =>
      _prefs.getInt('daily_ms_${packageName}_${date ?? _todayKey()}') ?? 0;

  int getOpenCount(String packageName, {String? date}) =>
      _prefs.getInt('open_count_${packageName}_${date ?? _todayKey()}') ?? 0;

  int getUnlockCount({String? date}) =>
      _prefs.getInt('unlock_count_${date ?? _todayKey()}') ?? 0;

  int getDeviceDailyMs({String? date}) =>
      _prefs.getInt('device_daily_ms_${date ?? _todayKey()}') ?? 0;

  // ── Per-app control ──

  Set<String> get disabledApps =>
      _prefs.getStringList('disabled_apps')?.toSet() ?? {};

  set disabledApps(Set<String> apps) =>
      _prefs.setStringList('disabled_apps', apps.toList());

  void toggleApp(String packageName) {
    final apps = disabledApps;
    if (apps.contains(packageName)) {
      apps.remove(packageName);
    } else {
      apps.add(packageName);
    }
    disabledApps = apps;
  }

  // ── Daily goal ──

  int get dailyGoalMinutes => _prefs.getInt('daily_goal_minutes') ?? 0;
  set dailyGoalMinutes(int v) => _prefs.setInt('daily_goal_minutes', v);

  // ── Query helpers ──

  /// Retorna packages que têm dados de uso para a data dada (formato YYYY-MM-DD).
  List<String> packagesDailyMs(String date) {
    const prefix = 'flutter.daily_ms_';
    final suffix = '_$date';
    return _prefs
        .getKeys()
        .where((k) => k.startsWith(prefix) && k.endsWith(suffix))
        .map((k) => k.substring(prefix.length, k.length - suffix.length))
        .toList();
  }
}
