// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class ChapterAudioScreen extends StatefulWidget {
  final int bookID;
  final String bookTitle;
  final String chapterName;
  final String audioUrl;
  final String imageUrl;
  final int chapterIndex;
  final Function(int) onNavigateToChapter;

  const ChapterAudioScreen({
    super.key,
    required this.bookID,
    required this.bookTitle,
    required this.chapterName,
    required this.audioUrl,
    required this.imageUrl,
    required this.chapterIndex,
    required this.onNavigateToChapter,
  });

  @override
  State<ChapterAudioScreen> createState() => _ChapterAudioScreenState();
}

class _ChapterAudioScreenState extends State<ChapterAudioScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  double sliderValue = 0.0;
  bool isAudioLoading = true;
  bool isDownloading = false;
  double downloadProgress = 0.0; // Track download progress percentage

  @override
  void initState() {
    super.initState();
    _loadAudio();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
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
      // Auto-navigate to next chapter
      widget.onNavigateToChapter(widget.chapterIndex + 1);
    });
  }

  Future<void> _loadAudio() async {
    setState(() {
      isAudioLoading = true;
    });

    try {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
      setState(() {
        isPlaying = true;
        isAudioLoading = false;
      });
    } catch (e) {
      debugPrint("Error playing chapter: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing chapter: $e')),
      );
      setState(() {
        isAudioLoading = false;
      });
    }
  }

  Future<void> downloadAudio() async {
    setState(() {
      isDownloading = true;
      downloadProgress = 0.0;
    });

    try {
      final request = http.Request('GET', Uri.parse(widget.audioUrl));
      final response = await request.send();

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filename = '${widget.bookTitle}_${widget.chapterName}.mp3';
        final file = File('${directory.path}/$filename');

        // Track download progress
        final contentLength = response.contentLength ?? 0;
        int receivedLength = 0;
        final sink = file.openWrite();

        final progressStream = response.stream.asBroadcastStream();
        progressStream.listen(
          (List<int> chunk) {
            receivedLength += chunk.length;
            if (contentLength > 0) {
              setState(() {
                downloadProgress = receivedLength / contentLength;
              });
            }
            sink.add(chunk);
          },
          onDone: () async {
            await sink.close();
            setState(() {
              isDownloading = false;
              downloadProgress = 1.0;
            });
            // Update the provider with the new file
            Provider.of<AudioBooksProvider>(context, listen: false)
                .refreshDownloadedFiles();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$filename downloaded successfully!')),
            );
          },
          onError: (error) {
            sink.close();
            setState(() {
              isDownloading = false;
              downloadProgress = 0.0;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error downloading file: $error')),
            );
          },
        );
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading: $e')),
      );
    }
  }

  void shareAudio() {
    Share.share(widget.audioUrl);
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
    return Scaffold(
      backgroundColor: Config.darkColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.chapterName,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat-SemiBold',
            fontSize: 12.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Download button with progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.download, color: Config.whiteColor),
                onPressed: isDownloading ? null : downloadAudio,
              ),
              if (isDownloading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Config.primaryColor,
                    value: downloadProgress,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Config.whiteColor),
            onPressed: shareAudio,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Book Cover Image
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Chapter Information
            Text(
              widget.bookTitle,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Montserrat-Regular',
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              widget.chapterName,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat-Bold',
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),

            // Spacer to push player controls to bottom
            const Spacer(),

            // Player Controls
            Column(
              children: [
                // Progress indicator
                if (isAudioLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Config.primaryColor,
                    ),
                  )
                else
                  Column(
                    children: [
                      // Slider for Audio Playback
                      Slider(
                        value: sliderValue,
                        min: 0,
                        max: totalDuration.inMilliseconds.toDouble(),
                        activeColor: Config.primaryColor,
                        inactiveColor: Colors.grey[600],
                        onChanged: (value) {
                          setState(() {
                            sliderValue = value;
                          });
                          _audioPlayer
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                      ),

                      // Time indicators
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDuration(currentPosition),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              formatDuration(totalDuration),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous chapter button
                    IconButton(
                      icon: const Icon(Icons.skip_previous,
                          color: Colors.white, size: 32),
                      onPressed: widget.chapterIndex > 0
                          ? () => widget
                              .onNavigateToChapter(widget.chapterIndex - 1)
                          : null,
                    ),

                    const SizedBox(width: 20),

                    // Play/Pause button
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Config.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Config.primaryColor.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: isAudioLoading
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
                                size: 40,
                              ),
                        onPressed: isAudioLoading
                            ? null
                            : () async {
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
                              },
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Next chapter button
                    IconButton(
                      icon: const Icon(Icons.skip_next,
                          color: Colors.white, size: 32),
                      onPressed: () =>
                          widget.onNavigateToChapter(widget.chapterIndex + 1),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
