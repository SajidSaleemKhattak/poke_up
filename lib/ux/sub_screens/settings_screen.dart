import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ACCOUNT
            const _SectionTitle(title: "ACCOUNT"),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.person_outline,
              title: "Personal Information",
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.business_center_outlined,
              title: "Change into Business Account",
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // SUPPORT
            const _SectionTitle(title: "SUPPORT"),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.verified_user_outlined,
              title: "Community Guidelines",
              trailing: Icons.open_in_new,
              onTap: () => context.push("/app/profile/community_guideline"),
            ),

            const Spacer(),

            // Sign Out Button
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Delete Account
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Delete Account",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Version
            const Center(
              child: Text(
                "Version 2.4.0 (Build 302)",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// Section Title
/// ===============================
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// ===============================
/// Settings Tile
/// ===============================
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final IconData? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.grey.shade700),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(trailing ?? Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}
