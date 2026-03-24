import 'package:flutter/material.dart';
import '../main.dart';

/// Alert screen for viewing and managing animal detection alerts
class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _alerts = [
    {
      'id': 1,
      'title': 'Wild Boar Detected',
      'zone': 'Zone B - North Sector',
      'time': '10 minutes ago',
      'severity': 'High',
      'animalType': 'Wild Boar',
      'imageUrl': null,
      'latitude': 23.5432,
      'longitude': 87.2341,
    },
    {
      'id': 2,
      'title': 'Deer Movement Detected',
      'zone': 'Zone A - South Sector',
      'time': '1 hour ago',
      'severity': 'Low',
      'animalType': 'Deer',
      'imageUrl': null,
      'latitude': 23.5412,
      'longitude': 87.2311,
    },
    {
      'id': 3,
      'title': 'Fox Spotted',
      'zone': 'Zone C - East Sector',
      'time': '2 hours ago',
      'severity': 'Medium',
      'animalType': 'Fox',
      'imageUrl': null,
      'latitude': 23.5452,
      'longitude': 87.2391,
    },
    {
      'id': 4,
      'title': 'Unknown Animal Detected',
      'zone': 'Zone D - West Sector',
      'time': '3 hours ago',
      'severity': 'High',
      'animalType': 'Unknown',
      'imageUrl': null,
      'latitude': 23.5392,
      'longitude': 87.2291,
    },
    {
      'id': 5,
      'title': 'Bird Flock Activity',
      'zone': 'Zone A - South Sector',
      'time': '5 hours ago',
      'severity': 'Low',
      'animalType': 'Bird',
      'imageUrl': null,
      'latitude': 23.5402,
      'longitude': 87.2301,
    },
  ];

  List<Map<String, dynamic>> get _filteredAlerts {
    if (_selectedFilter == 'All') return _alerts;
    return _alerts
        .where((alert) => alert['severity'] == _selectedFilter)
        .toList();
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'High':
        return AppTheme.alertRed;
      case 'Medium':
        return AppTheme.warningRed;
      default:
        return AppTheme.lightGreen;
    }
  }

  IconData _getAnimalIcon(String animalType) {
    switch (animalType.toLowerCase()) {
      case 'wild boar':
        return Icons.pets;
      case 'deer':
        return Icons.cruelty_free;
      case 'fox':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: const Text(
          'Alerts',
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.white),
            onPressed: () {
              // Refresh alerts
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('High'),
                const SizedBox(width: 8),
                _buildFilterChip('Medium'),
                const SizedBox(width: 8),
                _buildFilterChip('Low'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Alerts List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredAlerts.length,
              itemBuilder: (context, index) {
                final alert = _filteredAlerts[index];
                return _buildAlertCard(alert);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.forestGreen,
        onPressed: () {
          // Create new alert manually
          _showCreateAlertDialog(context);
        },
        child: const Icon(Icons.add, color: AppTheme.white),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(
        filter,
        style: TextStyle(
          color: isSelected
              ? AppTheme.white
              : AppTheme.white.withValues(alpha: 0.7),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = filter);
      },
      backgroundColor: AppTheme.cardBackground,
      selectedColor: AppTheme.forestGreen,
      checkmarkColor: AppTheme.white,
      side: BorderSide(
        color: isSelected ? AppTheme.forestGreen : Colors.transparent,
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final severityColor = _getSeverityColor(alert['severity']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Alert Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAnimalIcon(alert['animalType']),
                    color: severityColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'],
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert['animalType'],
                        style: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    alert['severity'],
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alert Details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alert['zone'],
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alert['time'],
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      size: 16,
                      color: AppTheme.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lat: ${alert['latitude']}, Long: ${alert['longitude']}',
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to map screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 18, color: AppTheme.lightGreen),
                        SizedBox(width: 8),
                        Text(
                          'View Map',
                          style: TextStyle(color: AppTheme.lightGreen),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppTheme.white.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Mark alert as resolved
                      _resolveAlert(alert['id']);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppTheme.lightGreen,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Resolve',
                          style: TextStyle(color: AppTheme.lightGreen),
                        ),
                      ],
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

  // Resolve an alert - remove from active list
  void _resolveAlert(int alertId) {
    setState(() {
      _alerts.removeWhere((alert) => alert['id'] == alertId);
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert resolved successfully'),
        backgroundColor: AppTheme.lightGreen,
      ),
    );
  }

  void _showCreateAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Create Alert',
          style: TextStyle(color: AppTheme.white),
        ),
        content: const Text(
          'Manual alert creation feature',
          style: TextStyle(color: AppTheme.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
