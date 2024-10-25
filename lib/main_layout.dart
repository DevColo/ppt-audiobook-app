import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:precious/screens/audio_books_screen.dart';
import 'package:precious/screens/categories_screen.dart';
import 'package:precious/screens/home_screen.dart';
import 'package:precious/screens/semons_screen.dart';
import 'package:precious/screens/video_collection_screen.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPage = 0;
  final PageController _pageController = PageController();
  Map<String, dynamic> user = {};

  // Global key for the scaffold to control the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Default selected language
  String selectedLanguage = 'English';

  // List of language options
  final List<Map<String, String>> languages = [
    {'language': 'English', 'flag': 'assets/images/eng.png'},
    {'language': 'French', 'flag': 'assets/images/fr.png'},
    {'language': 'Kinyarwanda', 'flag': 'assets/images/rw.png'},
    {'language': 'Swahili', 'flag': 'assets/images/sw.png'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPage();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      setState(() {
        user = Map<String, dynamic>.from(jsonDecode(userData));
      });
    } else {
      Navigator.pushNamed(context, 'login');
    }
  }

  void _loadPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentPage = prefs.getInt('currentPage') ?? 0;
    });
  }

  void _savePage(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPage', page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          //mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Search Input
            Expanded(
              child: Material(
                //elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  height: 40.0,
                  width: 300,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_outlined,
                        color: Colors.grey,
                        size: 18.0,
                      ),
                      hintText: 'Search by title, author, or category',
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                      fillColor: Color.fromARGB(255, 254, 254, 254),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(50.0)), // Add border radius
                        borderSide: BorderSide(
                          color: Colors.transparent, // Transparent border
                          width: 0.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(50.0)), // Add border radius
                        borderSide: BorderSide(
                          color: Colors.transparent, // Transparent border
                          width: 0.0,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                    ),
                    cursorColor: Colors.grey,
                  ),
                ),
              ),
            ),

            // Language Switcher
            DropdownButtonHideUnderline(
              child: Container(
                decoration: const BoxDecoration(
                  color: Config.greyColor,
                ), // Optional padding
                child: DropdownButton<String>(
                  icon: Image.asset(
                    languages.firstWhere((lang) =>
                        lang['language'] == selectedLanguage)['flag']!,
                    width: 30,
                    height: 30,
                  ),
                  focusColor: Config.greyColor,
                  items: languages.map((language) {
                    return DropdownMenuItem<String>(
                      value: language['language'],
                      child: Row(
                        children: [
                          Image.asset(
                            language['flag']!,
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(language['language']!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedLanguage = newValue!;
                    });
                    // Logic to change language can be added here
                  },
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Config.greyColor,
        surfaceTintColor: Config.greyColor,
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
          HomeScreen(),
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
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
                backgroundColor: Config.whiteColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_sharp),
                label: 'Categories',
                backgroundColor: Config.whiteColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_collection_outlined),
                label: 'Sermons',
                backgroundColor: Config.whiteColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.audiotrack),
                label: 'Audio Book',
                backgroundColor: Config.whiteColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
                backgroundColor: Config.whiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
