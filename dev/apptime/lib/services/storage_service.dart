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

  // ── Rolling 24h helpers ──
  // Since data is stored per calendar day we approximate the rolling 24h window
  // as: yesterday's total * fraction still within the window + all of today's total.
  // Assumption: usage is roughly uniform throughout the day (best we can do with
  // daily-granularity storage without a full schema change).

  String _yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  /// Fraction of the previous calendar day still within the last 24h.
  double _yesterdayFraction() {
    final now = DateTime.now();
    final hoursElapsedToday =
        now.hour + now.minute / 60.0 + now.second / 3600.0;
    return (24.0 - hoursElapsedToday) / 24.0;
  }

  int getLast24hMs(String packageName) {
    final f = _yesterdayFraction();
    final yesterdayMs = getDailyMs(packageName, date: _yesterdayKey());
    final todayMs = getDailyMs(packageName);
    return (yesterdayMs * f).round() + todayMs;
  }

  int getDeviceLast24hMs() {
    final f = _yesterdayFraction();
    final yesterdayMs = getDeviceDailyMs(date: _yesterdayKey());
    final todayMs = getDeviceDailyMs();
    return (yesterdayMs * f).round() + todayMs;
  }

  int getUnlockLast24h() {
    final f = _yesterdayFraction();
    final yesterdayUnlocks = getUnlockCount(date: _yesterdayKey());
    final todayUnlocks = getUnlockCount();
    return (yesterdayUnlocks * f).round() + todayUnlocks;
  }

  /// Packages that have any usage data in the last 24h (today or yesterday).
  List<String> packagesLast24h() {
    final today = _todayKey();
    final yesterday = _yesterdayKey();
    const prefix = 'flutter.daily_ms_';
    final keys = _prefs.getKeys();
    final packages = <String>{};
    for (final k in keys) {
      if (k.startsWith(prefix)) {
        if (k.endsWith('_$today') || k.endsWith('_$yesterday')) {
          packages.add(k.substring(prefix.length, k.lastIndexOf('_')));
        }
      }
    }
    return packages.toList();
  }

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
