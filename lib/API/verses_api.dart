import 'dart:convert';

import 'package:dio/dio.dart';

class VersesApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ppt.druptech.com'));
  //final Dio _dio = Dio(BaseOptions(baseUrl: 'http://ppt.site'));

  // Get Pastors
  Future<dynamic> getVersesAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/bible-verses');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load verses: $e');
    }
  }

  // Get Bible Verse Videos
  Future<dynamic> getBibleVerseAPI({required int videoID}) async {
    try {
      final response = await _dio.get('/api/bible-verse/$videoID');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }
}
