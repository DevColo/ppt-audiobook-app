import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:precious/API/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _videos = [];
  List<dynamic> get videos => _videos;

  List<dynamic> _subjects = [];
  List<dynamic> get subjects => _subjects;

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
      _subjects = jsonDecode(videosString);
      notifyListeners();
    }
  }

  void setVideos(List<dynamic> newVideos) {
    _videos = newVideos;
    notifyListeners();
    _saveVideosToPrefs(newVideos); // Save to shared preferences
  }

  Future<void> getAllVideos() async {
    try {
      final videos = await ApiService().getVideos();
      setVideos(videos);
    } catch (e) {
      print('Error fetching Videos: $e');
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
    _saveAudiosToPrefs(newAudios); // Save to shared preferences
  }

  Future<void> getAllAudios() async {
    try {
      final audios = await ApiService().getAudioBook();
      setAudios(audios);
    } catch (e) {
      print('Error fetching Videos: $e');
    }
  }

  Future<void> _saveSubjectsToPrefs(List<dynamic> subjects) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('subjects', jsonEncode(subjects));
  }

  Future<void> _loadSubjectsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subjectsString = prefs.getString('subjects');
    if (subjectsString != null) {
      _subjects = jsonDecode(subjectsString);
      notifyListeners();
    }
  }

  void setSubjects(List<dynamic> newSubjects) {
    _subjects = newSubjects;
    notifyListeners();
    _saveSubjectsToPrefs(newSubjects); // Save to shared preferences
  }

  Future<void> getAllSubjects() async {
    try {
      final subjects = await ApiService().getSubjects();
      setSubjects(subjects);
    } catch (e) {
      print('Error fetching subjects: $e');
    }
  }

  /* 
  * User Token 
  */

  // save user auth token to shared preference
  Future<void> _saveUserTokenToPrefs(String userToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_auth_token', userToken);
  }

  // load user auth token to shared preference
  Future<void> _loadUserTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userTokenString = prefs.getString('user_auth_token');
    if (userTokenString != null) {
      _userToken = jsonDecode(userTokenString);
      notifyListeners();
    }
  }

  void setUserToken(String newUserToken) {
    _userToken = newUserToken;
    notifyListeners();
    _saveUserTokenToPrefs(newUserToken);
  }

  Future<dynamic> getUserToken(String username, String password) async {
    try {
      final token = await ApiService().getToken(username, password);
      setUserToken(token['jwt']);
    } catch (e) {
      print('Error fetching user token: $e');
    }
  }

  /* 
  * User Data 
  */

  // save user auth Data to shared preference
  Future<void> _saveUserDataToPrefs(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  Future<void> _loadUserDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      _userData = jsonDecode(userDataString);
      notifyListeners();
    }
  }

  void setUserData(Map<String, dynamic> newUserData) {
    _userData = newUserData;
    notifyListeners();
    _saveUserDataToPrefs(newUserData);
  }

  Future<dynamic> getUserData(String token) async {
    try {
      final data = await ApiService().getUserData(token);
      setUserData(data);
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  bool get isLogin {
    return _isLogin;
  }

  Map<String, dynamic> get getUser {
    return user;
  }

//when login success, update the status
  void loginSuccess(Map<String, dynamic> userData) {
    _isLogin = true;

    user = userData;

    notifyListeners();
  }

  AppProvider() {
    // Load data from shared preferences on initialization
    // _loadSubjectsFromPrefs();
    // _loadYearsFromPrefs();
    //_loadQuestionsFromPrefs();

    // Fetch data from the API
    getAllSubjects();
    getAllVideos();
    getAllAudios();
  }
}
