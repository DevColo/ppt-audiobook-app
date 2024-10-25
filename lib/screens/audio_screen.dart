import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/utils/config.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({
    super.key,
    required this.audioId,
    required this.audioName,
    required this.audioImage,
    required this.audio,
  });
  final int audioId;
  final String audioImage;
  final String audioName;
  final String audio;

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  late String theAudioName;
  late String theAudioImage;
  late String theAudio;
  late int theAudioId;
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    theAudioId = widget.audioId;
    theAudioName = widget.audioName;
    theAudioImage = widget.audioImage;
    theAudio = widget.audio;

    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPauseAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(theAudio));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Config.primaryColor,
        foregroundColor: Config.whiteColor,
        title: Text(
          theAudioName,
          style: const TextStyle(
            fontFamily: "Raleway-Regular",
            fontSize: 18.0,
          ),
        ),
        toolbarHeight: 45,
      ),
      backgroundColor: Config.greyColor,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 35.0,
          right: 35.0,
          bottom: 10.0,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20.0),
                // Display the audio image using CachedNetworkImage
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: CachedNetworkImage(
                    imageUrl: theAudioImage,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      size: 100,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                // Display the audio name
                Text(
                  theAudioName,
                  style: const TextStyle(
                    fontFamily: "Raleway-Bold",
                    fontSize: 24.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                // Play/Pause button
                ElevatedButton.icon(
                  onPressed: _playPauseAudio,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? 'Pause' : 'Play'),
                ),
                const SizedBox(height: 20.0),
                // Stop button
                ElevatedButton.icon(
                  onPressed: _stopAudio,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
