import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/civilian_login_model.dart';

class CivilianProvider extends ChangeNotifier {
  Civilian? _civilian;

  Civilian? get civilian => _civilian;
  bool get isLoggedIn => _civilian != null;

  Future<void> setCivilian(Civilian civilian) async {
    _civilian = civilian;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('civilian_data', jsonEncode(civilian.toMap()));
    await prefs.setString('user_role', 'civilian');
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('civilian_data');
    final role = prefs.getString('user_role');

    if (data != null && role == 'civilian') {
      _civilian = Civilian.fromMap(jsonDecode(data));
      notifyListeners();
    }
  }

  // ✅ Add this method for logout
  Future<void> clearCivilian() async {
    _civilian = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('civilian_data');
    await prefs.remove('user_role');
  }
}