import 'package:flutter/material.dart';
import 'package:precious/providers/categories_provider.dart';
import 'package:precious/screens/audio_screen.dart';
import 'package:precious/screens/category_screen.dart';
import 'package:precious/screens/semons_screen.dart';
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
    //final mostReadBooks = Provider.of<AppProvider>(context).mostReadBooks;
    final preachers = Provider.of<AppProvider>(context).preachers;
    final newReleasedBooks = Provider.of<AppProvider>(context).newReleasedBooks;
    final categories = Provider.of<CategoriesProvider>(context).categories;

    return Scaffold(
      backgroundColor: Config.greyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 1.0,
          horizontal: 10.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService().translate('categories'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat-SemiBold',
                        color: Config.darkColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: .0),
              SizedBox(
                height: 40,
                child: isLoading
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5, // Placeholder count
                        itemBuilder: (context, index) => shimmerBookCategory(),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return bookCategory(
                              category['title'], category['id']);
                        },
                      ),
              ),
              const SizedBox(height: 15.0),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       Text(
              //         LocalizationService().translate('mostReadBooks'),
              //         style: const TextStyle(
              //           fontSize: 14,
              //           fontFamily: 'Montserrat-SemiBold',
              //           color: Config.darkColor,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 5.0),
              // SizedBox(
              //   height: 135,
              //   child: isLoading
              //       ? ListView.builder(
              //           scrollDirection: Axis.horizontal,
              //           itemCount: 5, // Placeholder count
              //           itemBuilder: (context, index) =>
              //               shimmerMostReadBookCard(),
              //         )
              //       : ListView.builder(
              //           scrollDirection: Axis.horizontal,
              //           itemCount: mostReadBooks.length,
              //           itemBuilder: (context, index) {
              //             final book = mostReadBooks[index];
              //             return MostReadBookCard(
              //               book['id'],
              //               book['title'],
              //               book['description'],
              //               book['author'],
              //               book['image_link'],
              //               book['pdf_link'],
              //             );
              //           },
              //         ),
              // ),
              // const SizedBox(height: 15.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService().translate('pastors'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat-SemiBold',
                        color: Config.darkColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3.0),
              SizedBox(
                height: 98.0,
                child: isLoading
                    ? shimmerPreachersCard()
                    : Container(
                        decoration: BoxDecoration(
                          color: Config.whiteColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8.0,
                        ),
                        child: preachers.isNotEmpty
                            ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: preachers.length,
                                itemBuilder: (context, index) {
                                  final preacher = preachers[index];
                                  return Preachers(
                                    preacher['id'],
                                    _trimFullname(preacher['fullname']),
                                    preacher['bio'] ?? '',
                                    preacher['image_link'],
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                    LocalizationService().translate('noData')),
                              ),
                      ),
              ),
              const SizedBox(height: 20.0),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocalizationService().translate('newReleasedBooks'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Montserrat-SemiBold',
                          color: Config.darkColor,
                        ),
                      ),
                      Text(
                        LocalizationService().translate('seeAll'),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 153, 254),
                          fontFamily: 'Montserrat-SemiBold',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  isLoading
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5, // Placeholder count
                          itemBuilder: (context, index) =>
                              shimmerNewReleasedBook(),
                        )
                      : newReleasedBooks.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: newReleasedBooks.length,
                              itemBuilder: (context, index) {
                                final book = newReleasedBooks[index];
                                return newReleasedBook(
                                  book['id'],
                                  book['title'],
                                  book['description'],
                                  book['author'],
                                  book['image_link'],
                                  book['pdf_link'],
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                  LocalizationService().translate('noData')),
                            ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bookCategory(String label, int id) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(
                categoryID: id,
                title: label,
              ),
            ),
          );
        },
        child: Chip(
          label: Text(LocalizationService().translate(label)),
          backgroundColor: Config.whiteColor,
          labelStyle: const TextStyle(
            color: Config.darkColor,
            fontFamily: 'Montserrat-SemiBold',
            fontSize: 10.0,
          ),
          elevation: 1.0,
          shadowColor: const Color.fromARGB(0, 235, 235, 235),
          labelPadding: const EdgeInsets.all(0),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Preachers(int id, String fullname, String bio, String imageLink) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                  imageUrl: imageLink),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  imageLink,
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
            SizedBox(
              width: 55.0,
              child: Text(
                fullname,
                style: const TextStyle(
                  color: Config.darkColor,
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 8.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget MostReadBookCard(int id, String title, String description,
      String author, String imageLink, String pdfLink) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                imageUrl: imageLink,
                description: description,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Config.whiteColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(imageLink),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget newReleasedBook(int id, String title, String description,
      String author, String imageLink, String pdfLink) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                imageUrl: imageLink,
                description: description,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Config.whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              const EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 8.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageLink),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 170.0,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    author,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 99, 99, 99),
                      fontFamily: 'Montserrat-SemiBold',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Config.primaryColor,
                size: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget shimmerBookCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Chip(
          label: Container(
            width: 50,
            height: 12,
            color: Colors.grey[300],
          ),
          backgroundColor: Colors.grey[300],
        ),
      ),
    );
  }

  // Widget shimmerMostReadBookCard() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 5.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Shimmer.fromColors(
  //           baseColor: Colors.grey[300]!,
  //           highlightColor: Colors.grey[100]!,
  //           child: Container(
  //             width: 80,
  //             height: 100,
  //             decoration: BoxDecoration(
  //               color: Colors.grey[300],
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget shimmerPreachersCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
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
        ],
      ),
    );
  }

  Widget shimmerNewReleasedBook() {
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
}

// Helper method to process fullname
String _trimFullname(String fullname) {
  // Split the fullname into words
  final words = fullname.split(' ');

  // If more than two words, keep only the first two
  if (words.length > 2) {
    return '${words[0]} ${words[1]}';
  }

  // Otherwise, return the fullname as is
  return fullname;
}
