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
      // Handle fetch errors without breaking playback
      debugPrint("Error fetching chapters: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading chapters: $e')),
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
                            SizedBox(
                              width: 200.0,
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Config.whiteColor,
                                  fontFamily: 'Montserrat-SemiBold',
                                  fontSize: 14,
                                ),
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
                        : buildAudioChapterList(audioChapters),
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
                          ? () {
                              final audioChapters =
                                  Provider.of<AudioBooksProvider>(context,
                                          listen: false)
                                      .books;
                              setState(() {
                                currentIndex = currentIndex! - 1;
                                isPlaying = true;
                                currentPlayingChapter = currentIndex;
                              });
                              togglePlayChapter(
                                  audioChapters[currentIndex!]['audio_link'],
                                  currentIndex!);
                            }
                          : null,
                    ),
                    IconButton(
                      icon: currentPlayingAudioUrl == null
                          ? const Icon(Icons.play_arrow, color: Colors.white)
                          : isAudioLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                      onPressed:
                          currentPlayingAudioUrl != null && !isAudioLoading
                              ? () async {
                                  if (isPlaying) {
                                    await _audioPlayer.pause();
                                    setState(() {
                                      isPlaying = false;
                                    });
                                  } else {
                                    await _audioPlayer.resume();
                                    setState(() {
                                      isPlaying = true;
                                    });
                                  }
                                }
                              : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: currentIndex != null &&
                              currentIndex! < audioChapters.length - 1
                          ? () {
                              final audioChapters =
                                  Provider.of<AudioBooksProvider>(context,
                                          listen: false)
                                      .books;
                              setState(() {
                                currentIndex = currentIndex! + 1;
                                isPlaying = true;
                                currentPlayingChapter = currentIndex;
                              });
                              togglePlayChapter(
                                  audioChapters[currentIndex!]['audio_link'],
                                  currentIndex!);
                            }
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.queue_music, color: Colors.white),
                      onPressed:
                          audioChapters.isNotEmpty ? _playAllChapters : null,
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
    final isCurrentPlaying = currentPlayingChapter == index;
    isDownloading =
        Provider.of<AudioBooksProvider>(context).getDownloadProgress(index) > 0;
    final isDownloadComplete =
        Provider.of<AudioBooksProvider>(context).isDownloadComplete(index);

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
            if (isDownloading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: Provider.of<AudioBooksProvider>(context)
                          .getDownloadProgress(index) /
                      100,
                  strokeWidth: 2,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            // if (isDownloadComplete)
            //   const Icon(
            //     Icons.check_circle,
            //     color: Colors.green,
            //     size: 20,
            //   ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Config.whiteColor),
              onSelected: (value) {
                if (value == 'share') {
                  shareAudio(audioLink);
                } else if (value == 'download') {
                  downloadAudio(audioLink, 'Chapter_$chapter.mp3', index);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      const Icon(Icons.share, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(LocalizationService().translate('share')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      const Icon(Icons.download, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(LocalizationService().translate('download')),
                    ],
                  ),
                ),
              ],
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
            color: Config.whiteColor,
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
