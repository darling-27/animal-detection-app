import 'package:flutter/material.dart';
import '../main.dart';

/// Home screen - main dashboard of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardTab(),
    const _AlertsTab(),
    const _MapTab(),
    const _HistoryTab(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.cardBackground,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: AppTheme.forestGreen.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppTheme.white),
            selectedIcon: Icon(Icons.home, color: AppTheme.lightGreen),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined, color: AppTheme.white),
            selectedIcon: Icon(Icons.notifications, color: AppTheme.lightGreen),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined, color: AppTheme.white),
            selectedIcon: Icon(Icons.map, color: AppTheme.lightGreen),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined, color: AppTheme.white),
            selectedIcon: Icon(Icons.history, color: AppTheme.lightGreen),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

/// Dashboard tab content
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Wildlife Monitor',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: AppTheme.forestGreen,
                  child: const Icon(Icons.person, color: AppTheme.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Card
            _buildStatusCard(
              title: 'System Status',
              icon: Icons.check_circle,
              status: 'Active',
              color: AppTheme.lightGreen,
              description: 'All sensors monitoring正常',
            ),
            const SizedBox(height: 16),

            // Quick Stats
            const Text(
              'Quick Stats',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.pets,
                    label: 'Detections',
                    value: '12',
                    color: AppTheme.lightGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.warning_amber,
                    label: 'Alerts',
                    value: '3',
                    color: AppTheme.alertRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.location_on,
                    label: 'Active Zones',
                    value: '5',
                    color: AppTheme.earthBrown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.security,
                    label: 'Safe',
                    value: '98%',
                    color: AppTheme.forestGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.pets,
              title: 'Deer Detected',
              subtitle: 'Zone A - 5 minutes ago',
              color: AppTheme.lightGreen,
            ),
            _buildActivityItem(
              icon: Icons.warning,
              title: 'Wild Boar Alert',
              subtitle: 'Zone B - 1 hour ago',
              color: AppTheme.alertRed,
            ),
            _buildActivityItem(
              icon: Icons.pets,
              title: 'Fox Detected',
              subtitle: 'Zone C - 2 hours ago',
              color: AppTheme.lightGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required IconData icon,
    required String status,
    required Color color,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppTheme.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

/// Alerts tab content
class _AlertsTab extends StatefulWidget {
  const _AlertsTab();

  @override
  State<_AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<_AlertsTab> {
  void _showFilterOptions(BuildContext context) {
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
            const Text(
              'Filter Alerts',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.pets, color: AppTheme.lightGreen),
              title: const Text(
                'All Alerts',
                style: TextStyle(color: AppTheme.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: AppTheme.alertRed),
              title: const Text(
                'High Severity',
                style: TextStyle(color: AppTheme.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppTheme.warningRed),
              title: const Text(
                'Medium Severity',
                style: TextStyle(color: AppTheme.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.check_circle,
                color: AppTheme.lightGreen,
              ),
              title: const Text(
                'Low Severity',
                style: TextStyle(color: AppTheme.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alerts',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: AppTheme.white),
                  onPressed: () {
                    _showFilterOptions(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildAlertCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(int index) {
    final alerts = [
      {
        'title': 'Wild Boar Detected',
        'zone': 'Zone B',
        'time': '10 min ago',
        'severity': 'High',
      },
      {
        'title': 'Deer Movement',
        'zone': 'Zone A',
        'time': '1 hour ago',
        'severity': 'Low',
      },
      {
        'title': 'Fox Spotted',
        'zone': 'Zone C',
        'time': '2 hours ago',
        'severity': 'Medium',
      },
      {
        'title': 'Unknown Animal',
        'zone': 'Zone D',
        'time': '3 hours ago',
        'severity': 'High',
      },
      {
        'title': 'Bird Flock',
        'zone': 'Zone A',
        'time': '5 hours ago',
        'severity': 'Low',
      },
    ];

    final alert = alerts[index];
    final severityColor = alert['severity'] == 'High'
        ? AppTheme.alertRed
        : alert['severity'] == 'Medium'
        ? AppTheme.warningRed
        : AppTheme.lightGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber, color: severityColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title']!,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                      alert['zone']!,
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert['time']!,
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              alert['severity']!,
              style: TextStyle(
                color: severityColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Map tab placeholder
class _MapTab extends StatelessWidget {
  const _MapTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
              color: AppTheme.lightGreen.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Map View',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View detection zones on map',
              style: TextStyle(color: AppTheme.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

/// History tab placeholder
class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppTheme.lightGreen.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Detection History',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View past detection records',
              style: TextStyle(color: AppTheme.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
