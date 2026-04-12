import 'package:flutter/services.dart';

/// Bridge para o MethodChannel Kotlin — OverlayService e MonitoringService.
class ServiceChannel {
  static const _channel = MethodChannel('apptime/service');

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
}
