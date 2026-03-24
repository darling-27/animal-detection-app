import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service class for Firebase operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _isInitialized = false;

  /// Initialize Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;

  /// Get current user
  User? get currentUser => _auth?.currentUser;

  /// Authenticate user with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth?.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Error signing in: ${e.message}');
      rethrow;
    }
  }

  /// Register user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth?.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Error creating user: ${e.message}');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Get detections collection
  CollectionReference<Map<String, dynamic>> get detectionsCollection {
    return _firestore!.collection('detections');
  }

  /// Get alerts collection
  CollectionReference<Map<String, dynamic>> get alertsCollection {
    return _firestore!.collection('alerts');
  }

  /// Get users collection
  CollectionReference<Map<String, dynamic>> get usersCollection {
    return _firestore!.collection('users');
  }

  /// Add a new detection record
  Future<DocumentReference<Map<String, dynamic>>> addDetection({
    required String animalType,
    required String zone,
    required double latitude,
    required double longitude,
    required int confidence,
  }) async {
    try {
      return await detectionsCollection.add({
        'animalType': animalType,
        'zone': zone,
        'latitude': latitude,
        'longitude': longitude,
        'confidence': confidence,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUser?.uid,
      });
    } catch (e) {
      print('Error adding detection: $e');
      rethrow;
    }
  }

  /// Get all detections
  Future<QuerySnapshot<Map<String, dynamic>>> getDetections({
    int? limit,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      var query = detectionsCollection.orderBy(
        orderBy ?? 'timestamp',
        descending: descending,
      );

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      print('Error getting detections: $e');
      rethrow;
    }
  }

  /// Stream detections in real-time
  Stream<QuerySnapshot<Map<String, dynamic>>> streamDetections({int? limit}) {
    var query = detectionsCollection.orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Add a new alert
  Future<DocumentReference<Map<String, dynamic>>> addAlert({
    required String title,
    required String zone,
    required String severity,
    required String animalType,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await alertsCollection.add({
        'title': title,
        'zone': zone,
        'severity': severity,
        'animalType': animalType,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'isResolved': false,
        'userId': currentUser?.uid,
      });
    } catch (e) {
      print('Error adding alert: $e');
      rethrow;
    }
  }

  /// Get all alerts
  Future<QuerySnapshot<Map<String, dynamic>>> getAlerts({
    bool? isResolved,
    int? limit,
  }) async {
    try {
      var query = alertsCollection.orderBy('timestamp', descending: true);

      if (isResolved != null) {
        query = query.where('isResolved', isEqualTo: isResolved);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      print('Error getting alerts: $e');
      rethrow;
    }
  }

  /// Stream alerts in real-time
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAlerts({
    bool? isResolved,
    int? limit,
  }) {
    var query = alertsCollection.orderBy('timestamp', descending: true);

    if (isResolved != null) {
      query = query.where('isResolved', isEqualTo: isResolved);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Resolve an alert
  Future<void> resolveAlert(String alertId) async {
    try {
      await alertsCollection.doc(alertId).update({
        'isResolved': true,
        'resolvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error resolving alert: $e');
      rethrow;
    }
  }

  /// Get user profile data
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserProfile(
    String userId,
  ) async {
    try {
      return await usersCollection.doc(userId).get();
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await usersCollection.doc(userId).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Create user profile
  Future<void> createUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await usersCollection.doc(userId).set(data);
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get detection statistics
  Future<Map<String, dynamic>> getDetectionStats() async {
    try {
      final detections = await detectionsCollection.get();
      final alerts = await alertsCollection.get();

      int totalDetections = detections.docs.length;
      int unresolvedAlerts = alerts.docs
          .where((doc) => doc['isResolved'] == false)
          .length;

      // Count by animal type
      Map<String, int> animalCounts = {};
      for (var doc in detections.docs) {
        String animalType = doc['animalType'] ?? 'Unknown';
        animalCounts[animalType] = (animalCounts[animalType] ?? 0) + 1;
      }

      return {
        'totalDetections': totalDetections,
        'unresolvedAlerts': unresolvedAlerts,
        'animalCounts': animalCounts,
      };
    } catch (e) {
      print('Error getting detection stats: $e');
      rethrow;
    }
  }
}
