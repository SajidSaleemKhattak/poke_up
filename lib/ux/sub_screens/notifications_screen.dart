import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_up/constants/app_styling.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (uid == null) return;
              final query = await FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(uid)
                  .collection('items')
                  .where('read', isEqualTo: false)
                  .get();
              final batch = FirebaseFirestore.instance.batch();
              for (final doc in query.docs) {
                batch.update(doc.reference, {'read': true});
              }
              await batch.commit();
            },
            child: const Text(
              "Mark all as read",
              style: TextStyle(color: AppStyling.primaryColor),
            ),
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text("Not signed in"))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(uid)
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading notifications"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("No notifications"));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final data = docs[i].data();
                    final type = data['type'] as String?;
                    final title = data['title'] as String? ?? '';
                    final body = data['body'] as String? ?? '';
                    final read = data['read'] as bool? ?? false;
                    final isInterest = type == 'interest';
                    final displayTitle = isInterest ? "New Interest 🎉" : title;
                    final bgColor =
                        isInterest ? const Color(0xFFEAF7FA) : Colors.white;
                    final titleStyle = TextStyle(
                      fontWeight: isInterest
                          ? FontWeight.w800
                          : (read ? FontWeight.w500 : FontWeight.w700),
                    );
                    return Material(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final action = data['action'] as Map<String, dynamic>?;
                          await docs[i].reference.update({'read': true});
                          if (action != null) {
                            final route = action['route'] as String?;
                            if (route != null) context.push(route);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayTitle, style: titleStyle),
                              const SizedBox(height: 4),
                              Text(body, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
