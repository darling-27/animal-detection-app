import 'package:flutter/material.dart';
import '../main.dart';
import '../models/map_marker_data.dart';
import '../widgets/map_marker.dart';
import '../widgets/map_grid_painter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final markers = [
      MapMarkerData(
        animalType: 'Tiger',
        latitude: 28.6139,
        longitude: 77.2090,
        isDangerous: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      MapMarkerData(
        animalType: 'Elephant',
        latitude: 28.6145,
        longitude: 77.2095,
        isDangerous: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      MapMarkerData(
        animalType: 'Leopard',
        latitude: 28.6150,
        longitude: 77.2100,
        isDangerous: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
      ),
      MapMarkerData(
        animalType: 'Deer',
        latitude: 28.6155,
        longitude: 77.2105,
        isDangerous: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Detection Map'),
        backgroundColor: AppTheme.darkBackground,
        actions: [
          IconButton(icon: const Icon(Icons.layers), onPressed: () {}),
          IconButton(icon: const Icon(Icons.my_location), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.cardBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(
                  color: AppTheme.alertRed,
                  label: 'Dangerous',
                  icon: Icons.warning,
                ),
                _LegendItem(
                  color: AppTheme.lightGreen,
                  label: 'Safe',
                  icon: Icons.pets,
                ),
                _LegendItem(
                  color: AppTheme.forestGreen,
                  label: 'Officer',
                  icon: Icons.shield,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.forestGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Stack(
                children: [
                  CustomPaint(painter: MapGridPainter(), size: Size.infinite),
                  ...markers.asMap().entries.map((entry) {
                    return Positioned(
                      left: 50.0 + (entry.key * 60),
                      top: 50.0 + (entry.key * 50),
                      child: MapMarker(
                        marker: entry.value,
                        onTap: () {
                          _showMarkerInfo(context, entry.value);
                        },
                      ),
                    );
                  }),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pets,
                            color: AppTheme.lightGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '4 Active Detections',
                            style: TextStyle(
                              color: AppTheme.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.cardBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '28.6139°N, 77.2090°E',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_location, size: 18),
                  label: const Text('Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkerInfo(BuildContext context, MapMarkerData marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: marker.isDangerous
                          ? AppTheme.alertRed.withValues(alpha: 0.2)
                          : AppTheme.lightGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      marker.isDangerous ? Icons.warning : Icons.pets,
                      color: marker.isDangerous
                          ? AppTheme.alertRed
                          : AppTheme.lightGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marker.animalType,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                        if (marker.isDangerous)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.alertRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DANGEROUS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _InfoItem(
                    icon: Icons.location_on,
                    label: 'Latitude',
                    value: '${marker.latitude.toStringAsFixed(4)}°N',
                  ),
                  const SizedBox(width: 24),
                  _InfoItem(
                    icon: Icons.location_on,
                    label: 'Longitude',
                    value: '${marker.longitude.toStringAsFixed(4)}°E',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoItem(
                icon: Icons.access_time,
                label: 'Detected',
                value: _formatTimestamp(marker.timestamp),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('VIEW DETAILS'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.lightGreen, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
