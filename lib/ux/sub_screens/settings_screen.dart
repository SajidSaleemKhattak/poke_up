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
  bool showInterestsEditor = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final Set<String> _selectedInterests = {};

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
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
                    _selectedInterests
                      ..clear()
                      ..addAll(interests.map((e) => e.toString()));
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
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              showInterestsEditor = !showInterestsEditor;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Change Interests",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (showInterestsEditor) ...[
                        const _SectionTitle(title: "INTERESTS"),
                        const SizedBox(height: 8),
                        _chipsSection(this),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _selectedInterests.length >= 5
                                ? () async {
                                    final uid =
                                        FirebaseAuth.instance.currentUser?.uid;
                                    if (uid == null) return;
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .update({
                                          'interests': _selectedInterests
                                              .toList(),
                                        });
                                    setState(() {
                                      showInterestsEditor = false;
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2EC7F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Submit Interests",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                            if (name.isEmpty || age == null) return;
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({'firstName': name, 'age': age});
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

// Interest chips UI section (styled similar to InterestSelection4)
Widget _chipsSection(_SettingsScreenState state) {
  Widget chipsWrap(List<String> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        final bool isSelected = state._selectedInterests.contains(item);
        return GestureDetector(
          onTap: () {
            state.setState(() {
              if (isSelected) {
                state._selectedInterests.remove(item);
              } else {
                state._selectedInterests.add(item);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isSelected ? const Color(0xFF2EC7F0) : Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2EC7F0)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      chipsWrap([
        "🌮 Tacos",
        "☕ Coffee Runs",
        "🍣 Sushi",
        "🍕 Late Night Pizza",
        "🧋 Boba Tea",
        "🥐 Brunch",
      ]),
      const SizedBox(height: 16),
      chipsWrap([
        "🎬 Movie Night",
        "🎮 Gaming",
        "🚶‍♀️ Hot Girl Walk",
        "🍹 Rooftop Drinks",
        "📖 Book Time",
        "😌 Just Chilling",
      ]),
      const SizedBox(height: 16),
      chipsWrap([
        "🏋️ Gym",
        "🧘 Yoga",
        "🏃 Running",
        "🥗 Healthy Eating",
        "🧠 Mental Health",
        "🛌 Self Care",
      ]),
      const SizedBox(height: 16),
      chipsWrap([
        "⚽ Football",
        "🏀 Basketball",
        "🎾 Tennis",
        "🏏 Cricket",
        "🏓 Table Tennis",
        "🏐 Volleyball",
      ]),
      const SizedBox(height: 16),
      chipsWrap([
        "🎵 Music",
        "📸 Photography",
        "🎬 Filmmaking",
        "✍️ Writing",
        "🖌️ Painting",
        "🎭 Theatre",
      ]),
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
