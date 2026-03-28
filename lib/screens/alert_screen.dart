import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import '../models/alert_data.dart';
import '../widgets/alert_card.dart';
import '../services/alert_service.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  Position? _userPosition;
  bool _locationLoading = true;
  final AlertService _alertService = AlertService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _requestLocationPermission();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _locationLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationLoading = false);
      if (mounted) {
        _showLocationSnackbar(
          'Location services are disabled. Please turn on GPS.',
          actionLabel: 'Open Settings',
          onAction: Geolocator.openLocationSettings,
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationLoading = false);
      if (mounted) {
        _showLocationSnackbar(
          'Location permission permanently denied. Enable it in App Settings.',
          actionLabel: 'App Settings',
          onAction: Geolocator.openAppSettings,
        );
      }
      return;
    }

    if (permission == LocationPermission.denied) {
      setState(() => _locationLoading = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _userPosition = position;
          _locationLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Location fetch error: $e');
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  void _showLocationSnackbar(
      String message, {
        required String actionLabel,
        required VoidCallback onAction,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onAction,
        ),
      ),
    );
  }

  double? _calculateDistance(AlertData alert) {
    if (_userPosition == null) return null;
    return Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      alert.latitude,
      alert.longitude,
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)}m away';
    return '${(meters / 1000).toStringAsFixed(1)}km away';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: AppTheme.darkBackground,
        actions: [
          if (_locationLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Refresh Location',
              onPressed: _requestLocationPermission,
            ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<List<AlertData>>(
        stream: _alertService.getActiveAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.alertRed),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading alerts: ${snapshot.error}',
                style: const TextStyle(color: Colors.white54),
              ),
            );
          }

          final alerts = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Pulse Alert Banner ──
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: alerts.isEmpty ? 1.0 : _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: alerts.isEmpty
                              ? [AppTheme.darkGreen, AppTheme.forestGreen]
                              : [AppTheme.alertRed, AppTheme.warningRed],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (alerts.isEmpty
                                ? AppTheme.darkGreen
                                : AppTheme.alertRed)
                                .withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            alerts.isEmpty
                                ? Icons.check_circle
                                : Icons.warning_amber,
                            color: AppTheme.white,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alerts.isEmpty
                                      ? 'ALL CLEAR'
                                      : '${alerts.length} ACTIVE ALERT${alerts.length > 1 ? 'S' : ''}',
                                  style: const TextStyle(
                                    color: AppTheme.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  alerts.isEmpty
                                      ? 'No dangerous animals detected'
                                      : 'Dangerous animals detected nearby',
                                  style: TextStyle(
                                    color:
                                    AppTheme.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // ── Location Unavailable Banner ──
              if (_userPosition == null && !_locationLoading) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_off,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Location unavailable — distance cannot be calculated',
                          style:
                          TextStyle(color: Colors.orange, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: _requestLocationPermission,
                        child: const Text(
                          'Enable',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Alert Cards ──
              if (alerts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.shield, size: 64, color: Colors.white24),
                        SizedBox(height: 16),
                        Text(
                          'No active alerts',
                          style:
                          TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...alerts.map((alert) {
                  final distanceMeters = _calculateDistance(alert);
                  final distanceText = distanceMeters != null
                      ? _formatDistance(distanceMeters)
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AlertCard(
                      alert: alert,
                      distanceText: distanceText,
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}