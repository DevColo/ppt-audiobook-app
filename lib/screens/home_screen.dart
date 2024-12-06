import 'package:flutter/material.dart';
import 'package:precious/providers/categories_provider.dart';
import 'package:precious/screens/audio_screen.dart';
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
    final mostReadBooks = Provider.of<AppProvider>(context).mostReadBooks;
    final newReleasedBooks = Provider.of<AppProvider>(context).newReleasedBooks;
    final categories = Provider.of<CategoriesProvider>(context).categories;

    return Scaffold(
      backgroundColor: Config.greyColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService().translate('categories'),
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
                          return BookCategory(
                              category['title'], category['id']);
                        },
                      ),
              ),
              const SizedBox(height: 15.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService().translate('mostReadBooks'),
                      style: const TextStyle(
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
                child: isLoading
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5, // Placeholder count
                        itemBuilder: (context, index) =>
                            shimmerMostReadBookCard(),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: mostReadBooks.length,
                        itemBuilder: (context, index) {
                          final book = mostReadBooks[index];
                          return MostReadBookCard(
                            book['id'],
                            book['title'],
                            book['description'],
                            book['author'],
                            book['image_link'],
                            book['pdf_link'],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10.0),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocalizationService().translate('newReleasedBooks'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Montserrat-SemiBold',
                          color: Config.darkColor,
                        ),
                      ),
                      Text(
                        LocalizationService().translate('seeAll'),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 153, 254),
                          fontFamily: 'Montserrat-SemiBold',
                          fontSize: 14,
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
                      : ListView.builder(
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
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        color: Colors.white,
        height: 120,
        width: double.infinity,
      ),
    );
  }

  Widget BookCategory(String label, int id) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: GestureDetector(
        onTap: () {
          // Route to a new page with the id
          //Navigator.pushNamed(context, '/categoryDetail', arguments: id);
        },
        child: Chip(
          label: Text(LocalizationService().translate(label)),
          backgroundColor: Config.primaryColor,
          labelStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat-SemiBold',
            fontSize: 12.0,
          ),
          padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
          elevation: 0,
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
                color: Colors.white,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              const EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 8.0),
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
                    image: NetworkImage(imageLink),
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

  Widget shimmerMostReadBookCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
              Icons.play_circle_fill,
              color: Colors.grey, // Adjusted for shimmer
              size: 25.0,
            ),
          ],
        ),
      ),
    );
  }
}
