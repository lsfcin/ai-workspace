import '../../services/storage_service.dart';
import '../../utils/app_info.dart';

class InsightData {
  const InsightData({
    required this.todayUnlocks,
    required this.weeklyUnlocks,
    required this.avgDailyMin,
    required this.weeklyMin,
    required this.lateNightMin,
    required this.earlyUnlocks,
    required this.workUnlocks,
    required this.mealUnlocks,
    required this.microSessions,
    required this.passiveMin,
  });

  final int todayUnlocks;
  final int weeklyUnlocks;
  final int avgDailyMin;
  final int weeklyMin;
  final int lateNightMin;
  final int earlyUnlocks;
  final int workUnlocks;
  final int mealUnlocks;
  final int microSessions;
  final int passiveMin;

  static InsightData compute(StorageService s) {
    final today = DateTime.now();
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    int totalMs = 0, lateMs = 0, earlyUnlocks = 0, workUnlocks = 0,
        mealUnlocks = 0, weeklyUnlocks = 0, microSessions = 0;

    for (int i = 0; i < 7; i++) {
      final d = today.subtract(Duration(days: i));
      final date = fmt(d);
      totalMs += s.getDeviceDailyMs(date: date);
      weeklyUnlocks += s.getUnlockCount(date: date);
      for (final h in [22, 23, 0, 1, 2, 3, 4, 5]) {
        lateMs += s.getDeviceHourlyMs(date: date, hour: h);
      }
      for (final h in [6, 7]) {
        earlyUnlocks += s.getHourlyUnlocks(date: date, hour: h);
      }
      for (final h in [9, 10, 11, 12, 13, 14, 15, 16, 17, 18]) {
        workUnlocks += s.getHourlyUnlocks(date: date, hour: h);
      }
      for (final h in [12, 13, 14, 19, 20, 21]) {
        mealUnlocks += s.getHourlyUnlocks(date: date, hour: h);
      }
      final buckets = s.getSessionBuckets(date: date);
      if (buckets.isNotEmpty) microSessions += buckets[0];
    }

    int passiveMs = 0;
    final disabled = s.disabledApps;
    final packages = <String>{};
    for (int i = 0; i < 7; i++) {
      packages.addAll(s.packagesDailyMs(fmt(today.subtract(Duration(days: i)))));
    }
    for (final pkg in packages) {
      if (isPassiveApp(pkg) && !disabled.contains(pkg)) {
        for (int i = 0; i < 7; i++) {
          passiveMs += s.getDailyMs(pkg, date: fmt(today.subtract(Duration(days: i))));
        }
      }
    }

    return InsightData(
      todayUnlocks: s.getUnlockCount(),
      weeklyUnlocks: weeklyUnlocks,
      avgDailyMin: totalMs ~/ 7 ~/ 60000,
      weeklyMin: totalMs ~/ 60000,
      lateNightMin: lateMs ~/ 60000,
      earlyUnlocks: earlyUnlocks,
      workUnlocks: workUnlocks,
      mealUnlocks: mealUnlocks,
      microSessions: microSessions,
      passiveMin: passiveMs ~/ 60000,
    );
  }

  bool get hasData => weeklyMin > 0 || weeklyUnlocks > 0;
}
