import 'package:flutter/material.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/providers/audio_books_provider.dart';
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
    }
    await LocalizationService().loadLanguage(languageCode);
    await _fetchDataBasedOnLanguage();
  }

  Future<void> _fetchDataBasedOnLanguage() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.getMostReadBooks();
    await appProvider.getNewReleasedBooks();

    final sermonsProvider =
        Provider.of<SermonsProvider>(context, listen: false);
    await sermonsProvider.getPastors();

    final audioProvider =
        Provider.of<AudioBooksProvider>(context, listen: false);
    await audioProvider.getAudioBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Space between start and end icons
          children: [
            // Search Icon at Start
            IconButton(
              icon: const Icon(Icons.search, size: 24.0),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),

            // Spacer to push the language dropdown to the end
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: Image.asset(
                  languages.firstWhere(
                      (lang) => lang['language'] == selectedLanguage)['flag']!,
                  width: 25,
                  height: 25,
                ),
                focusColor: Config.whiteColor,
                dropdownColor: Config.whiteColor,
                iconDisabledColor: Config.whiteColor,
                iconEnabledColor: Config.whiteColor,
                elevation: 0,
                items: languages.map((language) {
                  return DropdownMenuItem<String>(
                    alignment: AlignmentDirectional.centerStart,
                    value: language['language'],
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          language['flag']!,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          language['code']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Config.darkColor,
                            fontFamily: 'Montserrat-SemiBold',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) async {
                  setState(() {
                    selectedLanguage = newValue!;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('selectedLanguage', selectedLanguage);

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
                  }
                  await LocalizationService().loadLanguage(languageCode);

                  // Fetch data based on the selected language
                  await _fetchDataBasedOnLanguage();

                  // Rebuild the current state to reflect the language change
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        backgroundColor: Config.whiteColor,
        surfaceTintColor: Config.whiteColor,
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
          SettingsScreen(),
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
            elevation: 5.0,
            selectedFontSize: 10,
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
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: LocalizationService().translate('settings'),
                backgroundColor: Config.whiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
