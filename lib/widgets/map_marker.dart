import 'package:flutter/material.dart';
import '../main.dart';
import '../models/map_marker_data.dart';

class MapMarker extends StatelessWidget {
  final MapMarkerData marker;
  final VoidCallback onTap;

  const MapMarker({super.key, required this.marker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: marker.isDangerous ? AppTheme.alertRed : AppTheme.lightGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
              (marker.isDangerous ? AppTheme.alertRed : AppTheme.lightGreen)
                  .withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.location_on, color: AppTheme.white, size: 24),
      ),
    );
  }
}
