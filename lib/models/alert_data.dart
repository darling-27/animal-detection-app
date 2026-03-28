class AlertData {
  final String id;
  final String animalType;
  final DateTime timestamp;
  final String severity;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String location;

  AlertData({
    required this.id,
    required this.animalType,
    required this.timestamp,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.location,
  });

  String get severityEmoji {
    switch (severity) {
      case 'HIGH':
        return '🔴';
      case 'MEDIUM':
        return '🟠';
      default:
        return '🟡';
    }
  }
}