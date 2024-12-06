import 'package:flutter/material.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/screens/video_collection_screen.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:precious/utils/config.dart';
import 'package:shimmer/shimmer.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
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
    final pastors = Provider.of<SermonsProvider>(context).pastors;

    return Scaffold(
      backgroundColor: Config.greyColor,
      body: isLoading
          ? buildSkeletonScreen() // Show skeleton while loading
          : pastors.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              LocalizationService().translate('pastors'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Montserrat-SemiBold',
                                color: Config.darkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: pastors.length,
                          itemBuilder: (context, index) {
                            final pastor = pastors[index];
                            return pastorCard(
                              pastor['id'],
                              pastor['fullname'],
                              pastor['bio'] ?? '',
                              pastor['image_link'],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    'No Data Found!', // Display when pastors list is empty
                  ),
                ),
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

  Widget pastorCard(int id, String fullname, String bio, String imageURL) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to the AudioScreen when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCollectionScreen(
                pastorId: id,
                pastorName: fullname,
                pastorBio: bio,
                imageUrl: imageURL,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageURL,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                fullname,
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
