import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pockettracer/pages/home_screen.dart';
import 'package:pockettracer/pages/main_screen.dart';
import 'package:pockettracer/pages/reports_screen.dart';
import 'package:pockettracer/pages/settings_screen.dart';
import 'package:pockettracer/pages/splash_screen.dart';
import 'package:pockettracer/services/theme_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService()..initialize(),
      child: const PocketTracerApp(),
    ),
  );
}

class PocketTracerApp extends StatelessWidget {
  const PocketTracerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Pocket Tracer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/main': (context) => const MainScreen(),
            '/home': (context) => HomeScreen(),
            '/reports': (context) => ReportsScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
