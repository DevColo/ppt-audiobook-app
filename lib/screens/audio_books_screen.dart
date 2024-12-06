import 'package:flutter/material.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/screens/audio_screen.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:precious/utils/config.dart';
import 'package:shimmer/shimmer.dart';

class AudioBooksScreen extends StatefulWidget {
  const AudioBooksScreen({super.key});

  @override
  State<AudioBooksScreen> createState() => _AudioBooksScreenState();
}

class _AudioBooksScreenState extends State<AudioBooksScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Simulate data fetching and update the loading state
  Future<void> _loadData() async {
    // Wait for data fetching (simulated)
    await Future.delayed(const Duration(seconds: 1));

    // Mark loading as complete
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final audioBooks = Provider.of<AudioBooksProvider>(context).audioBooks;
    return Scaffold(
      backgroundColor: Config.greyColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService().translate('audioBooks'),
                    style: const TextStyle(
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
              child: isLoading
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5, // Placeholder count
                      itemBuilder: (context, index) => shimmerAudioBook(),
                    )
                  : ListView.builder(
                      itemCount: audioBooks.length,
                      itemBuilder: (context, index) {
                        final audioBook = audioBooks[index];
                        return audioBookCard(
                          audioBook['id'],
                          audioBook['title'],
                          audioBook['author'],
                          audioBook['image_link'],
                          audioBook['pdf_link'],
                          audioBook['description'],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget shimmerAudioBook() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 5.0),
                Container(
                  width: 80,
                  height: 12,
                  color: Colors.grey[300],
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey, // Adjusted for shimmer
              size: 25.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget audioBookCard(int id, String title, String author, String imageUrl,
      String pdfLink, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to the AudioScreen when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioScreen(
                bookID: id,
                pdfUrl: pdfLink,
                author: author,
                title: title,
                imageUrl: imageUrl,
                description: description,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
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
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    author,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 99, 99, 99),
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Config.primaryColor,
                size: 25.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
