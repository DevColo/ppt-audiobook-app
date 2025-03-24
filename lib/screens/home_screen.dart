import 'package:flutter/material.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/screens/audio_screen.dart';
import 'package:precious/screens/bible_sermons_screen.dart';
import 'package:precious/screens/bible_verses_screen.dart';
import 'package:precious/screens/egw_audio_books_screen.dart';
import 'package:precious/screens/video_collection_screen.dart';
import 'package:precious/screens/video_screen.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  final String selectedLanguage;

  const HomeScreen({Key? key, required this.selectedLanguage})
      : super(key: key);

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
    final preachers = Provider.of<AppProvider>(context).preachers;
    //final newReleasedBooks = Provider.of<AppProvider>(context).newReleasedBooks;
    //final categories = Provider.of<CategoriesProvider>(context).categories;
    final videos = Provider.of<SermonsProvider>(context).youtube;

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
              const SizedBox(height: 10.0),
              // Banner
              if (widget.selectedLanguage != 'Kinyarwanda')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Image(
                    image: const AssetImage(banner),
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.noRepeat,
                    width: Config.screenWidth,
                  ),
                ),
              if (widget.selectedLanguage != 'Kinyarwanda')
                const SizedBox(height: 10.0),
              // Preaher Header
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
                height: 122.0,
                child: isLoading
                    ? shimmerPreachersCard()
                    : Container(
                        decoration: BoxDecoration(
                          color: Config.whiteColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.only(
                          top: 12.0,
                          bottom: 2.0,
                          left: 8.0,
                          right: 8.0,
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
                                    preacher['fullname'],
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
              const SizedBox(height: 15.0),
              if (mostReadBooks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationService().translate('mostReadBooks'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Montserrat-SemiBold',
                          color: Config.darkColor,
                        ),
                      ),
                    ],
                  ),
                ),
              if (mostReadBooks.isNotEmpty) const SizedBox(height: 5.0),
              if (mostReadBooks.isNotEmpty)
                SizedBox(
                  height: 120,
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
              // French Section
              if (widget.selectedLanguage == 'French')
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Versets',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Montserrat-SemiBold',
                          color: Config.darkColor,
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.selectedLanguage == 'French')
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BibleVersesScreen(),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 80,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(rwBible),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color: Config.whiteColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                  right: 8.0,
                                  left: 8.0,
                                  top: 0.0,
                                  bottom: 5.0,
                                ),
                                child: Text(
                                  'Versets \nBibliques',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Config.darkColor,
                                    fontFamily: 'Montserrat-SemiBold',
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EGWAudioBooksScreen(),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 80,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(book),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color: Config.whiteColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                  right: 8.0,
                                  left: 8.0,
                                  top: 0.0,
                                  bottom: 5.0,
                                ),
                                child: Text(
                                  "lignes tirées des livres d'Ellen",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Config.darkColor,
                                    fontFamily: 'Montserrat-SemiBold',
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Kinyarwanda Section
              if (widget.selectedLanguage == 'Kinyarwanda')
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Imirongo ivuga ku',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Montserrat-SemiBold',
                          color: Config.darkColor,
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.selectedLanguage == 'Kinyarwanda')
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BibleSermonsScreen(),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 80,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(preciousLogo),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color: Config.whiteColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                  right: 8.0,
                                  left: 8.0,
                                  top: 0.0,
                                  bottom: 5.0,
                                ),
                                child: Text(
                                  'Byigisho \n',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Config.darkColor,
                                    fontFamily: 'Montserrat-SemiBold',
                                    fontSize: 11.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EGWAudioBooksScreen(),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 80,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(book),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color: Config.whiteColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                  right: 8.0,
                                  left: 8.0,
                                  top: 0.0,
                                  bottom: 5.0,
                                ),
                                child: Text(
                                  'Bitabo by \nEllen G White',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Config.darkColor,
                                    fontFamily: 'Montserrat-SemiBold',
                                    fontSize: 11.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BibleVersesScreen(),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 80,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(rwBible),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color: Config.whiteColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                  right: 8.0,
                                  left: 8.0,
                                  top: 0.0,
                                  bottom: 5.0,
                                ),
                                child: Text(
                                  'Bibiliya \n',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Config.darkColor,
                                    fontFamily: 'Montserrat-SemiBold',
                                    fontSize: 11.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15.0),
              Column(
                children: [
                  if (videos.isNotEmpty)
                    const Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Ibishya',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat-SemiBold',
                              color: Config.darkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 2.0),
                  isLoading
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5, // Placeholder count
                          itemBuilder: (context, index) => shimmerBibleVerses(),
                        )
                      : videos.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: videos.length,
                              itemBuilder: (context, index) {
                                final book = videos[index];
                                return youtubeVideo(
                                  book['id'],
                                  book['title'],
                                  book['video_link'],
                                );
                              },
                            )
                          : const Center(
                              child: Text(''),
                            ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Preachers(int id, String trimmedFullName, String fullname, String bio,
      String imageLink) {
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
              width: 80.0,
              height: 90.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
              width: 80.0,
              child: Text(
                trimmedFullName,
                style: const TextStyle(
                  color: Config.darkColor,
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 10.0,
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
                Icons.play_circle_fill,
                color: Config.primaryColor,
                size: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bible Verses
  Widget youtubeVideo(int playListID, String title, String videoLink) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                title: title,
                videoLink: videoLink,
                playListID: playListID,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Config.whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.only(
              left: 10.0, top: 10.0, bottom: 10.0, right: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 20.0),
                  SizedBox(
                    width: 180.0,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.play_circle_rounded,
                color: Config.primaryColor,
                size: 16.0,
              ),
            ],
          ),
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

  // shimmer Bible Verses
  Widget shimmerBibleVerses() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
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
  if (words.length > 1) {
    return '${words[1]}';
  }

  // Otherwise, return the fullname as is
  return fullname;
}
