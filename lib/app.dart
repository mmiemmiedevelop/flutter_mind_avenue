import 'package:flutter/material.dart';
import 'views/home/home_view.dart';
import 'views/calendar/calendar_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodAvenue',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/': (context) => const HomeView(),
        '/calendar': (context) => const CalendarView(),
      },
    );
  }
}
