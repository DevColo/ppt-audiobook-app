import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final subjectData = Provider.of<AppProvider>(context).subjects;
    // final subjectData = [
    //   {"id": 1, "name": "English", "questionCount": 51},
    //   {"id": 5, "name": "Mathematics", "questionCount": 1},
    //   {"id": 6, "name": "Chemistry", "questionCount": 0},
    //   {"id": 57, "name": "Biology", "questionCount": 0},
    //   {"id": 58, "name": "Literature", "questionCount": 0},
    //   {
    //     "title": "Welcome",
    //     "msg": "Explore past WASSCE questions and answers in various subjects."
    //   }
    // ];
    return Scaffold(
      backgroundColor: Config.greyColor,
      //if subjects is empty, then return progress indicator
      body: subjectData.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                bottom: 5.0,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 15.0),
                      WelcomeCard(message: subjectData),
                      const SizedBox(height: 15.0),
                      const Text(
                        'Subjects',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat-SemiBold',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Column(
                        children: [
                          Center(
                            child: ResponsiveGrid(subjects: subjectData),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          :
          // const Center(
          //     child: CircularProgressIndicator(),
          //   ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Heading for Categories
                  // Heading for Categories (aligned to the right)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // Align text to the right
                      children: [
                        Text(
                          'Categories', // The heading text
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat-SemiBold',
                            color: Config.darkColor,
                          ),
                        ),
                      ],
                    ),
                  ), // Spacing between heading and list

                  // Horizontal ListView for Categories
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        categoryChip('Leadership'),
                        categoryChip('Education'),
                        categoryChip('Church History'),
                        categoryChip('Mystery'),
                        categoryChip('Parenting'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // New Releases Section - Vertically scrollable inside the remaining screen space
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            padding: const EdgeInsets.all(10),
                            children: [
                              categoryCard('Leadership', Icons.mic, Colors.teal,
                                  Colors.greenAccent),
                              categoryCard('Loyalty', Icons.face, Colors.red,
                                  Colors.orangeAccent),
                              categoryCard('Youth', Icons.shelves, Colors.blue,
                                  Colors.blueAccent),
                              categoryCard('Education', Icons.book, Colors.pink,
                                  Colors.pinkAccent),
                              categoryCard('Church', Icons.church,
                                  Colors.purple, Colors.deepPurpleAccent),
                              categoryCard('love', Icons.heat_pump_rounded,
                                  Colors.cyan, Colors.cyanAccent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget categoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(
          color: Config.primaryColor,
          fontFamily: 'Montserrat-SemiBold',
          fontSize: 12.0,
        ),
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
        elevation: 0,
      ),
    );
  }

  Widget continueListeningCard(String title, String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // White background color for the card
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 120,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(assetPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Config.darkColor, // Adjust text color
              fontFamily: 'Montserrat-SemiBold',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget categoryCard(
      String categoryName, IconData icon, Color startColor, Color endColor) {
    return Container(
      width: 100, // Set width to control size of card
      height: 100, // Set height to make it square
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: Icon(
              icon,
              size: 25, // Adjust size of the icon
              color: Colors.white, // Ensures the icon is white
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            categoryName,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat-SemiBold',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// welcome card
class WelcomeCard extends StatefulWidget {
  final List<dynamic> message;

  const WelcomeCard({super.key, required this.message});

  @override
  State<WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<WelcomeCard> {
  String title = "";
  String msg = "";

  @override
  void initState() {
    super.initState();
    // Assuming widget.message is a List<dynamic>
    final List<dynamic> subjectData = widget.message;

    if (subjectData.isNotEmpty) {
      // Get the last item from the list
      final homeText = subjectData.last;
      if (homeText != null && homeText is Map<String, dynamic>) {
        title = homeText['title'] ?? 'Hey,';
        msg = homeText['msg'] ?? 'Welcome to Refresher Study and Pass';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 4, 184, 255), Config.primaryColor],
          begin: Alignment.topRight,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Card(
        elevation: 0.0,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10.0),
        // ),
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5.0),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Config.whiteColor,
                        fontFamily: 'Montserrat-SemiBold',
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      msg,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Config.whiteColor,
                        fontFamily: 'Raleway-Regular',
                      ),
                    ),
                    const SizedBox(height: 5.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<dynamic> subjects;

  ResponsiveGrid({super.key, required this.subjects});

  final Map<String, String> subjectImages = {
    "Biology": engImg,
    "English": engImg,
    "Mathematics": engImg,
    "Geography": engImg,
    "Chemistry": engImg,
    "Physics": engImg,
    "Literature": engImg,
    "History": engImg,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = getCrossAxisCount(constraints.maxWidth);
        return GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Prevent GridView from scrolling independently
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.75,
            ),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              if (subjects[index]['id'] != null) {
                final subject = subjects[index];
                final subjectName = subject['name'];
                final subjectId = subject['id'];
                final questionCount = subject['questionCount'];
                final subjectImage = subjectImages[subjectName] ?? logo;
                return SubjectCard(
                    id: subjectId,
                    name: subjectName,
                    image: subjectImage,
                    questionCount: questionCount);
              }
              ;
            });
      },
    );
  }

  int getCrossAxisCount(double width) {
    if (width >= 1200) return 8;
    if (width >= 992) return 6;
    if (width >= 768) return 4;
    if (width >= 576) return 3;
    if (width >= 300) return 2;
    return 1;
  }
}

class SubjectCard extends StatelessWidget {
  final int id;
  final String name;
  final String image;
  final int questionCount;

  const SubjectCard({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15.0),
          Expanded(
            flex: 2,
            child: Container(
              width: 60.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$questionCount",
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontFamily: 'Raleway-Regular',
                    ),
                  ),
                  const Text(
                    'Q&A',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontFamily: 'Raleway-Regular',
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              decoration: const BoxDecoration(
                color: Config.greyColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              margin: const EdgeInsets.only(
                top: 8.0,
                bottom: 15.0,
                left: 10.0,
                right: 10.0,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontFamily: 'Raleway-Regular',
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 18.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
