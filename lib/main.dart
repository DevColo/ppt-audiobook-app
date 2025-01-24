import 'package:flutter/material.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/providers/categories_provider.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/screens/get_in_touch_screen.dart';
import 'package:precious/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:precious/main_layout.dart';
import 'package:precious/screens/welcome_screen.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/providers/collections_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CollectionsProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => SermonsProvider()),
        ChangeNotifierProvider(create: (_) => AudioBooksProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Navigator key for push navigation
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // Add any shared app theme configurations here
          ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        'main': (context) => const MainLayout(),
        'settings': (context) => const SettingsScreen(),
        'get_in_touch': (context) => const GetInTouchScreen(),
      },
    );
  }
}
