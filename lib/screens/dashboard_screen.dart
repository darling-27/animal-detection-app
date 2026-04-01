// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/detection_data.dart';
import '../widgets/detection_card.dart';
import '../services/fcm_service.dart';
import '../provider/office_provider.dart';
import 'alert_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndUpdateFCM();
    });
  }

  Future<void> _checkAndUpdateFCM() async {
    final officerProvider =
        Provider.of<OfficerProvider>(context, listen: false);

    if (officerProvider.officer != null) {
      final officerId = officerProvider.officer!.id;
      final fcmService = FCMService();
      await fcmService.initializeFCM(officerId, 'forestOfficer');

      String? currentToken = await FirebaseMessaging.instance.getToken();

      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("DASHBOARD INITIALIZED");
      debugPrint("OFFICER ID : $officerId");
      debugPrint("FCM TOKEN  : $currentToken");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    }
  }

  final List<Widget> _screens = [
    const _DashboardHome(),
    const AlertScreen(showMapOnTap: true),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ FIX: Now uses real Firestore data via StreamBuilder
class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.darkBackground,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Wild Guardian',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkGreen,
                      AppTheme.forestGreen.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {},
              ),
            ],
          ),

          // ── Stats Row (live from Firestore) ──
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('detections')
                  .snapshots(),
              builder: (context, snapshot) {
                int total = 0;
                int dangerous = 0;
                Set<String> zones = {};

                if (snapshot.hasData) {
                  total = snapshot.data!.docs.length;
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['isDangerous'] == true) dangerous++;
                    final loc = data['location'] as String?;
                    if (loc != null) zones.add(loc);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _StatCard(
                        icon: Icons.pets,
                        label: 'Total Detections',
                        value: '$total',
                        color: AppTheme.lightGreen,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.warning,
                        label: 'Dangerous',
                        value: '$dangerous',
                        color: AppTheme.alertRed,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.location_on,
                        label: 'Active Zones',
                        value: '${zones.length}',
                        color: AppTheme.forestGreen,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Live Detections',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),

          // ── Live Detection List from Firestore ──
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('detections')
                .orderBy('timestamp', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppTheme.lightGreen,
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pets,
                            size: 64,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No detections yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final detection = DetectionData(
                      animalType: data['animalType'] ?? 'Unknown',
                      confidence: (data['confidence'] ?? 0).toDouble(),
                      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now(),
                      imageUrl: data['imageUrl'] ?? '',
                      isDangerous: data['isDangerous'] ?? false,
                      latitude: 0.0, // Add if you store coords
                      longitude: 0.0,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: DetectionCard(
                        detection: detection,
                      ),
                    );
                  },
                  childCount: docs.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
