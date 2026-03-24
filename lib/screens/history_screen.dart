import 'package:flutter/material.dart';
import '../main.dart';

/// History screen for viewing past detection records
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Today';

  final List<Map<String, dynamic>> _detections = [
    {
      'id': 1,
      'animalType': 'Wild Boar',
      'zone': 'Zone B',
      'time': '10:30 AM',
      'date': 'Today',
      'confidence': 95,
      'imageUrl': null,
    },
    {
      'id': 2,
      'animalType': 'Deer',
      'zone': 'Zone A',
      'time': '09:15 AM',
      'date': 'Today',
      'confidence': 88,
      'imageUrl': null,
    },
    {
      'id': 3,
      'animalType': 'Fox',
      'zone': 'Zone C',
      'time': '08:45 AM',
      'date': 'Today',
      'confidence': 92,
      'imageUrl': null,
    },
    {
      'id': 4,
      'animalType': 'Unknown',
      'zone': 'Zone D',
      'time': '07:20 AM',
      'date': 'Today',
      'confidence': 75,
      'imageUrl': null,
    },
    {
      'id': 5,
      'animalType': 'Bird Flock',
      'zone': 'Zone A',
      'time': '06:00 AM',
      'date': 'Today',
      'confidence': 98,
      'imageUrl': null,
    },
    {
      'id': 6,
      'animalType': 'Deer',
      'zone': 'Zone B',
      'time': '11:30 PM',
      'date': 'Yesterday',
      'confidence': 90,
      'imageUrl': null,
    },
    {
      'id': 7,
      'animalType': 'Wild Boar',
      'zone': 'Zone C',
      'time': '10:15 PM',
      'date': 'Yesterday',
      'confidence': 87,
      'imageUrl': null,
    },
    {
      'id': 8,
      'animalType': 'Fox',
      'zone': 'Zone A',
      'time': '08:00 PM',
      'date': 'Yesterday',
      'confidence': 94,
      'imageUrl': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredDetections {
    return _detections.where((d) => d['date'] == _selectedPeriod).toList();
  }

  IconData _getAnimalIcon(String animalType) {
    switch (animalType.toLowerCase()) {
      case 'wild boar':
        return Icons.pets;
      case 'deer':
        return Icons.cruelty_free;
      case 'fox':
        return Icons.pets;
      case 'bird flock':
        return Icons.flutter_dash;
      default:
        return Icons.help_outline;
    }
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 90) return AppTheme.lightGreen;
    if (confidence >= 75) return AppTheme.forestGreen;
    return AppTheme.warningRed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detection History',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppTheme.white),
                    onPressed: () {
                      _showSearchDialog();
                    },
                  ),
                ],
              ),
            ),

            // Period Filter
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPeriodChip('Today'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('Yesterday'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('This Week'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('This Month'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.forestGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: AppTheme.white,
                unselectedLabelColor: AppTheme.white.withValues(alpha: 0.5),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Animals'),
                  Tab(text: 'Alerts'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.pets,
                    label: 'Total',
                    value: '${_filteredDetections.length}',
                    color: AppTheme.lightGreen,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.pets,
                    label: 'Animals',
                    value:
                        '${_filteredDetections.where((d) => d['animalType'] != 'Unknown').length}',
                    color: AppTheme.forestGreen,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.warning,
                    label: 'Alerts',
                    value:
                        '${_filteredDetections.where((d) => d['animalType'] == 'Wild Boar').length}',
                    color: AppTheme.alertRed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detection List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All Tab
                  _buildDetectionList(_filteredDetections),
                  // Animals Tab
                  _buildDetectionList(
                    _filteredDetections
                        .where((d) => d['animalType'] != 'Unknown')
                        .toList(),
                  ),
                  // Alerts Tab
                  _buildDetectionList(
                    _filteredDetections
                        .where(
                          (d) =>
                              d['animalType'] == 'Wild Boar' ||
                              d['animalType'] == 'Unknown',
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      label: Text(
        period,
        style: TextStyle(
          color: isSelected
              ? AppTheme.white
              : AppTheme.white.withValues(alpha: 0.7),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedPeriod = period);
      },
      backgroundColor: AppTheme.cardBackground,
      selectedColor: AppTheme.forestGreen,
      checkmarkColor: AppTheme.white,
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionList(List<Map<String, dynamic>> detections) {
    if (detections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 60,
              color: AppTheme.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No detections found',
              style: TextStyle(
                color: AppTheme.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: detections.length,
      itemBuilder: (context, index) {
        final detection = detections[index];
        return _buildDetectionCard(detection);
      },
    );
  }

  Widget _buildDetectionCard(Map<String, dynamic> detection) {
    final confidenceColor = _getConfidenceColor(detection['confidence']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.forestGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getAnimalIcon(detection['animalType']),
            color: AppTheme.lightGreen,
            size: 24,
          ),
        ),
        title: Text(
          detection['animalType'],
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppTheme.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  detection['zone'],
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppTheme.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  detection['time'],
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: confidenceColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${detection['confidence']}%',
                style: TextStyle(
                  color: confidenceColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence',
              style: TextStyle(
                color: AppTheme.white.withValues(alpha: 0.3),
                fontSize: 10,
              ),
            ),
          ],
        ),
        onTap: () {
          _showDetectionDetails(detection);
        },
      ),
    );
  }

  void _showDetectionDetails(Map<String, dynamic> detection) {
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getAnimalIcon(detection['animalType']),
                    color: AppTheme.lightGreen,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detection['animalType'],
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        detection['zone'],
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
                _buildDetailStat('Time', detection['time'], AppTheme.white),
                _buildDetailStat(
                  'Confidence',
                  '${detection['confidence']}%',
                  _getConfidenceColor(detection['confidence']),
                ),
                _buildDetailStat('Date', detection['date'], AppTheme.white),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.map),
                label: const Text('View on Map'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.lightGreen,
                  side: const BorderSide(color: AppTheme.lightGreen),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
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

  // Search functionality
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Search History',
          style: TextStyle(color: AppTheme.white),
        ),
        content: TextField(
          style: const TextStyle(color: AppTheme.white),
          decoration: InputDecoration(
            hintText: 'Search by animal type or zone',
            hintStyle: TextStyle(color: AppTheme.white.withValues(alpha: 0.5)),
            prefixIcon: const Icon(Icons.search, color: AppTheme.lightGreen),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _performSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    // Filter detections based on search query
    setState(() {
      _selectedPeriod = 'All';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $query'),
        backgroundColor: AppTheme.forestGreen,
      ),
    );
  }
}
