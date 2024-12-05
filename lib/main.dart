import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:signals/signals_flutter.dart';

import 'package:habits/screens/splash_screen.dart';
import 'package:habits/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await serviceLocator.setup();
  await serviceLocator.settingsService.loadSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final settingsService = serviceLocator.settingsService;
      final themeMode = settingsService.settings.themeMode.value;
      final themeScheme = settingsService.settings.themeScheme.value;

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        restorationScopeId: 'app',
        title: 'Let\'s Habit',
        home: const SplashScreen(),
        themeMode: themeMode,
        theme: FlexThemeData.light(
          useMaterial3: true,
          scheme: themeScheme,
          fontFamily: 'Montserrat',
        ),
        darkTheme: FlexThemeData.dark(
          scheme: themeScheme,
          useMaterial3: true,
          fontFamily: 'Montserrat',
        ),
      );
    });
  }
}
