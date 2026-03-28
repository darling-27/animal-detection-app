import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/alert_data.dart';

// ─── Colors missing from AppTheme (main.dart not modified) ───
const Color _kAccentBlue = Color(0xFF42A5F5);
const Color _kSeverityHigh = Color(0xFFFF1744);
const Color _kSeverityMedium = Color(0xFFFF9100);
const Color _kSeverityLow = Color(0xFFFFEA00);

class AlertMapScreen extends StatefulWidget {
  final AlertData alert;

  const AlertMapScreen({super.key, required this.alert});

  @override
  State<AlertMapScreen> createState() => _AlertMapScreenState();
}

class _AlertMapScreenState extends State<AlertMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  Position? _userPosition;
  bool _locationLoading = true;
  bool _locationError = false;
  String _errorMessage = '';
  double? _distanceMeters;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fetchUserLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────
  // SEVERITY COLOR
  // ─────────────────────────────────────
  Color get _severityColor {
    switch (widget.alert.severity) {
      case 'HIGH':
        return _kSeverityHigh;
      case 'MEDIUM':
        return _kSeverityMedium;
      default:
        return _kSeverityLow;
    }
  }

  // ─────────────────────────────────────
  // LOCATION
  // ─────────────────────────────────────
  Future<void> _fetchUserLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = false;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationLoading = false;
          _locationError = true;
          _errorMessage = 'Location services are disabled. Turn on GPS.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationLoading = false;
          _locationError = true;
          _errorMessage =
          'Location permission permanently denied. Enable in Settings.';
        });
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _locationLoading = false;
          _locationError = true;
          _errorMessage = 'Location permission denied.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.alert.latitude,
        widget.alert.longitude,
      );

      if (mounted) {
        setState(() {
          _userPosition = position;
          _distanceMeters = distance;
          _locationLoading = false;
          _locationError = false;
        });

        // Auto-fit after location is fetched
        Future.delayed(
            const Duration(milliseconds: 300), _fitBothMarkers);
      }
    } catch (e) {
      debugPrint('❌ Location error: $e');
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _locationError = true;
          _errorMessage = 'Failed to get location: $e';
        });
      }
    }
  }

  // ─────────────────────────────────────
  // MAP HELPERS
  // ─────────────────────────────────────
  LatLng get _animalLatLng =>
      LatLng(widget.alert.latitude, widget.alert.longitude);

  LatLng? get _userLatLng => _userPosition != null
      ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
      : null;

  LatLngBounds? get _bounds {
    if (_userLatLng == null) return null;
    final sw = LatLng(
      min(_userLatLng!.latitude, _animalLatLng.latitude),
      min(_userLatLng!.longitude, _animalLatLng.longitude),
    );
    final ne = LatLng(
      max(_userLatLng!.latitude, _animalLatLng.latitude),
      max(_userLatLng!.longitude, _animalLatLng.longitude),
    );
    return LatLngBounds(sw, ne);
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  void _fitBothMarkers() {
    if (_bounds != null) {
      try {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: _bounds!,
            padding: const EdgeInsets.all(80),
          ),
        );
      } catch (e) {
        debugPrint('Map fit error: $e');
      }
    }
  }

  void _centerOnUser() {
    if (_userLatLng != null) {
      _mapController.move(_userLatLng!, 15);
    }
  }

  void _centerOnAnimal() {
    _mapController.move(_animalLatLng, 15);
  }

  // ─────────────────────────────────────
  // ENHANCED DIRECTIONS FUNCTIONALITY
  // ─────────────────────────────────────
  // ─────────────────────────────────────
