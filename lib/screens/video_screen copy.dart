import 'package:flutter/material.dart';
import 'package:precious/utils/config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
                IconButton(
                  icon: const Icon(
                    Icons.share,
                    color: Config.whiteColor,
                  ),
                  onPressed: shareVideoLink,
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
