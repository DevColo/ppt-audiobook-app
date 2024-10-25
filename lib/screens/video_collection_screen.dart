import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:precious/API/api_service.dart';
import 'package:provider/provider.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCollectionScreen extends StatefulWidget {
  const VideoCollectionScreen({super.key});

  @override
  State<VideoCollectionScreen> createState() => _VideoCollectionScreenState();
}

class _VideoCollectionScreenState extends State<VideoCollectionScreen> {
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      setState(() {
        user = Map<String, dynamic>.from(jsonDecode(userData));
      });
    } else {
      Navigator.pushNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final videos = [
      {
        "id": 1,
        "video_title":
            "1 The BluePrint Earth\u0027s Final Movie PPT English version",
        "video_url": "https:\/\/www.youtube.com\/watch?v=crmQ6O4rQfE"
      },
      {
        "id": 2,
        "video_title": "2 Ivor Myers Story of The Bible with PPT",
        "video_url": "https:\/\/www.youtube.com\/watch?v=wonZKBKaMVc"
      },
      {
        "id": 3,
        "video_title":
            "3 \u201cThe Sanctuary \u0026 the Image of the Beast\u201d Ivor Myers 3ABN Winter Camp Meeting 2020",
        "video_url": "https:\/\/www.youtube.com\/watch?v=udiTxfx_UEA"
      }
    ]; //Provider.of<AppProvider>(context).videos;
    return Scaffold(
        backgroundColor: Config.greyColor,
        //if subjects is empty, then return progress indicator
        body: videos.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                  bottom: 5.0,
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 15.0),
                        WelcomeCard(),
                        const SizedBox(height: 15.0),
                        Column(
                          children: [
                            Center(
                              child: ResponsiveGrid(videos: videos),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}

// welcome card
class WelcomeCard extends StatefulWidget {
  const WelcomeCard({super.key});

  @override
  State<WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<WelcomeCard> {
  String title = "";
  String msg = "";

  @override
  void initState() {
    super.initState();
    msg = 'Precious Present Truth Video Collections';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Config.primaryColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Card(
        elevation: 0.0,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10.0),
        // ),
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    Text(
                      msg,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Config.whiteColor,
                        fontFamily: 'Raleway-Regular',
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<dynamic> videos;

  const ResponsiveGrid({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = getCrossAxisCount(constraints.maxWidth);
        return GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Prevent GridView from scrolling independently
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.75,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              if (videos[index]['id'] != null) {
                final video = videos[index];
                final videoUrl = video['video_url'];
                final videoTitle = video['video_title'];
                final videoId = video['id'];
                return VideoCard(
                  id: videoId,
                  videoTitle: videoTitle,
                  videoUrl: videoUrl,
                );
              }
              ;
            });
      },
    );
  }

  int getCrossAxisCount(double width) {
    if (width >= 1200) return 8;
    if (width >= 992) return 6;
    if (width >= 768) return 4;
    if (width >= 576) return 3;
    return 2;
  }
}

class VideoCard extends StatefulWidget {
  final int id;
  final String videoTitle;
  final String videoUrl;

  const VideoCard({
    super.key,
    required this.id,
    required this.videoTitle,
    required this.videoUrl,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Extract the video ID from the URL and initialize the player
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
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
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        child: Container(
          height: 150, // Adjust this value to control the video player height
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: false,
          ),
        ));
  }
}
