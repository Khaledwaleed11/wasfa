import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('favoriteMeals');
  await Hive.openBox('recentMeals');
  await Hive.openBox('shopping_list');
  await Hive.openBox('settings');

  final settingsBox = Hive.box('settings');

  final isDarkMode = settingsBox.get('isDarkMode', defaultValue: false) as bool;

  runApp(WasfaApp(isDarkMode: isDarkMode));
}

class WasfaApp extends StatefulWidget {
  final bool isDarkMode;

  const WasfaApp({super.key, required this.isDarkMode});

  @override
  State<WasfaApp> createState() => _WasfaAppState();
}

class _WasfaAppState extends State<WasfaApp> {
  late ThemeMode themeMode;

  @override
  void initState() {
    super.initState();

    themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final newMode = themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    setState(() {
      themeMode = newMode;
    });

    final settingsBox = Hive.box('settings');

    await settingsBox.put('isDarkMode', newMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wasfa',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: SplashScreen(
        isDarkMode: themeMode == ThemeMode.dark,
        onThemeToggle: toggleTheme,
      ),
    );
  }
}
