// lib/services/civilian_auth_service.dart - UPDATED
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/civilian_login_model.dart';
import 'fcm_service.dart';

class CivilianAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Civilian?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      final docRef = _firestore.collection('civilians').doc(user.uid);
      final docSnap = await docRef.get();

      Civilian civilian;
      if (!docSnap.exists) {
        civilian = Civilian(
          id: user.uid,
          name: user.displayName ?? 'Anonymous',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        await docRef.set(civilian.toMap());
      } else {
        civilian = Civilian.fromMap(docSnap.data()!);
      }

      // Initialize FCM after successful login
      await FCMService().initializeFCM(civilian.id, 'civilian');

      return civilian;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
