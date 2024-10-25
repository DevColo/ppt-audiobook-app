import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:precious/screens/audio_screen.dart';
import 'package:provider/provider.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioBooksScreen extends StatefulWidget {
  const AudioBooksScreen({super.key});

  @override
  State<AudioBooksScreen> createState() => _AudioBooksScreenState();
}

class _AudioBooksScreenState extends State<AudioBooksScreen> {
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
    final audioBook =
        // [
        //   {
        //     "id": 4,
        //     "title": "The Act of the Apostles",
        //     "audio_link":
        //         "https://media2.egwwritings.org/mp3/127/0002_eng_m_preface_127_7.mp3",
        //     "audio_image_link": "https://media2.egwwritings.org/covers/84_r.jpg"
        //   },
        //   {
        //     "id": 5,
        //     "title": "Patriarchs and Prophets",
        //     "audio_link":
        //         "https://media2.egwwritings.org/mp3/84/0001_eng_m_patriarchs_and_prophets_84_4.mp3",
        //     "audio_image_link": "https://media2.egwwritings.org/covers/127_r.jpg"
        //   }
        // ];
        Provider.of<AppProvider>(context).audios;
    return Scaffold(
      backgroundColor: Config.greyColor,
      //if audios is empty, then return progress indicator
      body: audioBook.isNotEmpty
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
                      //WelcomeCard(message: audioBook),
                      const SizedBox(height: 15.0),
                      const SizedBox(height: 5),
                      Column(
                        children: [
                          Center(
                            child: ResponsiveGrid(audios: audioBook),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : Padding(
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
                          'Audio Books', // The heading text
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat-SemiBold',
                            color: Config.darkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // New Releases Section - Vertically scrollable inside the remaining screen space
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 2.0),
                        Expanded(
                          child: ListView(
                            children: [
                              book('Can’t Stop Thinking', 'Nancy Colier',
                                  '45 Mins'),
                              book('Stay Wild My Child', 'Cynthia Lewis',
                                  '60 Mins'),
                              book('The Midnight Library', 'Matt Haig',
                                  '100 Mins'),
                              book('Atomic Habits', 'James Clear', '120 Mins'),
                              book('Dune', 'Frank Herbert', '250 Mins'),
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

  Widget book(String title, String author, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
    final List<dynamic> audioBook = widget.message;

    if (audioBook.isNotEmpty) {
      // Get the last item from the list
      final homeText = audioBook.last;
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
  final List<dynamic> audios;

  ResponsiveGrid({super.key, required this.audios});

  final Map<String, String> audioImages = {
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
            itemCount: audios.length,
            itemBuilder: (context, index) {
              final audio = audios[index];
              final audioName = audio['title'];
              final audioId = audio['id'];
              final audioLink = audio['audio_link'];
              final audioImage = audio['audio_image_link'] ?? logo;
              return audioCard(
                id: audioId,
                name: audioName,
                image: audioImage,
                audio: audioLink,
              );
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

class audioCard extends StatelessWidget {
  final int id;
  final String name;
  final String image;
  final String audio;

  const audioCard({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.audio,
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
                  image: NetworkImage(image),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AudioScreen(
                          audio: audio,
                          audioImage: image,
                          audioId: id,
                          audioName: name,
                        )),
              );
            },
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
