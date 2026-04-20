import 'service_channel.dart';
import '../utils/app_info.dart';

/// Holds runtime app metadata (PackageManager labels + launcher packages).
/// Created once in MainScreen, loaded via a single channel call, then passed
/// to any screen that needs dynamic app names or launcher classification.
class AppInfoService {
  Map<String, String> labels = const {};
  Set<String> launchers = const {};

  Future<void> load() async {
    final meta = await ServiceChannel.getAppMetadata();
    labels = meta.labels;
    launchers = meta.launchers;
    // Seed module-level helpers so labelForApp() and isLauncherPkg() stay in sync.
    seedDynamicLabels(labels);
    seedDynamicLaunchers(launchers);
  }
}
