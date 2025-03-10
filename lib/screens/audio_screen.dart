import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:precious/screens/pdf_book_view.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:http/http.dart' as http;
import 'package:precious/screens/chapter_audio_screen.dart';

class AudioScreen extends StatefulWidget {
  final int bookID;
  final String title;
  final String description;
  final String author;
  final String imageUrl;
  final String pdfUrl;

  const AudioScreen({
    super.key,
    required this.bookID,
    required this.title,
    required this.description,
    required this.author,
    required this.imageUrl,
    required this.pdfUrl,
  });

  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  String? currentPlayingAudioUrl;
  int? currentPlayingChapter;
  bool isPlayingAll = false;
  int? currentIndex;
  double sliderValue = 0.0;
  bool isLoading = true;
  bool isAudioLoading = true;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    fetchChapters();
    _loadData();
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
        sliderValue = position.inMilliseconds.toDouble();
      });
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (isPlayingAll && currentIndex != null) {
        _playNextChapter();
      }
    });
  }

  // Simulate data fetching and update the loading state
  Future<void> _loadData() async {
    // Wait for data fetching (simulated)
    // await Future.delayed(const Duration(seconds: 1));

    // // Mark loading as complete
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchChapters() async {
    try {
      final audioBooksProvider =
          Provider.of<AudioBooksProvider>(context, listen: false);
      await audioBooksProvider.getBooks(context, widget.bookID);
    } catch (e) {
      debugPrint("Error fetching chapters: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading chapters: $e')),
      );
    }
  }

  void openChapter(int index, List<dynamic> audioChapters) {
    if (index >= 0 && index < audioChapters.length) {
      final chapter = audioChapters[index];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterAudioScreen(
            bookID: widget.bookID,
            bookTitle: widget.title,
            chapterName: 'Chapter ${chapter['chapter']}',
            audioUrl: chapter['audio_link'],
            imageUrl: widget.imageUrl,
            chapterIndex: index,
            onNavigateToChapter: (int nextIndex) {
              // This function handles navigation between chapters
              Navigator.pop(context);
              if (nextIndex >= 0 && nextIndex < audioChapters.length) {
                openChapter(nextIndex, audioChapters);
              }
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter not available')),
      );
    }
  }

  void openBook() {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PDFBookView(title: widget.title, pdfUrl: widget.pdfUrl),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Couldn't open the book, check your internet connections and try again."),
        ),
      );
    }
  }

  Future<void> togglePlayChapter(String url, int chapterIndex) async {
    // Set loading state for this specific chapter
    setState(() {
      currentPlayingChapter = chapterIndex;
      isAudioLoading = true;
    });

    try {
      if (isPlaying && currentPlayingAudioUrl == url) {
        await _audioPlayer.pause();
        setState(() {
          isPlaying = false;
          currentPlayingChapter = null;
          isAudioLoading = false;
        });
      } else {
        // If a different chapter is requested, stop the current one first
        if (currentPlayingAudioUrl != null && currentPlayingAudioUrl != url) {
          await _audioPlayer.stop();
        }

        await _audioPlayer.play(UrlSource(url));
        setState(() {
          isPlaying = true;
          currentPlayingAudioUrl = url;
          currentPlayingChapter = chapterIndex;
          isAudioLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error playing chapter: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing chapter: $e')),
      );
      setState(() {
        currentPlayingChapter = null;
        isAudioLoading = false;
      });
    }
  }

  Future<void> _playNextChapter() async {
    final audioChapters =
        Provider.of<AudioBooksProvider>(context, listen: false).books;
    if (currentIndex != null && currentIndex! + 1 < audioChapters.length) {
      final nextIndex = currentIndex! + 1;
      final nextChapter = audioChapters[nextIndex];
      await togglePlayChapter(nextChapter['audio_link'], nextIndex);
      setState(() {
        currentIndex = nextIndex;
      });
    }
  }

  Future<void> _playAllChapters() async {
    final audioChapters =
        Provider.of<AudioBooksProvider>(context, listen: false).books;
    if (audioChapters.isNotEmpty) {
      setState(() {
        isPlayingAll = true;
        currentIndex = 0;
      });
      await togglePlayChapter(audioChapters[0]['audio_link'], 0);
    }
  }

  Future<void> downloadAudio(String url, String chapter, int index) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await request.send();

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filename = '${widget.title}_Chapter_$chapter.mp3';
      final file = File('${directory.path}/$filename');

      // Track download progress
      final contentLength = response.contentLength ?? 0;
      int receivedLength = 0;
      final sink = file.openWrite();

      // Emit progress updates
      final progressStream = response.stream.asBroadcastStream();
      progressStream.listen(
        (List<int> chunk) {
          receivedLength += chunk.length;
          final progress = (receivedLength / contentLength) * 100;
          Provider.of<AudioBooksProvider>(context, listen: false)
              .updateDownloadProgress(index, progress);
          sink.add(chunk);
        },
        onDone: () async {
          await sink.close();
          Provider.of<AudioBooksProvider>(context, listen: false)
              .markDownloadComplete(index, file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$filename downloaded successfully!')),
          );
        },
        onError: (error) {
          sink.close();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading file: $error')),
          );
        },
      );
    } else {
      throw Exception('Failed to download file');
    }
  }

  void shareAudio(String url) {
    Share.share(url);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  bool _isExpanded = false;
  String _getDisplayText(String text) {
    final words = text.split(' ');
    if (words.length <= 20 || _isExpanded) {
      return text;
    }
    return '${words.take(20).join(' ')}...';
  }

  @override
  Widget build(BuildContext context) {
    final audioChapters = Provider.of<AudioBooksProvider>(context).books;

    return Scaffold(
      backgroundColor: Config.greyColor,
      appBar: AppBar(
        backgroundColor: Config.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Config.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.book,
              color: Config.primaryColor,
            ),
            onPressed: openBook,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Scrollable Book Info and Chapter List
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Information Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Image
                      Container(
                        width: 100,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(widget.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title, Author, and Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Config.darkColor,
                                fontFamily: 'Montserrat-SemiBold',
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.author,
                              style: const TextStyle(
                                color: Config.darkColor,
                                fontFamily: 'Montserrat-SemiBold',
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getDisplayText(widget.description),
                              style: const TextStyle(
                                color: Config.darkColor,
                                fontFamily: 'Montserrat-SemiBold',
                                fontSize: 12,
                              ),
                            ),
                            if (widget.description.split(' ').length > 20)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: Text(
                                  _isExpanded ? 'Read Less' : 'Read More',
                                  style: const TextStyle(
                                    color: Config.primaryColor,
                                    fontFamily: 'Montserrat-SemiBold',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Chapter List
                  isLoading
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5, // Placeholder count
                          itemBuilder: (context, index) => shimmerAudioBook(),
                        )
                      : buildAudioChapterList(audioChapters),
                ],
              )),
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

  Widget audioChapter(String chapter, String audioLink, int index) {
    final isDownloadComplete =
        Provider.of<AudioBooksProvider>(context).isDownloadComplete(index);

    return GestureDetector(
      onTap: () {
        final audioChapters =
            Provider.of<AudioBooksProvider>(context, listen: false).books;
        openChapter(index, audioChapters);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Config.whiteColor,
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(
          //   width: 1.5,
          //   color: Config.darkColor,
          // ),
        ),
        child: Row(
          children: [
            // Small Chapter Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Config.primaryColor.withOpacity(0.2),
              ),
              child: const Center(
                child: Icon(
                  Icons.headphones,
                  color: Config.primaryColor,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(width: 15),

            // Chapter Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter $chapter',
                    style: const TextStyle(
                      color: Config.darkColor,
                      fontFamily: 'Montserrat-SemiBold',
                      fontSize: 14,
                    ),
                  ),
                  if (isDownloadComplete)
                    const Text(
                      "Downloaded",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontFamily: 'Montserrat-Regular',
                      ),
                    ),
                ],
              ),
            ),

            // Forward Icon
            const Icon(
              Icons.arrow_forward_ios,
              color: Config.darkColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAudioChapterList(List<dynamic> audioChapters) {
    if (audioChapters.isEmpty) {
      return const Center(
        child: Text(
          'No Audio Chapters',
          style: TextStyle(
            color: Config.darkColor,
            fontFamily: 'Montserrat-Regular',
            fontSize: 12,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: audioChapters.length,
      itemBuilder: (context, index) {
        final chapter = audioChapters[index];
        return audioChapter(
          chapter['chapter'],
          chapter['audio_link'],
          index,
        );
      },
    );
  }
}
