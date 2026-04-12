import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.init();
  runApp(AppTimeApp(storage: storage));
}

class AppTimeApp extends StatelessWidget {
  const AppTimeApp({super.key, required this.storage});

  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppTime',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: MainScreen(storage: storage),
      debugShowCheckedModeBanner: false,
    );
  }
}
