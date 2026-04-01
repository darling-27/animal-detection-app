import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../provider/civilian_proivder.dart';
import '../services/civilian_auth_service.dart';

class CivilianProfileScreen extends StatelessWidget {
  const CivilianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final civilianProvider = Provider.of<CivilianProvider>(context);
    final civilian = civilianProvider.civilian;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('My Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Profile Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.earthBrown.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppTheme.earthBrown.withValues(alpha: 0.3),
                    backgroundImage: civilian?.photoUrl != null &&
                            civilian!.photoUrl!.isNotEmpty
                        ? NetworkImage(civilian.photoUrl!)
                        : null,
                    child: civilian?.photoUrl == null ||
                            civilian!.photoUrl!.isEmpty
                        ? const Icon(Icons.person,
                            size: 45, color: AppTheme.earthBrown)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    civilian?.name ?? 'Citizen',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Email
                  Text(
                    civilian?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Role badge
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.earthBrown.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.earthBrown.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      '🐾 Wildlife Watcher',
                      style: TextStyle(
                        color: AppTheme.earthBrown,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // Member since
                  if (civilian?.createdAt != null) ...[
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Menu Items ──
            _ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notification Settings',
              subtitle: 'Manage alert preferences',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.shield_outlined,
              title: 'Safety Guidelines',
              subtitle: 'Learn how to stay safe',
              onTap: () => _showSafetyGuidelines(context),
            ),
            _ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'About Wildlife Watch',
              subtitle: 'App information',
              onTap: () => _showAbout(context),
            ),
            _ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help or report issues',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),

            const SizedBox(height: 16),

            // ── Logout Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.alertRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(color: AppTheme.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.alertRed,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await CivilianAuthService().signOut();
        await Provider.of<CivilianProvider>(context, listen: false)
            .clearCivilian();

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing out: $e')),
          );
        }
      }
    }
  }

  void _showSafetyGuidelines(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🛡️ Safety Guidelines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 16),
            _guideline('🐅', 'Big Cats',
                'Keep 100m distance. Never run. Make loud noises.'),
            _guideline('🐘', 'Elephants',
                'Stay quiet. Don\'t block their path. Move slowly.'),
            _guideline('🐍', 'Snakes',
                'Stay 5m away. Don\'t provoke. Call rescue helpline.'),
            _guideline('🐻', 'Bears',
                'Don\'t run or climb. Back away slowly facing the bear.'),
            _guideline('🐊', 'Reptiles',
                'Stay away from water edges. Never approach.'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _guideline(String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    )),
                Text(desc,
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🐾 Wildlife Watch',
            style: TextStyle(color: AppTheme.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wildlife Watch helps civilians stay informed about '
              'wild animal sightings in their area using AI-powered detection.',
              style: TextStyle(
                  color: AppTheme.white.withValues(alpha: 0.7), height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                  color: AppTheme.white.withValues(alpha: 0.4), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ──────────────────────────────────────────────────
// Profile Menu Item Widget
// ──────────────────────────────────────────────────

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.earthBrown.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.earthBrown, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.white.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
