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

  List<dynamic> _preachers = [];
  List<dynamic> get preachers => _preachers;

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
          await _apiService.getNewReleasedBooksAPI(language: selectedLanguage);
      setNewReleasedBooks(newReleasedBooks);
    } catch (e) {
      print('Error fetching New Released Books: $e');
    }
  }

  // Preachers
  Future<void> _savePreachersToPrefs(List<dynamic> preachers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('preachers', jsonEncode(preachers));
  }

  Future<void> _loadPreachersFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _preachersString = prefs.getString('_preachers');
    if (_preachersString != null) {
      _preachers = jsonDecode(_preachersString);
      notifyListeners();
    }
  }

  void setPreachers(List<dynamic> newpreachers) {
    _preachers = newpreachers;
    notifyListeners();
    _savePreachersToPrefs(newpreachers);
  }

  Future<void> getPreachers() async {
    try {
      // Fetch the selected language from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';

      // Pass the selected language to the API call
      final preachers =
          await _apiService.getPreachersAPI(language: selectedLanguage);
      setPreachers(preachers);
    } catch (e) {
      print('Error fetching preachers: $e');
    }
  }

  AppProvider() {
    // Fetch data from the API
    getPreachers();
    getNewReleasedBooks();
  }
}
