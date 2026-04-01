import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../services/fcm_service.dart';
import '../provider/civilian_proivder.dart';
import 'alert_screen.dart';
import 'history_screen.dart';
import 'civilian_profile_screen.dart';

class CivilianDashboardScreen extends StatefulWidget {
  const CivilianDashboardScreen({super.key});

  @override
  State<CivilianDashboardScreen> createState() =>
      _CivilianDashboardScreenState();
}

class _CivilianDashboardScreenState extends State<CivilianDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndUpdateFCM();
    });
  }

  Future<void> _checkAndUpdateFCM() async {
    final civilianProvider =
        Provider.of<CivilianProvider>(context, listen: false);

    if (civilianProvider.civilian != null) {
      final civilianId = civilianProvider.civilian!.id;
      await FCMService().initializeFCM(civilianId, 'civilian');

      String? currentToken = await FirebaseMessaging.instance.getToken();

      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("CIVILIAN DASHBOARD INITIALIZED");
      debugPrint("CIVILIAN ID : $civilianId");
      debugPrint("FCM TOKEN   : $currentToken");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    }
  }

  late final List<Widget> _screens = [
    const _CivilianDashboardHome(),
    const AlertScreen(),
    const HistoryScreen(),
    const CivilianProfileScreen(),
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
          selectedItemColor: AppTheme.earthBrown,
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

// ──────────────────────────────────────────────────
// Animal Detection Filter Helper
// ──────────────────────────────────────────────────

/// Known animal types (COCO dataset + common wild animals)
const Set<String> _knownAnimalTypes = {
  // COCO dataset animals
  'bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear',
  'zebra', 'giraffe',
  // Common wild / Indian animals
  'tiger', 'lion', 'leopard', 'deer', 'monkey', 'snake', 'crocodile',
  'wolf', 'fox', 'rabbit', 'boar', 'wild boar', 'rhinoceros', 'rhino',
  'hippopotamus', 'hippo', 'cheetah', 'jaguar', 'panther', 'buffalo',
  'bison', 'moose', 'elk', 'antelope', 'gazelle', 'kangaroo', 'koala',
  'panda', 'gorilla', 'chimpanzee', 'orangutan', 'hyena', 'jackal',
  'coyote', 'lynx', 'bobcat', 'cougar', 'puma', 'mongoose', 'otter',
  'peacock', 'eagle', 'hawk', 'falcon', 'owl', 'vulture', 'parrot',
  'turtle', 'tortoise', 'lizard', 'python', 'cobra', 'alligator',
  'dolphin', 'shark', 'seal', 'whale', 'pig', 'goat', 'donkey',
  'camel', 'llama', 'sambar', 'nilgai', 'chital', 'gaur', 'sloth bear',
  'wild dog', 'dhole', 'langur', 'macaque', 'mugger', 'gharial',
  'king cobra', 'indian python', 'monitor lizard',
};

/// Returns true if the Firestore document represents an actual animal detection
// Replace the isAnimalDetection function in civilian_dashboard_screen.dart:

/// Returns true if the Firestore document represents an actual animal detection
bool isAnimalDetection(Map<String, dynamic> data) {
  // ── Priority 1: Check isAnimal boolean field (set by backend) ──
  final isAnimal = data['isAnimal'];
  if (isAnimal != null) {
    return isAnimal == true;
  }

  // ── Priority 2: animalCategory field exists and is not empty ──
  final category = data['animalCategory'] as String?;
  if (category != null && category.trim().isNotEmpty) {
    return true;
  }

  // ── Priority 3: Check animalType against known animal list ──
  final type = (data['animalType'] as String?)?.toLowerCase().trim() ?? '';
  if (type.isEmpty) return false;

  return _knownAnimalTypes.contains(type);
}

// ──────────────────────────────────────────────────
// Civilian Dashboard Home (Animals Only)
// ──────────────────────────────────────────────────

class _CivilianDashboardHome extends StatelessWidget {
  const _CivilianDashboardHome();

  @override
  Widget build(BuildContext context) {
    final civilianProvider = Provider.of<CivilianProvider>(context);
    final civilianName =
        civilianProvider.civilian?.name.split(' ').first ?? 'Citizen';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.darkBackground,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🐾 Wildlife Watch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Hello, $civilianName',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.earthBrown,
                      AppTheme.earthBrown.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.pets,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),

          // ── Safety Banner ──
          SliverToBoxAdapter(
            child: _buildSafetyBanner(context),
          ),

          // ── Stats Row (animals only) ──
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('detections')
                  .snapshots(),
              builder: (context, snapshot) {
                int totalAnimals = 0;
                int dangerous = 0;
                Set<String> zones = {};

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (isAnimalDetection(data)) {
                      totalAnimals++;
                      if (data['isDangerous'] == true) dangerous++;
                      final loc = data['location'] as String?;
                      if (loc != null && loc.isNotEmpty) zones.add(loc);
                    }
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _StatCard(
                        icon: Icons.pets,
                        label: 'Animals Spotted',
                        value: '$totalAnimals',
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
                        color: AppTheme.earthBrown,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Dangerous Animals Alert (if any) ──
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('detections')
                  .orderBy('timestamp', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final dangerousDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return isAnimalDetection(data) && data['isDangerous'] == true;
                }).toList();

                if (dangerousDocs.isEmpty) return const SizedBox.shrink();

                // Show latest dangerous animal alert
                final latest =
                    dangerousDocs.first.data() as Map<String, dynamic>;
                final animalType = latest['animalType'] ?? 'Unknown';
                final location = latest['location'] ?? 'Unknown area';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.alertRed.withValues(alpha: 0.3),
                          AppTheme.warningRed.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.alertRed.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.alertRed.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            color: AppTheme.alertRed,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '⚠️ Danger Alert',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.alertRed,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_capitalize(animalType)} spotted near $location. Stay alert!',
                                style: TextStyle(
                                  color: AppTheme.white.withValues(alpha: 0.8),
                                  fontSize: 13,
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
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Section Title ──
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Animal Sightings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  Icon(Icons.pets, color: AppTheme.earthBrown, size: 20),
                ],
              ),
            ),
          ),

          // ── Live Animal Detection List (filtered) ──
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('detections')
                .orderBy('timestamp', descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppTheme.earthBrown,
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(child: _buildEmptyState());
              }

              // ✅ FILTER: Only animal detections
              final animalDocs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return isAnimalDetection(data);
              }).toList();

              if (animalDocs.isEmpty) {
                return SliverToBoxAdapter(child: _buildEmptyState());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data =
                        animalDocs[index].data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),
                      child: _CivilianAnimalCard(data: data),
                    );
                  },
                  childCount: animalDocs.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildSafetyBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.forestGreen.withValues(alpha: 0.3),
              AppTheme.darkGreen.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.forestGreen.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.forestGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppTheme.lightGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stay Safe in Wildlife Zones',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightGreen,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View real-time animal sightings near you and stay informed.',
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.pets,
                size: 64, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            const Text(
              'No animal sightings yet',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Animal detections will appear here in real-time',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Civilian Animal Detection Card
// ──────────────────────────────────────────────────

class _CivilianAnimalCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CivilianAnimalCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final animalType = data['animalType'] ?? 'Unknown';
    final animalCategory = data['animalCategory'] ?? '';
    final confidence = ((data['confidence'] ?? 0) * 100).toStringAsFixed(0);
    final isDangerous = data['isDangerous'] ?? false;
    final imageUrl = data['imageUrl'] ?? '';
    final location = data['location'] ?? 'Unknown Location';
    final latitude = (data['latitude'] ?? 0.0).toDouble();
    final longitude = (data['longitude'] ?? 0.0).toDouble();
    final timestamp =
        (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

    return GestureDetector(
      onTap: () => _showDetailSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: isDangerous
              ? Border.all(
                  color: AppTheme.alertRed.withValues(alpha: 0.5),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isDangerous
                  ? AppTheme.alertRed.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Section ──
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 180,
                              color: AppTheme.surfaceColor,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.earthBrown,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: AppTheme.surfaceColor,
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.white24, size: 48),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 180,
                          color: AppTheme.surfaceColor,
                          child: const Center(
                            child: Icon(Icons.pets,
                                color: Colors.white24, size: 48),
                          ),
                        ),

                  // Danger badge
                  if (isDangerous)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.alertRed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_rounded,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'DANGEROUS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Category badge
                  if (animalCategory.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(animalCategory),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          animalCategory.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Confidence badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$confidence% match',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info Section ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animal name row
                  Row(
                    children: [
                      Icon(
                        isDangerous ? Icons.warning_rounded : Icons.pets,
                        color: isDangerous
                            ? AppTheme.alertRed
                            : AppTheme.earthBrown,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _capitalize(animalType),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDangerous
                                ? AppTheme.alertRed
                                : AppTheme.white,
                          ),
                        ),
                      ),
                      Text(
                        _timeAgo(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Location row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.white.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (latitude != 0.0 && longitude != 0.0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          size: 14,
                          color: AppTheme.white.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.white.withValues(alpha: 0.4),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Timestamp row
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.white.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),

                  // Safety tip for dangerous animals
                  if (isDangerous) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.alertRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.alertRed.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppTheme.alertRed, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getSafetyTip(animalType),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    final animalType = data['animalType'] ?? 'Unknown';
    final animalCategory = data['animalCategory'] ?? '';
    final confidence = ((data['confidence'] ?? 0) * 100).toStringAsFixed(1);
    final isDangerous = data['isDangerous'] ?? false;
    final imageUrl = data['imageUrl'] ?? '';
    final location = data['location'] ?? 'Unknown Location';
    final latitude = (data['latitude'] ?? 0.0).toDouble();
    final longitude = (data['longitude'] ?? 0.0).toDouble();
    final timestamp =
        (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Image
              if (imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 250,
                        color: AppTheme.surfaceColor,
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.white24, size: 48),
                        ),
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        if (isDangerous)
                          Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.alertRed.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_rounded,
                                color: AppTheme.alertRed, size: 20),
                          ),
                        Expanded(
                          child: Text(
                            _capitalize(animalType),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Info grid
                    _DetailRow(
                      icon: Icons.category,
                      label: 'Category',
                      value: animalCategory.isNotEmpty
                          ? _capitalize(animalCategory)
                          : 'Unknown',
                    ),
                    _DetailRow(
                      icon: Icons.analytics,
                      label: 'Confidence',
                      value: '$confidence%',
                    ),
                    _DetailRow(
                      icon: Icons.dangerous,
                      label: 'Danger Level',
                      value: isDangerous ? 'Dangerous' : 'Safe',
                      valueColor:
                          isDangerous ? AppTheme.alertRed : AppTheme.lightGreen,
                    ),
                    _DetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: location,
                    ),
                    if (latitude != 0.0 && longitude != 0.0)
                      _DetailRow(
                        icon: Icons.my_location,
                        label: 'Coordinates',
                        value:
                            '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                      ),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Detected At',
                      value: DateFormat('dd MMM yyyy, hh:mm:ss a')
                          .format(timestamp),
                    ),

                    const SizedBox(height: 16),

                    // Safety info
                    if (isDangerous)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.alertRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.alertRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.health_and_safety,
                                    color: AppTheme.alertRed, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Safety Guidelines',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.alertRed,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getDetailedSafetyTip(animalType),
                              style: TextStyle(
                                color: AppTheme.white.withValues(alpha: 0.8),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'wild':
        return AppTheme.alertRed;
      case 'domestic':
        return AppTheme.forestGreen;
      case 'endangered':
        return Colors.orange;
      default:
        return AppTheme.earthBrown;
    }
  }

  String _getSafetyTip(String animalType) {
    final type = animalType.toLowerCase();
    if (type.contains('tiger') ||
        type.contains('lion') ||
        type.contains('leopard')) {
      return 'Keep distance! Do not approach. Contact forest department immediately.';
    } else if (type.contains('elephant')) {
      return 'Stay quiet and do not block its path. Move away slowly.';
    } else if (type.contains('snake') ||
        type.contains('cobra') ||
        type.contains('python')) {
      return 'Do not approach or provoke. Keep safe distance and call for help.';
    } else if (type.contains('bear')) {
      return 'Stay calm. Do not run. Back away slowly while facing the animal.';
    } else if (type.contains('crocodile') || type.contains('alligator')) {
      return 'Stay away from water edges. Do not approach under any circumstances.';
    } else if (type.contains('wolf') || type.contains('hyena')) {
      return 'Do not run. Make yourself appear larger and back away slowly.';
    }
    return 'Maintain safe distance. Do not approach or provoke the animal.';
  }

  String _getDetailedSafetyTip(String animalType) {
    final type = animalType.toLowerCase();
    if (type.contains('tiger') ||
        type.contains('lion') ||
        type.contains('leopard')) {
      return '• Keep a minimum distance of 100 meters\n'
          '• Do NOT run – it triggers chase instinct\n'
          '• Make loud noises to scare it away\n'
          '• Contact forest department at once\n'
          '• If charged, stand your ground and shout';
    } else if (type.contains('elephant')) {
      return '• Keep at least 50 meters distance\n'
          '• Do NOT block its path\n'
          '• Stay quiet and move away slowly\n'
          '• Watch for signs of agitation (ears flapping, trumpeting)\n'
          '• Never get between a mother and calf';
    } else if (type.contains('snake') || type.contains('cobra')) {
      return '• Stay at least 5 meters away\n'
          '• Do NOT try to catch or kill it\n'
          '• Wear boots in snake-prone areas\n'
          '• Call snake rescue helpline\n'
          '• If bitten, seek immediate medical attention';
    } else if (type.contains('bear')) {
      return '• Do NOT run or climb trees\n'
          '• Stay calm and speak in low tones\n'
          '• Back away slowly while facing the bear\n'
          '• Make yourself appear larger\n'
          '• Carry bear spray in bear country';
    }
    return '• Maintain safe distance at all times\n'
        '• Do NOT provoke or feed the animal\n'
        '• Contact local forest department\n'
        '• Keep children and pets away\n'
        '• Report the sighting to authorities';
  }
}

// ──────────────────────────────────────────────────
// Detail Row Widget
// ──────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.earthBrown),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Stat Card Widget
// ──────────────────────────────────────────────────

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

// ──────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String _timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('dd MMM').format(dateTime);
}
