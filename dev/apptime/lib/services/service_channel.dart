import 'package:flutter/services.dart';

const kServiceChannel = 'apptime/service';

/// Bridge para o MethodChannel Kotlin — OverlayService e MonitoringService.
class ServiceChannel {
  static const _channel = MethodChannel(kServiceChannel);

  static Future<void> startMonitoring() => _channel.invokeMethod('startMonitoring');
  static Future<void> stopMonitoring() => _channel.invokeMethod('stopMonitoring');
  static Future<bool> isRunning() async =>
      await _channel.invokeMethod<bool>('isRunning') ?? false;

  static Future<void> requestOverlayPermission() =>
      _channel.invokeMethod('requestOverlayPermission');
  static Future<bool> hasOverlayPermission() async =>
      await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;

  static Future<void> requestUsagePermission() =>
      _channel.invokeMethod('requestUsagePermission');
  static Future<bool> hasUsagePermission() async =>
      await _channel.invokeMethod<bool>('hasUsagePermission') ?? false;

  /// Returns a map of packageName → display label for all app-drawer-visible apps.
  static Future<Map<String, String>> getInstalledAppLabels() async {
    final raw = await _channel.invokeMethod<Map<Object?, Object?>>('getInstalledApps');
    if (raw == null) return {};
    return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  /// Returns package names of all apps registered as home-screen launchers.
  static Future<Set<String>> getLaunchers() async {
    final raw = await _channel.invokeMethod<List<Object?>>('getLaunchers');
    if (raw == null) return {};
    return raw.map((e) => e.toString()).toSet();
  }

  /// Single call combining getInstalledApps + getLaunchers — use this instead
  /// of the two separate methods to avoid double channel round-trips.
  static Future<({Map<String, String> labels, Set<String> launchers})>
      getAppMetadata() async {
    final raw =
        await _channel.invokeMethod<Map<Object?, Object?>>('getAppMetadata');
    if (raw == null) return (labels: const <String, String>{}, launchers: const <String>{});
    final labelsRaw = raw['labels'] as Map<Object?, Object?>? ?? {};
    final launchersRaw = raw['launchers'] as List<Object?>? ?? [];
    return (
      labels: Map<String, String>.fromEntries(
          labelsRaw.entries.map((e) => MapEntry(e.key.toString(), e.value.toString()))),
      launchers: launchersRaw.map((e) => e.toString()).toSet(),
    );
  }
}
