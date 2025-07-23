// lib/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is AuthSuccess) {
      final user = authState.user;
      return _buildProfileView(context, user);
    }
    
    return const Center(child: Text('Error: User not authenticated.'));
  }

  // This method is updated to control divider placement
  Widget _buildProfileView(BuildContext context, Map<String, dynamic> user) {
    return Container(
      color: const Color(0xFFF4F6F8), // Background for the whole page
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          _buildUserInfoCard(user),
          const SizedBox(height: 20),

          // --- Settings List with custom dividers ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const SizedBox(height: 10), // Space between card top and first divider
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16), // Divider above Notifications
                  _buildSettingsRow(Icons.notifications_none, 'Notifications', trailing: const Text('ON', style: TextStyle(color: Colors.grey))),
                  _buildSettingsRow(Icons.translate, 'Language', trailing: const Text('English', style: TextStyle(color: Colors.grey))),
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16), // Divider below Language
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildSettingsRow(Icons.security, 'Security'),
                  _buildSettingsRow(Icons.nightlight_round, 'Theme', trailing: const Text('Light mode', style: TextStyle(color: Colors.grey))),
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16), // Divider below Theme
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration( borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildSettingsRow(Icons.help_outline, 'Help & Support'),
                  _buildSettingsRow(Icons.contact_mail_outlined, 'Contact us'),
                  _buildSettingsRow(Icons.policy_outlined, 'Privacy policy'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- The helper methods below remain the same ---

  Widget _buildUserInfoCard(Map<String, dynamic> user) {
    const Color primaryBlue = Color(0xFF0D47A1);
    final String initial = user['name']?.isNotEmpty == true ? user['name'][0].toUpperCase() : 'U';

    return Card(
      elevation: 2,
      color: const Color(0xFFEFF4FF),
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: primaryBlue,
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name'] ?? 'User Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user['email'] ?? 'user@example.com', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Position', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(user['position'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Phone Number', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(user['phoneNumber'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String title, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      trailing: trailing,
      onTap: () {},
    );
  }
}