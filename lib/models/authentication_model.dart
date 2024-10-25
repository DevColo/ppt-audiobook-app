// import 'package:flutter/material.dart';

// class AuthenticationModel extends ChangeNotifier {
//   bool _isLogin = false;
//   Map<String, dynamic> user = {};
//   Map<String, dynamic> activeSubjects = {};
//   Map<String, dynamic> favVehicle = {};
//   Map<String, dynamic> pendingList = {};
//   Map<String, dynamic> approvedList = {};
//   Map<String, dynamic> deniedList = {};
//   Map<String, dynamic> vehicle = {};
//   List<Map<String, dynamic>> favDoc = [];
//   final List<dynamic> _fav = [];

//   bool get isLogin {
//     return _isLogin;
//   }

//   List<dynamic> get getFav {
//     return _fav;
//   }

//   Map<String, dynamic> get getUser {
//     return user;
//   }

//   Map<String, dynamic> get getFavVehicle {
//     return favVehicle;
//   }

//   Map<String, dynamic> get getSubjects {
//     return activeSubjects;
//   }

//   Map<String, dynamic> get getBooking {
//     return pendingList;
//   }

// //when login success, update the status
//   void loginSuccess(Map<String, dynamic> userData) {
//     _isLogin = true;

//     user = userData;

//     notifyListeners();
//   }
// }
