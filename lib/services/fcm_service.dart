// lib/services/fcm_service.dart
// ✅ This file was mostly correct. No critical bugs found.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeFCM(String userId, String userType) async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
          "🔔 Notification permission: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint("⚠️ User denied notification permissions.");
        return;
      }

      String? deviceToken = await _messaging.getToken();
      if (deviceToken == null) {
        debugPrint("⚠️ Failed to get FCM device token.");
        return;
      }

      debugPrint("📱 Device FCM Token: $deviceToken");

      final SharedPreferences prefs =
      await SharedPreferences.getInstance();
      String? cachedToken = prefs.getString('cached_fcm_token');
      String? firestoreToken =
      await _getTokenFromFirestore(userId, userType);

      if (cachedToken != deviceToken ||
          firestoreToken != deviceToken) {
        debugPrint("🔄 Token mismatch. Syncing...");
        await _syncTokenToFirestore(userId, userType, deviceToken);
        await prefs.setString('cached_fcm_token', deviceToken);
        debugPrint("✅ FCM token synced successfully.");
      } else {
        debugPrint("✅ FCM token is already up to date.");
      }

      _messaging.onTokenRefresh.listen((String newToken) async {
        debugPrint("🔄 FCM Token refreshed: $newToken");
        await _syncTokenToFirestore(userId, userType, newToken);
        final SharedPreferences refreshPrefs =
        await SharedPreferences.getInstance();
        await refreshPrefs.setString('cached_fcm_token', newToken);
        debugPrint("✅ Refreshed FCM token synced.");
      });
    } catch (e, stackTrace) {
      debugPrint("❌ FCM Initialization Error: $e");
      debugPrint("📋 Stack Trace: $stackTrace");
    }
  }

  Future<String?> _getTokenFromFirestore(
      String userId, String userType) async {
    try {
      String collection = _getCollectionName(userType);
      DocumentSnapshot doc =
      await _firestore.collection(collection).doc(userId).get();

      if (doc.exists) {
        Map<String, dynamic>? data =
        doc.data() as Map<String, dynamic>?;
        return data?['fcmToken'] as String?;
      }
    } catch (e) {
      debugPrint("❌ Error fetching token from Firestore: $e");
    }
    return null;
  }

  Future<void> _syncTokenToFirestore(
      String userId, String userType, String token) async {
    try {
      String collection = _getCollectionName(userType);
      await _firestore.collection(collection).doc(userId).set(
        {
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint("✅ Token synced: $collection/$userId");
    } catch (e) {
      debugPrint("❌ Error syncing token: $e");
    }
  }

  Future<void> removeFCMToken(
      String userId, String userType) async {
    try {
      String collection = _getCollectionName(userType);
      await _firestore.collection(collection).doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });

      final SharedPreferences prefs =
      await SharedPreferences.getInstance();
      await prefs.remove('cached_fcm_token');
      debugPrint("✅ FCM token removed for $userType ($userId).");
    } catch (e) {
      debugPrint("❌ Error removing FCM token: $e");
    }
  }

  String _getCollectionName(String userType) {
    return userType == 'civilian' ? 'civilians' : 'officers';
  }
}