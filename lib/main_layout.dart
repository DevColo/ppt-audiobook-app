import 'dart:io';

import 'package:flutter/material.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/providers/categories_provider.dart';
import 'package:precious/providers/collections_provider.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/screens/audio_books_screen.dart';
import 'package:precious/screens/categories_screen.dart';
import 'package:precious/screens/home_screen.dart';
import 'package:precious/screens/search_screen.dart';
import 'package:precious/screens/semons_screen.dart';
import 'package:precious/screens/settings_screen.dart';
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

  // Global key for the scaffold to control the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Default selected language
  String selectedLanguage = 'Kinyarwanda';

  // List of language options
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
    _loadPage();
    _loadLanguage();
  }

  // Load the current page index from SharedPreferences
  void _loadPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentPage = prefs.getInt('currentPage') ?? 0;
    });
  }

  // Save the current page index to SharedPreferences
  void _savePage(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPage', page);
  }

  // Load the selected language from SharedPreferences
  Future<void> _loadLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'Kinyarwanda';
    });
    // Map language name to code
    String languageCode = 'rw';
    if (selectedLanguage == 'French') {
      languageCode = 'fr';
    } else if (selectedLanguage == 'Kinyarwanda') {
      languageCode = 'rw';
    } else if (selectedLanguage == 'Swahili') {
      languageCode = 'sw';
    } else if (selectedLanguage == 'English') {
      languageCode = 'en';
    } else if (selectedLanguage == 'Lingala') {
      languageCode = 'lg';
    } else if (selectedLanguage == 'Tshiluba') {
      languageCode = 'ts';
    }

    await LocalizationService().loadLanguage(languageCode);
    await _fetchDataBasedOnLanguage();
  }

  Future<void> _fetchDataBasedOnLanguage() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    //await appProvider.getMostReadBooks();
    await appProvider.getNewReleasedBooks();
    await appProvider.getPreachers();

    final sermonsProvider =
        Provider.of<SermonsProvider>(context, listen: false);
    await sermonsProvider.getPastors();

    final audioProvider =
        Provider.of<AudioBooksProvider>(context, listen: false);
    await audioProvider.getAudioBooks();

    final categoryProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    await categoryProvider.getAllCategories();

    final collectionsProvider =
        Provider.of<CollectionsProvider>(context, listen: false);
    await collectionsProvider.getAllCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search, size: 24.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
        backgroundColor: Config.whiteColor,
        surfaceTintColor: Config.whiteColor,
      ),

      // Navigation Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Config.primaryColor,
              ),
              child: Text(
                'Precious Present Truth Audiobook',
                style: TextStyle(
                  fontFamily: 'Montserrat-SemiBold',
                  color: Config.whiteColor,
                  fontSize: 16,
                ),
              ),
            ),
            // Navigation Items
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(LocalizationService().translate('home')),
              onTap: () {
                _pageController.jumpToPage(0);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(LocalizationService().translate('downloads')),
              onTap: () {
                _pageController.jumpToPage(1);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_collection_outlined),
              title: Text(LocalizationService().translate('myPlayList')),
              onTap: () {
                _pageController.jumpToPage(2);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title:
                  Text(LocalizationService().translate('searchBookPreacher')),
              onTap: () {
                _pageController.jumpToPage(3);
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            // Language Selection
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(LocalizationService().translate('changeLanguage')),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        LocalizationService().translate('selectLanguage'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Montserrat-SemiBold',
                          color: Config.darkColor,
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: languages.map((language) {
                            return ListTile(
                              leading: Image.asset(
                                language['flag']!,
                                width: 30,
                                height: 30,
                              ),
                              title: Text(language['language']!),
                              onTap: () async {
                                setState(() {
                                  selectedLanguage = language['language']!;
                                });

                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                    'selectedLanguage', selectedLanguage);

                                String languageCode = language['code']!;
                                await LocalizationService()
                                    .loadLanguage(languageCode);

                                // Fetch data based on the selected language
                                await _fetchDataBasedOnLanguage();

                                // Close the dialog and drawer
                                Navigator.of(context).pop();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(LocalizationService().translate('settings')),
              onTap: () {
                Navigator.pushNamed(context, 'settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(LocalizationService().translate('refresh')),
              onTap: () async {
                await _fetchDataBasedOnLanguage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(LocalizationService().translate('exit')),
              onTap: () {
                exit(0);
              },
            ),
          ],
        ),
      ),

      body: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            currentPage = value;
            _savePage(currentPage);
          });
        },
        children: const <Widget>[
          HomeScreen(),
          CategoriesScreen(),
          SermonsScreen(),
          AudioBooksScreen(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Config.greyColor,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: BottomNavigationBar(
            currentIndex: currentPage,
            onTap: (page) {
              setState(() {
                currentPage = page;
                _pageController.animateToPage(
                  page,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
                _savePage(currentPage);
              });
            },
            selectedItemColor: Config.primaryColor,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(color: Config.primaryColor),
            unselectedLabelStyle: const TextStyle(color: Colors.grey),
            backgroundColor: Config.whiteColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 5.0,
            selectedFontSize: 10.0,
            unselectedFontSize: 9.0,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_filled),
                label: LocalizationService().translate('home'),
                backgroundColor: Config.whiteColor,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.category_sharp),
                label: LocalizationService().translate('categories'),
                backgroundColor: Config.whiteColor,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.video_collection_outlined),
                label: LocalizationService().translate('sermons'),
                backgroundColor: Config.whiteColor,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.audiotrack),
                label: LocalizationService().translate('audioBooks'),
                backgroundColor: Config.whiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
