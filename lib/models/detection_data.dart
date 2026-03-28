class DetectionData {
  final String animalType;
  final double confidence;
  final DateTime timestamp;
  final String imageUrl;
  final bool isDangerous;
  final double latitude;
  final double longitude;

  DetectionData({
    required this.animalType,
    required this.confidence,
    required this.timestamp,
    required this.imageUrl,
    required this.isDangerous,
    required this.latitude,
    required this.longitude,
  });
}
