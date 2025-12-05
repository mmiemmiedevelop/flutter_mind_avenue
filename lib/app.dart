import 'package:flutter/material.dart';
import 'views/splash/splash_view.dart';
import 'views/home/home_view.dart';
import 'views/calendar/calendar_view.dart';
import 'views/settings/setting_view.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodAvenue',
      theme: AppTheme.darkTheme,
      routes: {
        '/': (context) => const SplashView(),
        '/home': (context) => const HomeView(),
        '/calendar': (context) => const CalendarView(),
        '/settings': (context) => const SettingView(),
      },
    );
  }
}
