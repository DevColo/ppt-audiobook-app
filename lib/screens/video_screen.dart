import 'dart:io';
import 'package:flutter/material.dart';
import 'package:precious/utils/config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class VideoScreen extends StatefulWidget {
  final String title;
  final String videoLink;

  const VideoScreen({
    super.key,
    required this.title,
    required this.videoLink,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Extract the video ID from the URL and initialize the player
    final videoId = YoutubePlayer.convertUrlToId(widget.videoLink);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shareVideoLink() {
    try {
      Share.share(
          'Shared from Precious Present Truth - Mobile App: ${widget.videoLink}');
    } catch (e) {
      debugPrint('Error sharing video link: $e');
    }
  }

  void downloadVideo() async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          debugPrint('Permission denied');
          return;
        }
      }

      // Extract video ID
      final yt = YoutubeExplode();
      final videoId = YoutubePlayer.convertUrlToId(widget.videoLink);

      // Get video stream info
      final video = await yt.videos.get(videoId!);
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo =
          manifest.muxed.bestQuality; // Get best available quality

      if (streamInfo == null) {
        debugPrint('No suitable stream found');
        return;
      }

      // Get storage directory
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir?.path}/${video.title}.mp4';

      // Start downloading
      await FlutterDownloader.enqueue(
        url: streamInfo.url.toString(),
        savedDir: dir!.path,
        fileName: '${video.title}.mp4',
        showNotification: true,
        openFileFromNotification: true,
      );

      debugPrint('Downloading: ${video.title}');
    } catch (e) {
      debugPrint('Download error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: isLandscape
          ? null // Hide AppBar in landscape mode
          : AppBar(
              backgroundColor: Config.primaryColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Config.whiteColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Montserrat-SemiBold',
                  color: Config.whiteColor,
                ),
              ),
              actions: [
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, color: Config.whiteColor),
                  onSelected: (value) {
                    if (value == 1) {
                      shareVideoLink();
                    } else if (value == 2) {
                      downloadVideo();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: ListTile(
                        leading: const Icon(Icons.share),
                        title: const Text("Share Video"),
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text("Download Video"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      body: Padding(
        padding: isLandscape
            ? EdgeInsets.zero // No padding in landscape mode
            : const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          width: double.infinity,
          aspectRatio: isLandscape
              ? MediaQuery.of(context).size.aspectRatio
              : 16 / 9, // Fit screen in landscape
        ),
      ),
    );
  }
}
