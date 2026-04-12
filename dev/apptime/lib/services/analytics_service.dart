import '../services/storage_service.dart';

class AppUsage {
  const AppUsage({
    required this.packageName,
    required this.dailyMs,
    required this.openCount,
  });

  final String packageName;
  final int dailyMs; // ms acumulados no dia
  final int openCount;
}

class DaySummary {
  const DaySummary({
    required this.date,
    required this.totalMs,
    required this.unlockCount,
    required this.apps,
  });

  final String date; // YYYY-MM-DD
  final int totalMs;
  final int unlockCount;
  final List<AppUsage> apps;

  List<AppUsage> get topApps {
    final sorted = [...apps]..sort((a, b) => b.dailyMs.compareTo(a.dailyMs));
    return sorted.take(5).toList();
  }
}

class AnalyticsService {
  const AnalyticsService(this._storage);

  final StorageService _storage;

  /// Retorna sumário para os últimos [days] dias (1, 7 ou 30).
  List<DaySummary> getSummaries(int days) {
    final today = DateTime.now();
    final summaries = <DaySummary>[];

    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = _fmt(date);
      final packages = _storage.packagesDailyMs(dateStr);

      final apps = packages.map((pkg) {
        return AppUsage(
          packageName: pkg,
          dailyMs: _storage.getDailyMs(pkg, date: dateStr),
          openCount: _storage.getOpenCount(pkg, date: dateStr),
        );
      }).toList();

      summaries.add(DaySummary(
        date: dateStr,
        totalMs: _storage.getDeviceDailyMs(date: dateStr),
        unlockCount: _storage.getUnlockCount(date: dateStr),
        apps: apps,
      ));
    }

    return summaries;
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
