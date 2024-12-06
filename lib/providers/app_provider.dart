import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:precious/API/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _mostReadBooks = [];
  List<dynamic> get mostReadBooks => _mostReadBooks;

  List<dynamic> _newReleasedBooks = [];
  List<dynamic> get newReleasedBooks => _newReleasedBooks;

  List<dynamic> _audios = [];
  List<dynamic> get audios => _audios;

  String _userToken = '';
  String get userToken => _userToken;

  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  bool _isLogin = false;
  Map<String, dynamic> user = {};

  Future<void> _saveVideosToPrefs(List<dynamic> videos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('videos', jsonEncode(videos));
  }

  Future<void> _loadVideosFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? videosString = prefs.getString('videos');
    if (videosString != null) {
      _mostReadBooks = jsonDecode(videosString);
      notifyListeners();
    }
  }

  // Audio
  Future<void> _saveAudiosToPrefs(List<dynamic> audios) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('audios', jsonEncode(audios));
  }

  Future<void> _loadYearsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? audiosString = prefs.getString('years');
    if (audiosString != null) {
      _audios = jsonDecode(audiosString);
      notifyListeners();
    }
  }

  void setAudios(List<dynamic> newAudios) {
    _audios = newAudios;
    notifyListeners();
    _saveAudiosToPrefs(newAudios);
  }

  Future<void> getAllAudios() async {
    try {
      final audios = await ApiService().getAudioBook();
      setAudios(audios);
    } catch (e) {
      print('Error fetching Audios: $e');
    }
  }

  // MOST READ BOOKS
  Future<void> _saveMostReadBooksToPrefs(List<dynamic> mostReadBooks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mostReadBooks', jsonEncode(mostReadBooks));
  }

  Future<void> _loadMostReadBooksFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _mostReadBooksString = prefs.getString('_mostReadBooks');
    if (_mostReadBooksString != null) {
      _mostReadBooks = jsonDecode(_mostReadBooksString);
      notifyListeners();
    }
  }

  void setMostReadBooks(List<dynamic> newMostReadBooks) {
    _mostReadBooks = newMostReadBooks;
    notifyListeners();
    _saveMostReadBooksToPrefs(newMostReadBooks);
  }

  Future<void> getMostReadBooks() async {
    try {
      // Fetch the selected language from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';

      // Pass the selected language to the API call
      final mostReadBooks =
          await ApiService().getMostReadBooksAPI(language: selectedLanguage);
      setMostReadBooks(mostReadBooks);
    } catch (e) {
      print('Error fetching Most Read Books: $e');
    }
  }

  // NEW RELEASED BOOKS
  Future<void> _saveNewReleasedBooksToPrefs(
      List<dynamic> newReleasedBooks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('newReleasedBooks', jsonEncode(newReleasedBooks));
  }

  Future<void> _loadNewReleasedBooksFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _newReleasedBooksString = prefs.getString('_newReleasedBooks');
    if (_newReleasedBooksString != null) {
      _newReleasedBooks = jsonDecode(_newReleasedBooksString);
      notifyListeners();
    }
  }

  void setNewReleasedBooks(List<dynamic> newReleasedBooks) {
    _newReleasedBooks = newReleasedBooks;
    notifyListeners();
    _saveNewReleasedBooksToPrefs(newReleasedBooks);
  }

  Future<void> getNewReleasedBooks() async {
    try {
      // Fetch the selected language from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';

      // Pass the selected language to the API call
      final newReleasedBooks =
          await ApiService().getNewReleasedBooksAPI(language: selectedLanguage);
      setNewReleasedBooks(newReleasedBooks);
    } catch (e) {
      print('Error fetching New Released Books: $e');
    }
  }

  AppProvider() {
    // Load data from shared preferences on initialization
    // _loadSubjectsFromPrefs();
    // _loadYearsFromPrefs();
    //_loadQuestionsFromPrefs();

    // Fetch data from the API
    getMostReadBooks();
    getNewReleasedBooks();
    getAllAudios();
  }
}
