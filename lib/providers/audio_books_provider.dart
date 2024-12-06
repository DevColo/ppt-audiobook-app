import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:precious/API/audio_books_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioBooksProvider with ChangeNotifier {
  List<dynamic> _audioBooks = [];
  List<dynamic> get audioBooks => _audioBooks;

  List<dynamic> _books = [];
  List<dynamic> get books => _books;

  // Audio Books
  Future<void> _saveAudioBooksToPrefs(List<dynamic> audioBooks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioBooks', jsonEncode(audioBooks));
  }

  Future<void> _loadAudioBooksFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _audioBooksString = prefs.getString('_audioBooks');
    if (_audioBooksString != null) {
      _audioBooks = jsonDecode(_audioBooksString);
      notifyListeners();
    }
  }

  void setAudioBooks(List<dynamic> audioBooks) {
    _audioBooks = audioBooks;
    notifyListeners();
    _saveAudioBooksToPrefs(audioBooks);
  }

  Future<void> getAudioBooks() async {
    try {
      // Fetch the selected language from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';

      // Pass the selected language to the API call
      final audioBooks =
          await AudioBooksApi().getAudioBooksAPI(language: selectedLanguage);
      setAudioBooks(audioBooks);
    } catch (e) {
      print('Error fetching audio books: $e');
    }
  }

  // BOOKS
  Future<void> _saveBooksToPrefs(List<dynamic> books) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('books', jsonEncode(books));
  }

  Future<void> _loadBooksFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _booksString = prefs.getString('_books');
    if (_booksString != null) {
      _books = jsonDecode(_booksString);
      notifyListeners();
    }
  }

  void setBooks(List<dynamic> books) {
    _books = books;
    notifyListeners();
    _saveBooksToPrefs(books);
  }

  Future<void> getBooks(BuildContext context, int bookId) async {
    try {
      final books = await AudioBooksApi().getBookAPI(bookId: bookId);
      setBooks(books);
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

  AudioBooksProvider() {
    // Fetch data from the API
    getAudioBooks();
  }
}
