import 'package:flutter/material.dart';
import 'package:poke_up/constants/app_styling.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // 🔹 Header
              Row(
                children: [
                  const Icon(Icons.arrow_back),
                  const Spacer(),
                  const Text(
                    "My Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  const Icon(Icons.settings),
                ],
              ),

              const SizedBox(height: 24),

              // 🔹 Profile Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2EC7F0),
                        width: 4,
                      ),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 60),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2EC7F0),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Name + Verified
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Alex, 24",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.verified, color: Color(0xFF2EC7F0), size: 20),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                "Here for coffee runs and thrifting ✌️",
                style: TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // 🔹 Stats
              Row(
                children: const [
                  _StatCard(title: "12", subtitle: "POKES"),
                  SizedBox(width: 12),
                  _StatCard(title: "85", subtitle: "KARMA"),
                  SizedBox(width: 12),
                  _StatCard(title: "3", subtitle: "STREAKS"),
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 Action Buttons
              Row(
                children: [
                  Expanded(child: _OutlinedButton(title: "Edit Vibe")),
                  const SizedBox(width: 12),
                  Expanded(child: _PrimaryButton(title: "+ New Poke")),
                ],
              ),

              const SizedBox(height: 24),

              // 🔹 Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _tab("Active", 0),
                  _tab("Matched", 1),
                  _tab("The Vault", 2),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Tab Content
              if (selectedTab == 0) ...[
                _ActiveCard(
                  title: "Anyone for boba right now? 🧋",
                  time: "2 mins ago",
                  footer: "4 interested",
                ),
                _ActiveCard(
                  title: "Study buddy for library? 📚",
                  time: "15 mins ago",
                  subtitle:
                      "Need someone to keep me accountable for finals week. I have snacks!",
                  footer: "No responses yet...",
                ),
              ],

              if (selectedTab == 1) _MatchedCard(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String title, int index) {
    final bool active = selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          if (active)
            Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF2EC7F0),
              ),
            ),
        ],
      ),
    );
  }
}

/// ===============================
/// Widgets
/// ===============================

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFF1FAFD),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppStyling.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String title;

  const _PrimaryButton({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF2EC7F0),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String title;

  const _OutlinedButton({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFFF1FAFD),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  final String title;
  final String time;
  final String? subtitle;
  final String footer;

  const _ActiveCard({
    required this.title,
    required this.time,
    this.subtitle,
    required this.footer,
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
          Text(
            "● Live   $time",
            style: const TextStyle(color: Color(0xFF2EC7F0)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 12),
          Text(
            footer,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "MATCHED",
            style: TextStyle(
              color: Color(0xFF2EC7F0),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Quick Valorant game",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Center(
            child: Text(
              "Message Sam",
              style: TextStyle(
                color: Color(0xFF2EC7F0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
