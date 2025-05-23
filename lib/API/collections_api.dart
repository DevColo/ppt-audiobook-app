import 'dart:convert';

import 'package:dio/dio.dart';

class CollectionsApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ppt.druptech.com'));
  //final Dio _dio = Dio(BaseOptions(baseUrl: 'http://ppt.site'));

  // Get video
  Future<dynamic> getCollections() async {
    try {
      final response = await _dio.get('/api/get-collections');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load collections: $e');
    }
  }
}
