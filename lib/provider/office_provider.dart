// lib/provider/officer_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/officer_model.dart';


class OfficerProvider with ChangeNotifier {
  ForestOfficer? _officer;

  ForestOfficer? get officer => _officer;
  bool get isLoggedIn => _officer != null;

  Future<void> setOfficer(ForestOfficer officer) async {
    _officer = officer;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('officer_data', jsonEncode(officer.toMap()));
    await prefs.setString('user_type', 'forestOfficer');
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('user_type');

    if (userType == 'forestOfficer') {
      final officerData = prefs.getString('officer_data');
      if (officerData != null) {
        _officer = ForestOfficer.fromMap(jsonDecode(officerData));
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    _officer = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('officer_data');
    await prefs.remove('user_type');
    await prefs.remove('cached_fcm_token');
  }

  Future<void> updateFCMToken(String token) async {
    if (_officer != null) {
      _officer = _officer!.copyWith(fcmToken: token);
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('officer_data', jsonEncode(_officer!.toMap()));
    }
  }
}
