import 'package:flutter/material.dart';
import 'package:poke_up/constants/app_styling.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyling.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Chats",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Who’s Free Now
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Who's Free Now?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _OnlineAvatar(name: "Mike"),
                  _OnlineAvatar(name: "Jen"),
                  _OnlineAvatar(name: "Tariq"),
                  _OnlineAvatar(name: "Chloe", online: false),
                  _OnlineAvatar(name: "Sam", online: false),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Chats List
            Expanded(
              child: ListView(
                children: const [
                  _ChatTile(
                    name: "Sarah M.",
                    message: "Let's meet at 4pm?",
                    time: "2m",
                    unread: true,
                  ),
                  _ChatTile(
                    name: "Jake",
                    message: "🚀 Poke accepted! Plan a hangout.",
                    time: "10m",
                    highlighted: true,
                  ),
                  _ChatTile(
                    name: "Alex",
                    message: "See you there!",
                    time: "1h",
                  ),
                  _ChatTile(
                    name: "Mia",
                    message: "Haha same here",
                    time: "Yesterday",
                  ),
                  _ChatTile(
                    name: "Daniel",
                    message: "Maybe next weekend?",
                    time: "Yesterday",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// Online Avatar Widget
/// ===============================
class _OnlineAvatar extends StatelessWidget {
  final String name;
  final bool online;

  const _OnlineAvatar({required this.name, this.online = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 32),
              ),
              if (online)
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2EC7F0),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

/// ===============================
/// Chat List Tile
/// ===============================
class _ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool unread;
  final bool highlighted;

  const _ChatTile({
    required this.name,
    required this.message,
    required this.time,
    this.unread = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: highlighted ? AppStyling.primaryLight : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: highlighted
                        ? AppStyling.primaryColor
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 6),
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2EC7F0),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
