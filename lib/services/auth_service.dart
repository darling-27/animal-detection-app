// lib/services/officer_auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/officer_model.dart';
import 'fcm_service.dart';

class OfficerAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference for officers
  CollectionReference get _officersCollection =>
      _firestore.collection('officers');

  /// Authenticate officer by Staff_Id and Password
  /// Returns ForestOfficer if credentials are valid, null otherwise
  Future<ForestOfficer?> loginOfficer({
    required String staffId,
    required String password,
  }) async {
    try {
      // Query Firestore for matching Staff_Id
      final QuerySnapshot querySnapshot = await _officersCollection
          .where('Staff_Id', isEqualTo: staffId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('❌ No officer found with Staff_Id: $staffId');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;

      // Check if password matches
      if (data['Password'] == password) {
        data['id'] = doc.id;
        final officer = ForestOfficer.fromMap(data);

        // Initialize FCM after successful login
        await FCMService().initializeFCM(officer.id, 'forestOfficer');

        debugPrint('✅ Officer logged in: ${officer.name}');
        return officer;
      }

      debugPrint('❌ Invalid password for Staff_Id: $staffId');
      return null;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return null;
    }
  }

  /// Check if a Staff_Id exists in the database
  Future<bool> staffIdExists(String staffId) async {
    try {
      final QuerySnapshot querySnapshot = await _officersCollection
          .where('Staff_Id', isEqualTo: staffId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Staff ID check error: $e');
      return false;
    }
  }

  /// Get officer by ID
  Future<ForestOfficer?> getOfficerById(String id) async {
    try {
      final doc = await _officersCollection.doc(id).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ForestOfficer.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get officer error: $e');
      return null;
    }
  }

  /// Update officer FCM token
  Future<void> updateFCMToken(String officerId, String fcmToken) async {
    try {
      await _officersCollection.doc(officerId).update({
        'fcmToken': fcmToken,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ FCM token updated for officer: $officerId');
    } catch (e) {
      debugPrint('❌ Update FCM token error: $e');
    }
  }

  /// Sign out officer
  Future<void> signOut(String officerId) async {
    try {
      // Clear FCM token on logout
      await FCMService().removeFCMToken(officerId, 'forestOfficer');
      debugPrint('✅ Officer signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    }
  }
}
