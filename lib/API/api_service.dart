import 'dart:convert';

import 'package:dio/dio.dart';

class ApiService {
  //final Dio _dio = Dio(BaseOptions(baseUrl: 'https://codeetserver.com'));
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://precious.admin'));

  // Get video
  Future<dynamic> getVideos() async {
    try {
      final response = await _dio.get('/get-videos/apiv1');
      //final response = await _dio.get('/jsonapi/node/subject');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }

  // Get video
  Future<dynamic> getAudioBook() async {
    try {
      final response = await _dio.get('/get-audio-book/apiv1');
      //final response = await _dio.get('/jsonapi/node/subject');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }

  Future<String> getGreeting() async {
    try {
      final response = await _dio.get('/subjects/greeting');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load greeting: $e');
    }
  }

// Get subjects with questions count
  Future<dynamic> getSubjects() async {
    try {
      final response =
          await _dio.get('/subjects/api/subjects-and-questions-count');
      //final response = await _dio.get('/jsonapi/node/subject');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }

// Academics year
  Future<dynamic> getYears() async {
    try {
      final response = await _dio.get('/years/api');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load years: $e');
    }
  }

  // Q&A
  Future<dynamic> getQABySubjectAndYear(int subjectId, int yearId) async {
    try {
      final response = await _dio
          .get('/questions/api/getQABySubjectAndYear/$subjectId/$yearId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load Q&A: $e');
    }
  }

  Future<dynamic> getAllQABySubjectAndYear(int subjectId, int yearId) async {
    try {
      final response = await _dio
          .get('/questions/api/getAllQABySubjectAndYear/$subjectId/$yearId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load Q&A: $e');
    }
  }

  Future<dynamic> getToken(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/user-login',
        data: {'username': username, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception('Failed to login: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Get user data
  Future<dynamic> getUserData(String token) async {
    try {
      var user = await _dio.post('/api/user-data',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (user.statusCode == 200 && user.data != '') {
        return user.data;
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to fetch user data: $error');
    }
  }

  // Send Quiz Data
  Future<dynamic> sendQuizScore(
      String score, int subjectId, int yearId, String userId) async {
    try {
      final response = await _dio.post(
        '/api/send-quiz-score',
        data: {
          'score': score,
          'subject_id': subjectId,
          'year_id': yearId,
          'user_id': userId
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception('Failed to save quiz: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to save quiz: $e');
    }
  }

  // Get user quizes hisotry
  Future<dynamic> getUserQuizesHistory(String userId) async {
    try {
      var quizes = await _dio.get('/quiz-results/api/$userId');
      if (quizes.statusCode == 200 && quizes.data != '') {
        return quizes.data;
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to fetch quizes: $error');
    }
  }

  // Logout user
  Future<void> logout() async {
    // Clear the token or perform any necessary logout operations
  }

  // Change User Password
  Future<dynamic> changePassword(String userId, String password) async {
    try {
      final response = await _dio.post(
        '/api/change-password',
        data: {'user_id': userId, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        //return json.decode(response.data);
        return response.data;
      } else {
        throw Exception('Failed to change password: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
