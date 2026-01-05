import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:poke_up/services/chat/chat_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

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

            // 🔹 Who’s Free Now (Static for now)
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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: ChatService.myChatsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading chats"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No chats yet. Match with someone to start chatting!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  // Sort by last_message_time descending on client to avoid composite index requirement
                  final sortedDocs = [...docs]
                    ..sort((a, b) {
                      final ta = (a.data()['last_message_time'] as Timestamp?);
                      final tb = (b.data()['last_message_time'] as Timestamp?);
                      final da =
                          ta?.toDate() ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      final db =
                          tb?.toDate() ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      return db.compareTo(da);
                    });

                  return ListView.builder(
                    itemCount: sortedDocs.length,
                    itemBuilder: (context, index) {
                      final data = sortedDocs[index].data();
                      final participants = List<String>.from(
                        data['participants'] ?? [],
                      );
                      final participantDetails =
                          data['participantDetails'] as Map<String, dynamic>? ??
                          {};

                      final currentUid = currentUser?.uid;
                      final otherUid = participants.firstWhere(
                        (uid) => uid != currentUid,
                        orElse: () => '',
                      );

                      final otherUser = participantDetails[otherUid] ?? {};
                      final name = otherUser['name'] ?? 'User';
                      final profilePic = otherUser['profilePic'];

                      final lastMessage = data['last_message'] ?? '';
                      final Timestamp? ts = data['last_message_time'];
                      final time = ts != null
                          ? timeago.format(ts.toDate(), locale: 'en_short')
                          : '';
                      final Map<String, dynamic>? lastRead =
                          data['last_read'] as Map<String, dynamic>?;
                      final Timestamp? myRead =
                          lastRead?[currentUid] as Timestamp?;
                      final bool isUnread =
                          ts != null && (myRead == null || ts.compareTo(myRead) > 0);

                      return _ChatTile(
                        name: name,
                        message: lastMessage,
                        time: time,
                        profilePic: profilePic,
                        highlighted: isUnread,
                        unread: isUnread,
                        onTap: () {
                          ChatService.markConversationRead(sortedDocs[index].id);
                          context.push(
                            '/app/chat/${sortedDocs[index].id}',
                            extra: {
                              'name': name,
                              'otherUid': otherUid,
                              'profilePic': profilePic,
                            },
                          );
                        },
                      );
                    },
                  );
                },
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
  final String? profilePic;
  final bool unread;
  final bool highlighted;
  final VoidCallback onTap;

  const _ChatTile({
    required this.name,
    required this.message,
    required this.time,
    required this.onTap,
    this.profilePic,
    this.unread = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: highlighted ? AppStyling.primaryLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: profilePic != null
                  ? NetworkImage(profilePic!)
                  : null,
              child: profilePic == null ? const Icon(Icons.person) : null,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: highlighted
                        ? AppStyling.primaryColor
                        : Colors.grey.shade500,
                  ),
                ),
                if (unread) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2EC7F0),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
