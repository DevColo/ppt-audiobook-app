import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:precious/screens/pdf_book_view.dart';
import 'package:precious/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:http/http.dart' as http;

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
    await Future.delayed(const Duration(seconds: 1));

    // Mark loading as complete
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchChapters() async {
    await Provider.of<AudioBooksProvider>(context, listen: false)
        .getBooks(context, widget.bookID);
  }

  Future<void> togglePlayChapter(String url, int chapterIndex) async {
    if (isPlaying && currentPlayingAudioUrl == url) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
        currentPlayingChapter = null;
      });
    } else {
      if (currentPlayingAudioUrl == null || currentPlayingAudioUrl != url) {
        await _audioPlayer.play(UrlSource(url));
      } else {
        await _audioPlayer.resume();
      }
      setState(() {
        isPlaying = true;
        currentPlayingAudioUrl = url;
        currentPlayingChapter = chapterIndex;
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

  Future<void> downloadAudio(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$filename downloaded successfully!'),
          ),
        );
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
        ),
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

  @override
  Widget build(BuildContext context) {
    final audioChapters = Provider.of<AudioBooksProvider>(context).books;

    return Scaffold(
      backgroundColor: Config.darkColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.book,
              color: Config.whiteColor,
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
                  children: [
                    // Book Info Section
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(widget.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Config.whiteColor,
                                fontFamily: 'Montserrat-SemiBold',
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.author,
                              style: const TextStyle(
                                color: Config.whiteColor,
                                fontFamily: 'Montserrat-Regular',
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Config.whiteColor,
                        fontFamily: 'Montserrat-Regular',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 5, // Placeholder count
                            itemBuilder: (context, index) => shimmerAudioBook(),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: audioChapters.length,
                            itemBuilder: (context, index) {
                              if (audioChapters.isEmpty) {
                                return const Center(
                                  child: Text('No Audio Chapter'),
                                );
                              } else {
                                final chapter = audioChapters[index];
                                return audioChapter(
                                  chapter['chapter'],
                                  chapter['audio_link'],
                                  index,
                                );
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),

            // Player Controls (Non-scrollable)
            Column(
              children: [
                // Slider for Audio Playback
                Slider(
                  value: sliderValue,
                  min: 0,
                  max: totalDuration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      sliderValue = value;
                    });
                    _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      formatDuration(currentPosition),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      formatDuration(totalDuration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: currentIndex != null && currentIndex! > 0
                          ? () => togglePlayChapter(
                                audioChapters[currentIndex! - 1]['audio_link'],
                                currentIndex! - 1,
                              )
                          : null,
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: currentPlayingAudioUrl != null
                          ? () => togglePlayChapter(
                                currentPlayingAudioUrl!,
                                currentPlayingChapter!,
                              )
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: currentIndex != null &&
                              currentIndex! < audioChapters.length - 1
                          ? _playNextChapter
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.queue_music, color: Colors.white),
                      onPressed: _playAllChapters,
                    ),
                  ],
                ),
              ],
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
              color: Colors.grey[300],
            ),
            const SizedBox(width: 10.0),
            Container(
              width: 100,
              height: 12,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget audioChapter(String chapter, String audioLink, int index) {
    final isCurrentPlaying = currentPlayingChapter == index;
    return GestureDetector(
      onTap: () => togglePlayChapter(audioLink, index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isCurrentPlaying ? Config.primaryColor : Config.darkColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1.5,
            color: Config.whiteColor,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Chapter $chapter',
                style: const TextStyle(
                  color: Config.whiteColor,
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 11,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Config.whiteColor),
              onSelected: (value) {
                if (value == 'share') {
                  shareAudio(audioLink);
                } else if (value == 'download') {
                  downloadAudio(audioLink, 'Chapter_$chapter.mp3');
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'share',
                  child: const Row(
                    children: [
                      Icon(Icons.share, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    shareAudio(audioLink);
                  },
                ),
                PopupMenuItem(
                  value: 'download',
                  child: const Row(
                    children: [
                      Icon(Icons.download, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Download'),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    downloadAudio(audioLink, 'Chapter_$chapter.mp3');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
