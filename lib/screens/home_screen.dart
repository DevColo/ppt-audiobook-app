import 'package:flutter/material.dart';
import 'package:precious/providers/categories_provider.dart';
import 'package:precious/screens/audio_books_screen.dart';
import 'package:precious/screens/audio_screen.dart';
import 'package:precious/screens/categories_screen.dart';
import 'package:precious/screens/category_screen.dart';
import 'package:precious/screens/semons_screen.dart';
import 'package:precious/screens/settings_screen.dart';
import 'package:precious/screens/video_collection_screen.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/utils/config.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Simulate data fetching and update the loading state
  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
      backgroundColor: Config.greyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 1.0,
          horizontal: 10.0,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: 6, // Define the number of items
                itemBuilder: (context, index) {
                  // Return widgets based on index
                  switch (index) {
                    case 0:
                      return pastorCard();
                    case 1:
                      return booksCard();
                    case 2:
                      return bibleCard();
                    case 3:
                      return charityCard();
                    case 4:
                      return getInTouchCard();
                    case 5:
                      return donationCard();
                    default:
                      return const SizedBox.shrink(); // Just in case
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget pastorCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SermonsScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.church_rounded,
                  size: 25,
                  color: Config.darkColor,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                LocalizationService().translate('pastors'),
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Config.primaryColor, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget booksCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AudioBooksScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.headset,
                  size: 25,
                  color: Config.darkColor,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                LocalizationService().translate('audioBooks'),
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Config.primaryColor, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget bibleCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AudioBooksScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.book,
                  size: 25,
                  color: Config.darkColor,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                LocalizationService().translate('bible'),
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Config.primaryColor, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget donationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AudioBooksScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.support,
                  size: 25,
                  color: Config.darkColor,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                LocalizationService().translate('pastors'),
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Config.primaryColor, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget charityCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AudioBooksScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_center,
                  size: 25,
                  color: Config.darkColor,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                LocalizationService().translate('charity'),
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Config.primaryColor, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget getInTouchCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AudioBooksScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.contact_page,
                  size: 25,
                  color: Config.darkColor,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                LocalizationService().translate('getInTouch'),
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Config.primaryColor, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
