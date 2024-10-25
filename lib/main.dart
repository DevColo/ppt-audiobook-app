import 'package:precious/main_layout.dart';
import 'package:precious/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:precious/providers/app_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //this is for push navigator
  static final navigatorKey = GlobalKey<NavigatorState>();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppProvider>(
      create: (context) => AppProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            //pre-define input decoration
            ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          'main': (context) => const MainLayout(),
        },
      ),
    );
  }
}

class QuizHistoryScreen {
  const QuizHistoryScreen();
}
