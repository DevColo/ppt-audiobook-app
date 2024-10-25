import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                            fontSize: 14,
                            fontFamily: 'Montserrat-SemiBold',
                            color: Config.darkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Categories Section
                  const SizedBox(
                      height: 2.0), // Spacing between heading and list

                  // Horizontal ListView for Categories
                  SizedBox(
                    height: 40,
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
                  const SizedBox(height: 15.0),
                  // Continue Listening Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // Align text to the right
                      children: [
                        Text(
                          'Ellen G. White Books', // The heading text
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat-SemiBold',
                            color: Config.darkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  SizedBox(
                    height: 135,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        continueListeningCard(
                            'Every Youth', 'assets/images/7_r-1.jpg'),
                        continueListeningCard(
                            'The Last Man', 'assets/images/84_r.jpg'),
                        continueListeningCard(
                            'The Alchemist', 'assets/images/127_r.jpg'),
                        continueListeningCard(
                            'The Last Man', 'assets/images/84_r.jpg'),
                        continueListeningCard(
                            'The Alchemist', 'assets/images/127_r.jpg'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // New Releases Section - Vertically scrollable inside the remaining screen space
                  Expanded(
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'New Releases', // The heading text
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Montserrat-SemiBold',
                                color: Config.darkColor,
                              ),
                            ),
                            Text(
                              'See all',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 153, 254),
                                fontFamily: 'Montserrat-SemiBold',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Expanded(
                          child: ListView(
                            children: [
                              newReleaseTile('Can’t Stop Thinking',
                                  'Nancy Colier', '45 Mins'),
                              newReleaseTile('Stay Wild My Child',
                                  'Cynthia Lewis', '60 Mins'),
                              newReleaseTile('The Midnight Library',
                                  'Matt Haig', '100 Mins'),
                              newReleaseTile(
                                  'Atomic Habits', 'James Clear', '120 Mins'),
                              newReleaseTile(
                                  'Dune', 'Frank Herbert', '250 Mins'),
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
        backgroundColor: Config.primaryColor,
        labelStyle: const TextStyle(
          color: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // White background color for the card
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(assetPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 47, 47, 47), // Adjust text color
              fontFamily: 'Montserrat-SemiBold',
              fontSize: 10.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget newReleaseTile(String title, String author, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Add white background color
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.only(
          left: 0,
          top: 0,
          bottom: 0,
          right: 8.0,
        ), // Padding inside the container
        child: Row(
          children: [
            Container(
              width: 60,
              height: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    10.0,
                  ),
                  bottomLeft: Radius.circular(
                    10.0,
                  ),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/127_r.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontFamily: 'Montserrat-SemiBold',
                    fontSize: 14,
                  ),
                ),
                Text(
                  author,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 99, 99, 99),
                      fontFamily: 'Montserrat-SemiBold',
                      fontSize: 11),
                ),
                Text(
                  duration,
                  style: const TextStyle(
                      color: Config.darkColorTransperant,
                      fontFamily: 'Montserrat-b',
                      fontSize: 10),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.play_circle_fill,
              color: Config.primaryColor,
              size: 25.0,
            ),
          ],
        ),
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
