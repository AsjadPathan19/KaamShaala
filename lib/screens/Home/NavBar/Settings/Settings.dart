import 'package:flutter/material.dart';
import 'package:work/services/auth_service.dart';
import 'package:work/screens/Home/NavBar/Settings/TermsAndConditionsScreen.dart';

/// A screen that displays various application settings and options
/// Allows users to change password, view help, terms, report problems, and log out
class SettingsScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  SettingsScreen({super.key});

  /// Shows a confirmation dialog before logging out
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            buildSettingItem(Icons.person_outline, "Profile Settings", () {
              // TODO: Implement profile settings
            }),
            buildSettingItem(Icons.change_circle, "Change Password", () {
              // TODO: Implement password change functionality
            }),

            // Support Section
            _buildSectionHeader('Support'),
            buildSettingItem(Icons.help_outline, "Help Center", () {
              // TODO: Implement help functionality
            }),
            buildSettingItem(Icons.info_outline, "Terms & Conditions", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermsAndConditionsScreen(),
                ),
              );
            }),
            buildSettingItem(
              Icons.warning_amber_outlined,
              "Report Problem",
              () {
                // TODO: Implement problem reporting functionality
              },
            ),

            // About Section
            _buildSectionHeader('About'),
            buildSettingItem(Icons.info_outline, "App Version", () {
              // TODO: Show app version info
            }),

            // Logout Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutConfirmation(context),
                  icon: Icon(Icons.logout, color: Colors.white),
                  label: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a section header with a title
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// Creates a consistent list tile for each setting item
  Widget buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
