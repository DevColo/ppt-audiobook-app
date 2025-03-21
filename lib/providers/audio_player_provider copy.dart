import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  String? _currentAudioUrl;
  String? _currentChapterName;
  String? _currentBookTitle;
  String? _currentImageUrl;

  // Getters
  bool get isPlaying => _isPlaying;
  String? get currentAudioUrl => _currentAudioUrl;
  String? get currentChapterName => _currentChapterName;
  String? get currentBookTitle => _currentBookTitle;
  String? get currentImageUrl => _currentImageUrl;

  AudioPlayer get audioPlayer => _audioPlayer;

  /// Play audio from URL and update the current metadata
  Future<void> playAudio(
    audioLink, {
    required String url,
    required String chapterName,
    required String bookTitle,
    required String imageUrl,
  }) async {
    try {
      _currentAudioUrl = url;
      _currentChapterName = chapterName;
      _currentBookTitle = bookTitle;
      _currentImageUrl = imageUrl;

      await _audioPlayer.play(UrlSource(url));
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Pause current audio
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  /// Resume paused audio
  Future<void> resumeAudio() async {
    try {
      if (_currentAudioUrl != null) {
        await _audioPlayer.resume();
        _isPlaying = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error resuming audio: $e');
    }
  }

  /// Stop audio playback and clear current media info
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;

      _currentAudioUrl = null;
      _currentChapterName = null;
      _currentBookTitle = null;
      _currentImageUrl = null;

      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  /// Dispose of the player when done
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Optionally call this to dispose the player manually
  void disposeAudio() {
    _audioPlayer.dispose();
  }
}