// ENHANCED DIRECTIONS FUNCTIONALITY WITH MULTIPLE FALLBACKS
// ─────────────────────────────────────
  Future<void> _openInGoogleMaps() async {
    if (_userPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enable location to get directions'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      // Get coordinates for cleaner code
      final userLat = _userPosition!.latitude;
      final userLng = _userPosition!.longitude;
      final animalLat = widget.alert.latitude;
      final animalLng = widget.alert.longitude;

      // List of URL schemes to try in order
      final List<Map<String, String>> urlOptions = [
        // 1. Google Maps App with navigation (Android & iOS)
        {
          'url': 'google.navigation:q=$animalLat,$animalLng&mode=d',
          'scheme': 'google.navigation'
        },
        // 2. Google Maps App with directions (Android & iOS)
        {
          'url': 'https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLng&destination=$animalLat,$animalLng&travelmode=driving',
          'scheme': 'https'
        },
        // 3. Web-based Google Maps (fallback)
        {
          'url': 'https://www.google.com/maps/dir/$userLat,$userLng/$animalLat,$animalLng',
          'scheme': 'https'
        },
        // 4. Apple Maps (iOS fallback)
        {
          'url': 'http://maps.apple.com/?saddr=$userLat,$userLng&daddr=$animalLat,$animalLng&dirflg=d',
          'scheme': 'http'
        }
      ];

      bool launched = false;

      for (final option in urlOptions) {
        final Uri uri = Uri.parse(option['url']!);

        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            launched = true;
            break;
          }
        } catch (e) {
          debugPrint('Failed to launch ${option['scheme']}: $e');
          continue;
        }
      }

      if (!launched) {
        // Final fallback: open in web browser
        final webUrl = Uri.parse('https://www.google.com/maps');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl);
          launched = true;
        }
      }

      if (!launched) {
        throw Exception('Could not launch any map application');
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');

      // Show detailed error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to open maps', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Error: ${e.toString()}',
                style: const TextStyle(fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your internet connection or install Google Maps app',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // ─────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final timeFormatted =
    DateFormat('hh:mm a · MMM dd, yyyy').format(alert.timestamp);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // ── MAP ──
          _buildMap(),

          // ── TOP GRADIENT OVERLAY ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.darkBackground.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── CUSTOM APP BAR ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _severityColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pets,
                            color: _severityColor, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${alert.animalType.toUpperCase()} DETECTED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _severityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
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
                  ),
                ),
              ],
            ),
          ),

          // ── RIGHT SIDE FABs ──
          Positioned(
            right: 16,
            bottom: 300,
            child: Column(
              children: [
                _buildCircleButton(
                  icon: Icons.fit_screen,
                  onTap: _fitBothMarkers,
                  tooltip: 'Fit Both',
                  color: _kAccentBlue,
                ),
                const SizedBox(height: 10),
                _buildCircleButton(
                  icon: Icons.my_location,
                  onTap: _centerOnUser,
                  tooltip: 'My Location',
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                _buildCircleButton(
                  icon: Icons.pets,
                  onTap: _centerOnAnimal,
                  tooltip: 'Animal Location',
                  color: _severityColor,
                ),
                const SizedBox(height: 10),
                _buildCircleButton(
                  icon: Icons.directions,
                  onTap: _openInGoogleMaps,
                  tooltip: 'Google Maps',
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          // ── BOTTOM INFO SHEET ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(alert, timeFormatted),
          ),

          // ── LOADING OVERLAY ──
          if (_locationLoading)
            Positioned.fill(
              child: Container(
                color: AppTheme.darkBackground.withValues(alpha: 0.6),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: _kAccentBlue),
                      SizedBox(height: 16),
                      Text(
                        'Fetching your location...',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── ERROR BANNER ──
          if (_locationError && !_locationLoading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.red.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchUserLocation,
                      child: const Text('Retry',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // MAP WIDGET
  // ─────────────────────────────────────
  Widget _buildMap() {
    final initialCenter = _userLatLng ?? _animalLatLng;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 13,
        minZoom: 3,
        maxZoom: 18,
      ),
      children: [
        // ── Tile Layer (Dark theme) ──
        TileLayer(
          urlTemplate:
          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.wildguard.app',
        ),

        // ── Polyline (connection line) ──
        if (_userLatLng != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [_userLatLng!, _animalLatLng],
                strokeWidth: 3,
                color: _severityColor.withValues(alpha: 0.7),
              ),
            ],
          ),

        // ── Danger Zone Circles ──
        CircleLayer(
          circles: [
            CircleMarker(
              point: _animalLatLng,
              radius: 200,
              color: _severityColor.withValues(alpha: 0.1),
              borderColor: _severityColor.withValues(alpha: 0.4),
              borderStrokeWidth: 2,
              useRadiusInMeter: true,
            ),
            CircleMarker(
              point: _animalLatLng,
              radius: 500,
              color: _severityColor.withValues(alpha: 0.05),
              borderColor: _severityColor.withValues(alpha: 0.2),
              borderStrokeWidth: 1,
              useRadiusInMeter: true,
            ),
          ],
        ),

        // ── Markers ──
        MarkerLayer(
          markers: [
            // ── Animal Marker (pulsing) ──
            Marker(
              point: _animalLatLng,
              width: 60,
              height: 60,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _severityColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _severityColor.withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── User Marker ──
            if (_userLatLng != null)
              Marker(
                point: _userLatLng!,
                width: 50,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: _kAccentBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccentBlue.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // BOTTOM SHEET
  // ─────────────────────────────────────
  Widget _buildBottomSheet(AlertData alert, String timeFormatted) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
              color: _severityColor.withValues(alpha: 0.3), width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // ── Animal Info Row ──
              Row(
                children: [
                  // Animal image or icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _severityColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: alert.imageUrl.isNotEmpty
                          ? Image.network(
                        alert.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _severityColor.withValues(alpha: 0.2),
                          child: Icon(Icons.pets,
                              color: _severityColor, size: 30),
                        ),
                      )
                          : Container(
                        color: _severityColor.withValues(alpha: 0.2),
                        child: Icon(Icons.pets,
                            color: _severityColor, size: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.animalType.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white38, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                alert.location,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.white38, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              timeFormatted,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Stats Row 1 ──
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.social_distance,
                    label: 'Distance',
                    value: _distanceMeters != null
                        ? _formatDistance(_distanceMeters!)
                        : 'N/A',
                    color: _kAccentBlue,
                  ),
                  const SizedBox(width: 10),
                  _buildStatChip(
                    icon: Icons.gps_fixed,
                    label: 'Animal Coords',
                    value:
                    '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
                    color: _severityColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Stats Row 2 ──
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.my_location,
                    label: 'Your Coords',
                    value: _userPosition != null
                        ? '${_userPosition!.latitude.toStringAsFixed(4)}, ${_userPosition!.longitude.toStringAsFixed(4)}'
                        : 'Unavailable',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  _buildStatChip(
                    icon: Icons.warning_amber,
                    label: 'Severity',
                    value: alert.severity,
                    color: _severityColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Action Buttons ──
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openInGoogleMaps,
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _fetchUserLocation,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // REUSABLE WIDGETS
  // ─────────────────────────────────────
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(color: color, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color color = Colors.white,
  }) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}