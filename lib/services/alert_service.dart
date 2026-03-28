import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_data.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AlertData>> getActiveAlerts() {
    return _firestore
        .collection('detections')
        .where('isDangerous', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AlertData(
          id: doc.id,
          animalType: data['animalType'] ?? 'Unknown',
          timestamp:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          severity: _getSeverity(data['animalType'] ?? ''),
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          location: data['location'] ?? 'Unknown',
        );
      }).toList();
    });
  }

  String _getSeverity(String animalType) {
    const highSeverity = [
      'tiger', 'lion', 'leopard', 'bear', 'crocodile', 'rhinoceros'
    ];
    const mediumSeverity = [
      'elephant', 'wolf', 'hyena', 'cheetah', 'panther', 'boar', 'bison'
    ];
    final name = animalType.toLowerCase();
    if (highSeverity.contains(name)) return 'HIGH';
    if (mediumSeverity.contains(name)) return 'MEDIUM';
    return 'LOW';
  }
}