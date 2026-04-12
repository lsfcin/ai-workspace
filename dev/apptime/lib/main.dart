import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'services/service_channel.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.init();

  // Show onboarding when either required permission is missing.
  final results = await Future.wait([
    ServiceChannel.hasOverlayPermission(),
    ServiceChannel.hasUsagePermission(),
  ]);
  final allGranted = results[0] && results[1];

  runApp(AppTimeApp(storage: storage, skipOnboarding: allGranted));
}

class AppTimeApp extends StatelessWidget {
  const AppTimeApp({super.key, required this.storage, required this.skipOnboarding});

  final StorageService storage;
  final bool skipOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppTime',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: skipOnboarding
          ? MainScreen(storage: storage)
          : OnboardingScreen(storage: storage),
      debugShowCheckedModeBanner: false,
    );
  }
}
