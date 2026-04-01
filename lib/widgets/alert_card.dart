import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/alert_data.dart';
import '../screens/alert_map_screen.dart';

// ─── Colors missing from AppTheme (main.dart not modified) ───
const Color _kSeverityHigh = Color(0xFFFF1744);
const Color _kSeverityMedium = Color(0xFFFF9100);
const Color _kSeverityLow = Color(0xFFFFEA00);

class AlertCard extends StatelessWidget {
  final AlertData alert;
  final String? distanceText;
  final bool showMapOnTap;

  const AlertCard({
    super.key,
    required this.alert,
    this.distanceText,
    this.showMapOnTap = false,
  });

  Color get _severityColor {
    switch (alert.severity) {
      case 'HIGH':
        return _kSeverityHigh;
      case 'MEDIUM':
        return _kSeverityMedium;
      default:
        return _kSeverityLow;
    }
  }

  IconData get _animalIcon {
    switch (alert.animalType.toLowerCase()) {
      case 'tiger':
      case 'lion':
      case 'leopard':
      case 'cheetah':
      case 'panther':
      case 'bear':
      case 'elephant':
      case 'wolf':
      case 'hyena':
      case 'zebra':
        return Icons.pets;
      case 'crocodile':
        return Icons.water;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatted =
        DateFormat('hh:mm a · MMM dd').format(alert.timestamp);

    return GestureDetector(
      onTap: () {
        if (showMapOnTap) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlertMapScreen(alert: alert),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground, // ✅ FIX: was darkCard
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _severityColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _severityColor.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top Section: Info ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Animal Icon Container
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _severityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _severityColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      _animalIcon,
                      color: _severityColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                alert.animalType.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _severityColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _severityColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                alert.severity,
                                style: TextStyle(
                                  color: _severityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white38, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                alert.location,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.white38, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              timeFormatted,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow + distance
                  Column(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: _severityColor.withValues(alpha: 0.7),
                        size: 24,
                      ),
                      if (distanceText != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          distanceText!,
                          style: TextStyle(
                            color: _severityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      const Text(
                        'View Map',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Bottom Gradient Bar ──
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _severityColor.withValues(alpha: 0.8),
                    _severityColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
