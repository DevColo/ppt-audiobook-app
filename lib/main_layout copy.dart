import 'dart:io';

import 'package:flutter/material.dart';
import 'package:precious/providers/collections_provider.dart';
import 'package:precious/screens/downloaded_audios_screen.dart';
import 'package:precious/screens/home_screen.dart';
import 'package:precious/screens/search_screen.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/localization_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPage = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedLanguage = 'Kinyarwanda';

  final List<Map<String, String>> languages = [
    {'language': 'English', 'flag': 'assets/images/english.png', 'code': 'en'},
    {'language': 'French', 'flag': 'assets/images/french.png', 'code': 'fr'},
    {
      'language': 'Kinyarwanda',
      'flag': 'assets/images/kinyarwanda.png',
      'code': 'rw'
    },
    {
      'language': 'Swahili',
      'flag': 'assets/images/kiswahili.png',
      'code': 'sw'
    },
    {'language': 'Lingala', 'flag': 'assets/images/lingala.png', 'code': 'lg'},
    {'language': 'Tshiluba', 'flag': 'assets/images/default.png', 'code': 'ts'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentPage = prefs.getInt('currentPage') ?? 0;
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'Kinyarwanda';
    });

    await _applyLanguage(selectedLanguage);
  }

  Future<void> _savePage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPage', page);
  }

  Future<void> _applyLanguage(String language) async {
    final languageCode =
        languages.firstWhere((lang) => lang['language'] == language)['code']!;
    await LocalizationService().loadLanguage(languageCode);
    //await _fetchDataBasedOnLanguage();
  }

  Future<void> _fetchDataBasedOnLanguage() async {
    await Provider.of<CollectionsProvider>(context, listen: false)
        .getAllCollections();
  }

  void _changeLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocalizationService().translate('selectLanguage'),
          style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Montserrat-SemiBold',
              color: Config.darkColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: languages.map((language) {
              return ListTile(
                leading: Image.asset(language['flag']!, width: 30, height: 30),
                title: Text(language['language']!),
                onTap: () async {
                  setState(() => selectedLanguage = language['language']!);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('selectedLanguage', selectedLanguage);
                  await _applyLanguage(selectedLanguage);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 24.0),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
        ],
        backgroundColor: Config.whiteColor,
        surfaceTintColor: Config.whiteColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Config.primaryColor),
              child:
                  Image(image: AssetImage(preciousLogo), fit: BoxFit.contain),
            ),
            _drawerItem(Icons.home, 'home', () {
              _pageController.jumpToPage(0);
              Navigator.pop(context);
            }),
            _drawerItem(Icons.download, 'downloads', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DownloadedAudiosScreen()));
            }),
            _drawerItem(Icons.search, 'searchBookPreacher', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()));
            }),
            const Divider(),
            _drawerItem(Icons.language, 'changeLanguage',
                () => _changeLanguage(context)),
            _drawerItem(Icons.settings, 'settings',
                () => Navigator.pushNamed(context, 'settings')),
            _drawerItem(Icons.refresh, 'refresh',
                () async => await _fetchDataBasedOnLanguage()),
            _drawerItem(Icons.logout, 'exit', () => exit(0)),
          ],
        ),
      ),
      body: const HomeScreen(),
    );
  }

  ListTile _drawerItem(
      IconData icon, String translationKey, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(LocalizationService().translate(translationKey)),
      onTap: onTap,
    );
  }
}
