import 'package:flutter/material.dart';
import 'package:precious/providers/bible_provider.dart';
import 'package:precious/screens/bible_books_screen.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:precious/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Simulate data fetching and update the loading state
  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));

    // Mark loading as complete
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final pastors = Provider.of<BibleProvider>(context).testaments;

    return Scaffold(
      backgroundColor: Config.greyColor,
      body: isLoading
          ? buildSkeletonScreen()
          : pastors.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 1.0,
                    horizontal: 10.0,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 5.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              LocalizationService().translate('bible'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Montserrat-SemiBold',
                                color: Config.darkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: pastors.length,
                          itemBuilder: (context, index) {
                            final pastor = pastors[index];
                            return testamentCard(
                              pastor['id'],
                              pastor['title'],
                              pastor['pdf_link'],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const Text(''),
    );
  }

  Widget buildSkeletonScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Make the content scrollable
        child: Column(
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget testamentCard(int id, String title, String pdf_link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to the AudioScreen when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BibleBooksScreen(
                testament: id,
                title: title,
                pdfUrl: pdf_link,
              ),
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
                child: const Icon(Icons.book),
              ),
              const SizedBox(width: 15),
              Text(
                title,
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
