import 'dart:convert';

import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ppt.codeetserver.com'));

  //final Dio _dio = Dio(BaseOptions(baseUrl: 'http://ppt.site'));

  // Get video
  Future<dynamic> getVideos() async {
    try {
      //final response = await _dio.get('/get-videos/apiv1');
      //final response = await _dio.get('/jsonapi/node/subject');
      // return response.data;
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }

  // Get video
  Future<dynamic> getAudioBook() async {
    try {
      // final response = await _dio.get('/get-audio-book/apiv1');
      //final response = await _dio.get('/jsonapi/node/subject');
      // return response.data;
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }

  // Get Most Read Books
  Future<dynamic> getMostReadBooksAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/most-read-books');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load most read books: $e');
    }
  }

  // Get New Released Books
  Future<dynamic> getNewReleasedBooksAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/new-released-books');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load new released books: $e');
    }
  }
}
