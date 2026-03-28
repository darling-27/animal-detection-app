import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryData {
  final String id;
  final String animalCategory;
  final String animalType;
  final double confidence;
  final String imageUrl;
  final bool isDangerous;
  final double latitude;
  final String location;
  final double longitude;
  final DateTime timestamp;

  HistoryData({
    required this.id,
    required this.animalCategory,
    required this.animalType,
    required this.confidence,
    required this.imageUrl,
    required this.isDangerous,
    required this.latitude,
    required this.location,
    required this.longitude,
    required this.timestamp,
  });

  factory HistoryData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryData(
      id: doc.id,
      animalCategory: data['animalCategory'] ?? '',
      animalType: data['animalType'] ?? '',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      isDangerous: data['isDangerous'] ?? false,
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      location: data['location'] ?? '',
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'animalCategory': animalCategory,
      'animalType': animalType,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'isDangerous': isDangerous,
      'latitude': latitude,
      'location': location,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Convert to the format your map/alert screen expects
  Map<String, dynamic> toAlertMap() {
    return {
      'id': id,
      'animalCategory': animalCategory,
      'animalType': animalType,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'isDangerous': isDangerous,
      'latitude': latitude,
      'location': location,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}