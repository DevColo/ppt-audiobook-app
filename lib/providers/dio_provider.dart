import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioProvider {
  //get token
  Future<dynamic> getToken(String email, String password) async {
    try {
      var response = await Dio().post('http://127.0.0.1:8000/api/login',
          data: {'email': email, 'password': password});
      if (response.statusCode == 200 && response.data != '') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }

  //get user data
  Future<dynamic> getUser(String token) async {
    try {
      var user = await Dio().get('http://127.0.0.1:8000/api/user',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (user.statusCode == 200 && user.data != '') {
        return json.encode(user.data);
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }

  //register new user
  Future<dynamic> registerUser(String firstName, String lastName, phone,
      String email, String password) async {
    try {
      var user = await Dio().post('http://127.0.0.1:8000/api/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'password': password
      });
      if (user.statusCode == 201 && user.data != '') {
        return true;
      } else if (user.statusCode == 200 && user.data == '') {
        return 'user_exist';
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }

  //store booking details
  Future<dynamic> bookVehicle(String startDate, String startTime,
      String endDate, String endTime, int vehicle, String token) async {
    try {
      var response = await Dio().post('http://127.0.0.1:8000/api/book',
          data: {
            'start_date': startDate,
            'start_time': startTime,
            'end_date': endDate,
            'end_time': endTime,
            'vehicle_id': vehicle
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //retrieve booking details
  Future<dynamic> getAppointments(String token) async {
    try {
      var response = await Dio().get('http://127.0.0.1:8000/api/appointments',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //store rating details
  Future<dynamic> storeReviews(
      String reviews, double ratings, int id, int doctor, String token) async {
    try {
      var response = await Dio().post('http://127.0.0.1:8000/api/reviews',
          data: {
            'ratings': ratings,
            'reviews': reviews,
            'appointment_id': id,
            'doctor_id': doctor
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //store fav doctor
  Future<dynamic> storeFavVehicle(String token, List<dynamic> favList) async {
    try {
      var response = await Dio().post('http://127.0.0.1:8000/api/fav',
          data: {
            'favList': favList,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //store fav doctor
  Future<dynamic> addFavVehicle(String token, int vehicleId) async {
    try {
      var response = await Dio().post('http://127.0.0.1:8000/api/add-fav',
          data: {
            'vehicle_id': vehicleId,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //get Fav Vehicle data
  Future<dynamic> getFavVehicle(String token) async {
    try {
      var favorite = await Dio().get('http://127.0.0.1:8000/api/fav-vehicle',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (favorite.statusCode == 200 && favorite.data != '') {
        return json.encode(favorite.data);
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }

  //get Fav Vehicle data
  Future<dynamic> getSubjects(String token) async {
    try {
      var subjects = await Dio().get('http://localhost:8080/subjects/api',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (subjects.statusCode == 200 && subjects.data != '') {
        return json.encode(subjects.data);
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }

  //remove fav doctor
  Future<dynamic> removeFavVehicle(String token, int vehicleId) async {
    try {
      var response = await Dio().post('http://127.0.0.1:8000/api/remove-fav',
          data: {
            'vehicle_id': vehicleId,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //get booking list
  Future<dynamic> getBooking(String token) async {
    try {
      var booking = await Dio().get('http://127.0.0.1:8000/api/get-booking',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (booking.statusCode == 200 && booking.data != '') {
        return json.encode(booking.data);
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }

//logout
  Future<dynamic> logout(String token) async {
    try {
      var response = await Dio().post('http://127.0.0.1:8000/api/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
}
