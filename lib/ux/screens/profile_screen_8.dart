import 'package:flutter/material.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showActive = true; // 🔹 state switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 🔹 Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.arrow_back),
                  Spacer(),
                  Text(
                    "My Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/app/profile/settings'),
                    child: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Profile Image
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 48),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2EC7F0),
                  ),
                  child: const Icon(Icons.edit, size: 18, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Alex, 24",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 6),
                Icon(Icons.verified, size: 18, color: Color(0xFF2EC7F0)),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "Here for coffee runs and thrifting ✌️",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // 🔹 Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  _StatBox(title: "12", label: "POKES"),
                  SizedBox(width: 12),
                  _StatBox(title: "85", label: "KARMA"),
                  SizedBox(width: 12),
                  _StatBox(title: "3", label: "STREAKS"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: AppStyling.primaryLight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: const Text(
                          "Edit Vibe",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2EC7F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: AppStyling.white,
                            fontWeight: FontWeight.w700,
                            size: 18,
                          ),
                          SizedBox(width: 4.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: const Text(
                              "New Poke",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppStyling.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 🔹 Tabs (Active / Matched)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _tabButton(
                    title: "Active",
                    active: showActive,
                    onTap: () => setState(() => showActive = true),
                  ),
                  _tabButton(
                    title: "Matched",
                    active: !showActive,
                    onTap: () => setState(() => showActive = false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Content Area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: showActive ? _activeList() : _matchedList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // Tabs
  // ===============================
  Widget _tabButton({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: active ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: active ? 28 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF2EC7F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // Active Content
  // ===============================
  Widget _activeList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _ActiveCard(
          title: "Anyone for boba right now? 🧋",
          subtitle: "4 interested",
          time: "2 mins ago",
        ),
        _ActiveCard(
          title: "Study buddy for library? 📚",
          subtitle: "No responses yet",
          time: "15 mins ago",
        ),
      ],
    );
  }

  // ===============================
  // Matched Content
  // ===============================
  Widget _matchedList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _MatchedCard(title: "Quick Valorant game", actionText: "Message Sam"),
      ],
    );
  }
}

// ===============================
// Reusable Widgets
// ===============================

class _StatBox extends StatelessWidget {
  final String title;
  final String label;

  const _StatBox({required this.title, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppStyling.primaryLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppStyling.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _ActiveCard({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFEAF7FA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Color(0xFF2EC7F0)),
              const SizedBox(width: 8),
              Text("Live • $time"),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _MatchedCard extends StatelessWidget {
  final String title;
  final String actionText;

  const _MatchedCard({required this.title, required this.actionText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: 0.5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MATCHED",
            style: TextStyle(
              fontSize: 12,
              color: AppStyling.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () {}, child: Text(actionText)),
        ],
      ),
    );
  }
}
