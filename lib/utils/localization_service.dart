import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  late Map<String, String> _localizedStrings = {};

  LocalizationService._internal();

  Future<void> loadLanguage(String languageCode) async {
    String jsonString =
        await rootBundle.loadString('assets/lang/$languageCode.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
