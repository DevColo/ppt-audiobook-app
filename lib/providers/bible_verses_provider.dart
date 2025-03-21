import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:precious/API/verses_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleVersesProvider with ChangeNotifier {
  final VersesApi _versesApi = VersesApi();

  List<dynamic> _verses = [];
  List<dynamic> get verses => _verses;

  List<dynamic> _videos = [];
  List<dynamic> get videos => _videos;

  // VERSES
  Future<void> _saveVersesToPrefs(List<dynamic> verses) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('verses', jsonEncode(verses));
  }

  Future<void> _loadVersesFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _versesString = prefs.getString('_verses');
    if (_versesString != null) {
      _verses = jsonDecode(_versesString);
      notifyListeners();
    }
  }

  void setVerses(List<dynamic> verses) {
    _verses = verses;
    notifyListeners();
    _saveVersesToPrefs(verses);
  }

  Future<void> getVerses() async {
    try {
      // Fetch the selected language from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';

      // Pass the selected language to the API call
      final verses = await _versesApi.getVersesAPI(language: selectedLanguage);
      setVerses(verses);
    } catch (e) {
      print('Error fetching verses: $e');
    }
  }

  // VIDEOS
  Future<void> _saveVideosToPrefs(List<dynamic> videos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('videos', jsonEncode(videos));
  }

  Future<void> _loadVideosFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _videosString = prefs.getString('_videos');
    if (_videosString != null) {
      _videos = jsonDecode(_videosString);
      notifyListeners();
    }
  }

  void setVideos(List<dynamic> videos) {
    _videos = videos;
    notifyListeners();
    _saveVideosToPrefs(videos);
  }

  Future<void> getVideos(BuildContext context, int videoID) async {
    try {
      final videos = await _versesApi.getBibleVerseAPI(videoID: videoID);
      setVideos(videos);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please check internet connection and try again.",
            style: const TextStyle(color: Colors.red),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 216, 203),
          elevation: 2.0,
        ),
      );
    }
  }

  BibleVersesProvider() {
    // Fetch data from the API
    getVerses();
  }
}
