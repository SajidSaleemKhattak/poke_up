import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool showPersonal = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

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
              onTap: () {
                setState(() {
                  showPersonal = !showPersonal;
                });
              },
            ),
            if (showPersonal)
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snap) {
                  final data = snap.data?.data();
                  if (data != null) {
                    _nameController.text = data['firstName'] ?? '';
                    _ageController.text =
                        (data['age'] as num?)?.toInt().toString() ?? '';
                    final interests = (data['interests'] as List?) ?? [];
                    _interestsController.text = interests
                        .map((e) => e.toString())
                        .join(', ');
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      _editableField(
                        "First Name",
                        _nameController,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 12),
                      _editableField(
                        "Age",
                        _ageController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _editableField(
                        "Interests (comma separated)",
                        _interestsController,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = _nameController.text.trim();
                            final age = int.tryParse(
                              _ageController.text.trim(),
                            );
                            final interests = _interestsController.text
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();
                            if (name.isEmpty || age == null) return;
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({
                                  'firstName': name,
                                  'age': age,
                                  'interests': interests,
                                });
                            setState(() {
                              showPersonal = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2EC7F0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 24),

            // SUPPORT
            const _SectionTitle(title: "SUPPORT"),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.verified_user_outlined,
              title: "Community Guidelines",
              trailing: Icons.open_in_new,
              onTap: () => context.push("/community_guideline"),
            ),

            const Spacer(),

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

class _EditableFieldWrapper extends StatelessWidget {
  final Widget child;
  const _EditableFieldWrapper({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

Widget _editableField(
  String label,
  TextEditingController controller, {
  TextInputType? keyboardType,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      _EditableFieldWrapper(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    ],
  );
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
