import 'package:flutter/material.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

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
          "Community Guidelines",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // 🔹 Hero Image (Dummy)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade200, Colors.teal.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bubble_chart,
                          size: 90,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Title
                  const Text(
                    "Let's keep the vibe right ✌️",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 12),

                  // 🔹 Subtitle
                  const Text(
                    "Here’s how we keep the app fun, safe, and chill for everyone in the crew.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🔹 Rules
                  const _GuidelineCard(
                    icon: Icons.verified,
                    iconColor: Color(0xFF4FC3F7),
                    title: "Be Real 💯",
                    description:
                        "No catfishing or faking it. We want to see the real you, authentic connections only.",
                  ),

                  const _GuidelineCard(
                    icon: Icons.favorite,
                    iconColor: Color(0xFFF48FB1),
                    title: "Kindness is Cool 💖",
                    description:
                        "Zero tolerance for bullying, hate speech, or bad vibes. Lift each other up.",
                  ),

                  const _GuidelineCard(
                    icon: Icons.shield,
                    iconColor: Color(0xFF90CAF9),
                    title: "Keep it Safe 🛡️",
                    description:
                        "Don’t share private info like your address. Report anything that feels weird.",
                  ),

                  const _GuidelineCard(
                    icon: Icons.block,
                    iconColor: Color(0xFFFFB74D),
                    title: "No Spam 🚫",
                    description:
                        "We’re here for friends, not bots, ads, or scams. Keep the feed clean.",
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Report
                  TextButton(
                    onPressed: () {},
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: "See something sketchy? ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextSpan(
                            text: "Report a violation",
                            style: TextStyle(
                              color: Color(0xFF2EC7F0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// Guideline Card
/// ===============================
class _GuidelineCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _GuidelineCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
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
