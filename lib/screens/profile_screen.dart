// lib/screens/profile_screen.dart
import 'package:animal_detection/screens/roles_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../provider/office_provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _locationEnabled = true;
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.alertRed, size: 24),
            SizedBox(width: 12),
            Text(
              'Confirm Logout',
              style:
                  TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to login again.',
          style: TextStyle(color: AppTheme.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.alertRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      final officerProvider =
          Provider.of<OfficerProvider>(context, listen: false);
      final officer = officerProvider.officer;

      // Sign out from Firebase (clears FCM token)
      if (officer != null) {
        await OfficerAuthService().signOut(officer.id);
      }

      // Clear provider state and shared preferences
      await officerProvider.logout();

      // Clear ALL shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppTheme.alertRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final officerProvider = Provider.of<OfficerProvider>(context);
    final officer = officerProvider.officer;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile Header ──
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.forestGreen, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(officer?.name ?? 'FO'),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    officer?.name ?? 'Forest Officer',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rank
                  if (officer?.rank != null && officer!.rank!.isNotEmpty)
                    Text(
                      officer.rank!,
                      style: TextStyle(
                        color: AppTheme.lightGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Staff ID
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Staff ID: ${officer?.staffId ?? 'N/A'}',
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Officer Details Section ──
            if (officer != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'OFFICER DETAILS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: 'Name',
                      value: officer.name ?? 'N/A',
                    ),
                    _DetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Staff ID',
                      value: officer.staffId,
                    ),
                    _DetailRow(
                      icon: Icons.military_tech_outlined,
                      label: 'Rank',
                      value: officer.rank ?? 'N/A',
                    ),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Zone',
                      value: officer.zone ?? 'N/A',
                    ),
                    _DetailRow(
                      icon: Icons.fingerprint,
                      label: 'Document ID',
                      value: officer.id,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ── Notification Settings (Location Only) ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.location_on,
                    title: 'Location Services',
                    subtitle: 'Enable location for detection tracking',
                    trailing: Switch(
                      value: _locationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _locationEnabled = value;
                        });
                      },
                      activeTrackColor: AppTheme.forestGreen,
                      activeThumbColor: AppTheme.forestGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Account Section ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'ACCOUNT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help with the app',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version 1.0.0',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Logout Button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoggingOut ? null : _handleLogout,
                  icon: _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.white,
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: Text(_isLoggingOut ? 'LOGGING OUT...' : 'LOGOUT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.alertRed,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'FO';
  }
}

// ── Officer Detail Row Widget ──
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.forestGreen, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Tile Widget ──
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.forestGreen.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.forestGreen, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.white.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.white.withValues(alpha: 0.3),
          ),
      onTap: onTap,
    );
  }
}
