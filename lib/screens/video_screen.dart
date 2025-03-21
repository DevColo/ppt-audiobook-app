// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precious/components/floating_audio_player.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service%20copy.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class VideoScreen extends StatefulWidget {
  final String title;
  final String videoLink;
  final int playListID;

  const VideoScreen({
    super.key,
    required this.title,
    required this.videoLink,
    required this.playListID,
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
    fetchVideos();
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
      // Show loading indicator (optional)
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Request storage permission (Android 13+ has scoped storage)
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          Navigator.of(context).pop(); // Close loading dialog
          debugPrint('Permission denied');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required!')),
          );
          return;
        }
      }

      final yt = YoutubeExplode();

      // Extract video ID from link
      final videoId = YoutubePlayer.convertUrlToId(widget.videoLink);

      if (videoId == null) {
        Navigator.of(context).pop();
        debugPrint('Invalid video URL');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid video URL')),
        );
        return;
      }

      // Get video details
      final video = await yt.videos.get(videoId);
      final manifest = await yt.videos.streamsClient.getManifest(videoId);

      // Select the best quality muxed stream (video + audio)
      final streamInfo = manifest.muxed.withHighestBitrate();

      // Get a sanitized filename (remove special characters)
      final sanitizedTitle =
          video.title.replaceAll(RegExp(r'[<>:"\\/|?*]'), '_');

      // Get external storage directory (Android)
      final dir = await getExternalStorageDirectory();

      if (dir == null) {
        Navigator.of(context).pop();
        debugPrint('Storage directory not found');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to access storage.')),
        );
        return;
      }

      // Download with FlutterDownloader (HTTP download, not stream download)
      await FlutterDownloader.enqueue(
        url: streamInfo.url.toString(),
        savedDir: dir.path,
        fileName: '$sanitizedTitle.mp4',
        showNotification: true,
        openFileFromNotification: true,
      );

      debugPrint('Downloading: $sanitizedTitle');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading: $sanitizedTitle')),
      );

      // Clean up YoutubeExplode instance
      yt.close();
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      Navigator.of(context).pop(); // Close loading dialog if it was open
    }
  }

  Future<void> fetchVideos() async {
    await Provider.of<SermonsProvider>(context, listen: false)
        .getVideos(context, widget.playListID);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final videoPlayList = Provider.of<SermonsProvider>(context).videos;

    // Handle system UI overlays based on orientation
    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return WillPopScope(
      onWillPop: () async {
        // Reset orientation and system UI when exiting the screen
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: Scaffold(
        appBar: isLandscape
            ? null
            : AppBar(
                backgroundColor: Config.primaryColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Config.whiteColor,
                  ),
                  onPressed: () async {
                    // Reset orientation before popping
                    await SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    await SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.edgeToEdge);
                    //Navigator.pop(context);
                    Navigator.pushNamed(context, 'main');
                  },
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
                          title: Text(LocalizationService().translate('share')),
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: ListTile(
                          leading: const Icon(Icons.download),
                          title:
                              Text(LocalizationService().translate('download')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        backgroundColor: Config.greyColor,
        body: Column(
          children: [
            if (isLandscape)
              Expanded(
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  width: double.infinity,
                  aspectRatio: MediaQuery.of(context).size.aspectRatio,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 25.0),
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  width: double.infinity,
                  aspectRatio: 16 / 9,
                ),
              ),
            if (!isLandscape)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 25.0),
                  child: videoPlayList.isEmpty
                      ? Center(
                          child:
                              Text(LocalizationService().translate('noData')),
                        )
                      : ListView(
                          children: videoPlayList.map((video) {
                            return videoCard(
                              video['title'],
                              video['video_link'],
                              widget.playListID,
                            );
                          }).toList(),
                        ),
                ),
              ),
            FloatingAudioControl(),
          ],
        ),
      ),
    );
  }

  Widget videoCard(String title, String videoLink, int playListID) {
    bool isCurrentlyPlaying = widget.title == title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: () async {
          // Pause the currently playing video before navigating
          if (_controller.value.isPlaying) {
            _controller.pause();
          }

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
            color: isCurrentlyPlaying ? Config.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              const EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 8.0),
          child: Row(
            children: [
              Container(
                height: 50,
              ),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 230,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isCurrentlyPlaying
                            ? Config.whiteColor
                            : const Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.play_circle_fill,
                color: isCurrentlyPlaying
                    ? Config.whiteColor
                    : Config.primaryColor,
                size: 25.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
