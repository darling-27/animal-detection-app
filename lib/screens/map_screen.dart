import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';

/// Map screen with Google Maps and real-time location
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _isLoading = true;
  bool _showHeatmap = false;
  String _selectedZone = 'All';
  StreamSubscription<Position>? _positionStream;

  // Google Maps API Key - configured in AndroidManifest.xml

  // Default location (can be changed to user's area)
  static const LatLng _defaultLocation = LatLng(23.5432, 87.2341);

  // Zone markers with real coordinates
  final List<Map<String, dynamic>> _zones = [
    {
      'id': 'A',
      'name': 'Zone A - South Sector',
      'position': const LatLng(23.5412, 87.2311),
      'status': 'Active',
      'alerts': 2,
    },
    {
      'id': 'B',
      'name': 'Zone B - North Sector',
      'position': const LatLng(23.5462, 87.2381),
      'status': 'Active',
      'alerts': 5,
    },
    {
      'id': 'C',
      'name': 'Zone C - East Sector',
      'position': const LatLng(23.5452, 87.2391),
      'status': 'Active',
      'alerts': 1,
    },
    {
      'id': 'D',
      'name': 'Zone D - West Sector',
      'position': const LatLng(23.5392, 87.2291),
      'status': 'Warning',
      'alerts': 3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _setupZoneMarkers();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  /// Initialize location services
  Future<void> _initializeLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        setState(() => _isLoading = false);
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        setState(() => _isLoading = false);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      }

      // Start listening to location updates
      _startLocationUpdates();
    } catch (e) {
      print('Error initializing location: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Start listening to location updates
  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            if (mounted) {
              setState(() {
                _currentPosition = position;
              });
              _updateCurrentLocationMarker();
            }
          },
        );
  }

  /// Setup zone markers
  void _setupZoneMarkers() {
    final markers = <Marker>{};

    for (var zone in _zones) {
      final zoneId = zone['id'] as String;
      final zoneStatus = zone['status'] as String;

      Color markerColor;
      if (zoneStatus == 'Warning') {
        markerColor = AppTheme.warningRed;
      } else if ((zone['alerts'] as int) > 3) {
        markerColor = AppTheme.alertRed;
      } else {
        markerColor = AppTheme.lightGreen;
      }

      markers.add(
        Marker(
          markerId: MarkerId(zoneId),
          position: zone['position'] as LatLng,
          infoWindow: InfoWindow(
            title: zone['name'] as String,
            snippet: '${zone['alerts']} alerts - ${zone['status']}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(markerColor),
          ),
          onTap: () => _showZoneDetails(zone),
        ),
      );
    }

    setState(() => _markers = markers);
    _setupZoneCircles();
  }

  /// Setup zone circles (detection radius)
  void _setupZoneCircles() {
    final circles = <Circle>{};

    for (var zone in _zones) {
      circles.add(
        Circle(
          circleId: CircleId(zone['id'] as String),
          center: zone['position'] as LatLng,
          radius: 500, // 500 meters radius
          fillColor:
              (zone['status'] == 'Warning'
                      ? AppTheme.warningRed
                      : AppTheme.lightGreen)
                  .withValues(alpha: 0.1),
          strokeColor: zone['status'] == 'Warning'
              ? AppTheme.warningRed
              : AppTheme.lightGreen,
          strokeWidth: 2,
        ),
      );
    }

    setState(() => _circles = circles);
  }

  /// Get marker hue from color
  double _getMarkerHue(Color color) {
    if (color == AppTheme.alertRed) return BitmapDescriptor.hueRed;
    if (color == AppTheme.warningRed) return BitmapDescriptor.hueOrange;
    return BitmapDescriptor.hueGreen;
  }

  /// Update current location marker
  void _updateCurrentLocationMarker() {
    if (_currentPosition == null) return;

    final currentMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Current Location'),
      zIndexInt: 100,
    );

    setState(() {
      _markers = {
        ..._markers.where((m) => m.markerId.value != 'current_location'),
        currentMarker,
      };
    });
  }

  /// Show zone details in bottom sheet
  void _showZoneDetails(Map<String, dynamic> zone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
                    color: AppTheme.forestGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppTheme.lightGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zone ${zone['id']}',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        zone['name'],
                        style: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Status', zone['status'], AppTheme.lightGreen),
                _buildStatItem(
                  'Alerts',
                  '${zone['alerts']}',
                  AppTheme.alertRed,
                ),
                _buildStatItem('Radius', '500m', AppTheme.lightGreen),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToZone(zone['position'] as LatLng);
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.forestGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _centerOnZone(zone['position'] as LatLng);
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Center'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.lightGreen,
                      side: const BorderSide(color: AppTheme.lightGreen),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Navigate to specific zone
  void _navigateToZone(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }

  /// Center map on zone
  void _centerOnZone(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  /// Toggle heatmap mode
  void _toggleHeatmap() {
    setState(() => _showHeatmap = !_showHeatmap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Google Map
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.lightGreen,
                    ),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition != null
                          ? LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            )
                          : _defaultLocation,
                      zoom: 14,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      // Set map style for dark theme
                      _setMapStyle();
                    },
                    markers: _markers,
                    circles: _showHeatmap ? _circles : {},
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                    padding: const EdgeInsets.only(top: 60),
                  ),

            // Header overlay
            Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),

            // Zone filter chips
            Positioned(top: 120, left: 0, right: 0, child: _buildZoneFilter()),

            // My Location Button
            Positioned(
              bottom: 100,
              right: 16,
              child: Column(
                children: [
                  // Heatmap toggle
                  FloatingActionButton.small(
                    heroTag: 'heatmap',
                    backgroundColor: AppTheme.cardBackground,
                    onPressed: _toggleHeatmap,
                    child: Icon(
                      _showHeatmap ? Icons.layers_clear : Icons.layers,
                      color: _showHeatmap
                          ? AppTheme.alertRed
                          : AppTheme.lightGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // My location button
                  FloatingActionButton.small(
                    heroTag: 'location',
                    backgroundColor: AppTheme.forestGreen,
                    onPressed: _goToCurrentLocation,
                    child: const Icon(Icons.my_location, color: AppTheme.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Set dark map style
  void _setMapStyle() {
    // Note: For production, you should use a JSON style string
    // This is a simplified version
  }

  /// Build header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkBackground.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Detection Map',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (_currentPosition != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.gps_fixed,
                        size: 14,
                        color: AppTheme.lightGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Live',
                        style: TextStyle(
                          color: AppTheme.lightGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build zone filter chips
  Widget _buildZoneFilter() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildZoneChip('All'),
          const SizedBox(width: 8),
          _buildZoneChip('A'),
          const SizedBox(width: 8),
          _buildZoneChip('B'),
          const SizedBox(width: 8),
          _buildZoneChip('C'),
          const SizedBox(width: 8),
          _buildZoneChip('D'),
        ],
      ),
    );
  }

  Widget _buildZoneChip(String zone) {
    final isSelected = _selectedZone == zone;
    return FilterChip(
      label: Text(
        zone == 'All' ? 'All Zones' : 'Zone $zone',
        style: TextStyle(
          color: isSelected
              ? AppTheme.white
              : AppTheme.white.withValues(alpha: 0.7),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedZone = zone);
        if (zone != 'All') {
          final zoneData = _zones.firstWhere((z) => z['id'] == zone);
          _centerOnZone(zoneData['position'] as LatLng);
        } else {
          _goToCurrentLocation();
        }
      },
      backgroundColor: AppTheme.cardBackground,
      selectedColor: AppTheme.forestGreen,
      checkmarkColor: AppTheme.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  /// Go to current location
  void _goToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 16,
          ),
        ),
      );
    } else {
      _initializeLocation();
    }
  }
}
