import 'package:flutter/material.dart';
import 'package:work/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work/screens/Home/NavBar/completed_jobs_screen.dart';

/// A screen that displays the user's profile information, statistics, and settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late User? _user;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              (_user?.displayName?.isNotEmpty == true
                      ? _user!.displayName![0]
                      : "U")
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user?.displayName ?? "User",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.email ?? "",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Jobs\nCompleted', '25'),
              _buildStatCard('Total\nEarnings', '₹50,000'),
              _buildStatCard('Rating', '4.8'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // TODO: Implement edit profile
            },
          ),
          _buildMenuItem(
            icon: Icons.work_outline,
            title: 'Work History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompletedJobsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.star_outline,
            title: 'Reviews',
            onTap: () {
              // TODO: Implement reviews
            },
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: Implement help & support
            },
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: _handleLogout,
            textColor: Colors.red,
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildMenuItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    bool showBorder = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: textColor ?? Colors.grey[700]),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: onTap,
        ),
        if (showBorder)
          Divider(
            height: 0,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
      ],
    );
  }
}
