import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_up/services/profile/profile_service.dart';
import 'package:poke_up/services/poke/poke_service.dart';
import 'package:poke_up/services/chat/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showActive = true;
  Future<bool> _ensureGalleryPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final status = await Permission.photos.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    } else if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (status.isGranted) return true;
      status = await Permission.photos.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: ProfileService.myProfileStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data();
            if (userData == null) return const SizedBox.shrink();

            final name = userData['firstName'] ?? 'User';
            final age = userData['ageRange'] ?? '';
            final interests =
                (userData['interests'] as List<dynamic>?)?.join(", ") ??
                "No vibe yet";
            final profilePic = userData['profilePic'];

            return Column(
              children: [
                const SizedBox(height: 12),

                // 🔹 Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back),
                      const Spacer(),
                      const Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
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
                      backgroundImage: profilePic != null
                          ? NetworkImage(profilePic)
                          : null,
                      child: profilePic == null
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final granted = await _ensureGalleryPermission();
                        if (!granted) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Gallery permission required to upload photo',
                              ),
                            ),
                          );
                          return;
                        }
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1600,
                          imageQuality: 88,
                        );
                        if (pickedFile == null) return;
                        final file = File(pickedFile.path);
                        try {
                          final url = await ProfileService.uploadProfilePic(
                            file,
                          );
                          await ProfileService.updateProfilePic(url);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile pic updated'),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        }
                      },
                      child: Container(
                        width: 34,
                        height: 34,
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
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 🔹 Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$name, $age",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      size: 18,
                      color: Color(0xFF2EC7F0),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    interests,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Stats Logic
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: PokeService.myPokesStream,
                  builder: (context, pokeSnap) {
                    if (pokeSnap.hasError) {
                      return _buildStatsRow(0, 0, 0);
                    }
                    if (!pokeSnap.hasData) {
                      return _buildStatsRow(0, 0, 0);
                    }

                    final pokes = pokeSnap.data!.docs;
                    final totalPokes = pokes.length;

                    // Karma = sum of interested people
                    int karma = 0;
                    for (var doc in pokes) {
                      final data = doc.data();
                      final interested =
                          (data['interestedPeople'] as List<dynamic>?) ?? [];
                      karma += interested.length;
                    }

                    // Streaks = consecutive days with at least one poke
                    // (simplified implementation: just check max streak in sorted list)
                    int currentStreak = 0;
                    if (pokes.isNotEmpty) {
                      // Sort by createdAt descending is already done by query, but let's be safe
                      // We need to group by day
                      final dates = pokes
                          .map((doc) {
                            final ts = doc.data()['createdAt'] as Timestamp?;
                            return ts?.toDate();
                          })
                          .whereType<DateTime>()
                          .toList();

                      if (dates.isNotEmpty) {
                        // simple logic: if last poke was within 24h, streak >= 1.
                        // This logic can be complex, let's stick to a simple "pokes in last 24h" or similar if needed.
                        // But requirement says "poke after every 24 hours".
                        // Let's implement a basic daily streak counter.

                        // We will count unique days in a row starting from today/yesterday.
                        // For now, let's just return a placeholder or simple logic
                        // Logic: Count how many consecutive days going back from now have pokes.
                        currentStreak = _calculateStreak(dates);
                      }
                    }

                    return _buildStatsRow(totalPokes, karma, currentStreak);
                  },
                ),

                const SizedBox(height: 20),

                // // 🔹 Buttons
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 20,
                //     vertical: 16.0,
                //   ),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: ElevatedButton(
                //           onPressed: () {},
                //           style: ElevatedButton.styleFrom(
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(30),
                //             ),
                //             backgroundColor: AppStyling.primaryLight,
                //           ),
                //           child: Padding(
                //             padding: const EdgeInsets.symmetric(vertical: 10.0),
                //             child: const Text(
                //               "Edit Vibe",
                //               style: TextStyle(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w800,
                //                 color: Colors.black,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: ElevatedButton(
                //           onPressed: () {
                //             // This should ideally navigate to CreatePokeScreen or open the modal
                //             // For now we can just show a snackbar or TODO
                //           },
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: const Color(0xFF2EC7F0),
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(30),
                //             ),
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               const Icon(
                //                 Icons.add,
                //                 color: AppStyling.white,
                //                 fontWeight: FontWeight.w700,
                //                 size: 18,
                //               ),
                //               const SizedBox(width: 4.0),
                //               Padding(
                //                 padding: const EdgeInsets.symmetric(
                //                   vertical: 10.0,
                //                 ),
                //                 child: const Text(
                //                   "New Poke",
                //                   style: TextStyle(
                //                     fontWeight: FontWeight.w800,
                //                     fontSize: 16,
                //                     color: AppStyling.white,
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: PokeService.myPokesStream,
                    builder: (context, pokeSnap) {
                      if (!pokeSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final pokes = pokeSnap.data!.docs;

                      // We need to fetch User Details for each UID.
                      // Since we can't do async inside build easily without FutureBuilder,
                      // and we have a list of items, we might need a separate widget that handles fetching user data.

                      if (showActive) {
                        return _buildActiveList(pokes);
                      } else {
                        return _buildMatchedList(pokes);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    // Normalize dates to midnight
    final normalized = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList();
    normalized.sort((a, b) => b.compareTo(a)); // Descending

    if (normalized.isEmpty) return 0;

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    // If the latest poke is not today or yesterday, streak is broken -> 0
    final diff = todayMidnight.difference(normalized.first).inDays;
    if (diff > 1) return 0;

    int streak = 0;
    // DateTime current = normalized.first;

    // Check if we start from today or yesterday
    // If latest is today, count starts at 1. If yesterday, count starts at 1.
    // We need to check continuity backwards.

    // If latest is today, we check previous for yesterday.
    // If latest is yesterday, we check previous for day before yesterday.

    for (int i = 0; i < normalized.length; i++) {
      // Since we are iterating strictly sorted unique days
      // We just check if this date is 1 day before the previous checked date (or is the start date)

      if (i == 0) {
        streak = 1;
        continue;
      }

      final prevDate = normalized[i - 1];
      final currDate = normalized[i];

      if (prevDate.difference(currDate).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Widget _buildStatsRow(int pokes, int karma, int streaks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatBox(title: "$pokes", label: "POKES"),
          const SizedBox(width: 12),
          _StatBox(title: "$karma", label: "KARMA"),
          const SizedBox(width: 12),
          _StatBox(title: "$streaks", label: "STREAKS"),
        ],
      ),
    );
  }

  Widget _buildActiveList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> pokes,
  ) {
    // Filter to show pokes that have interested people
    final activePokesWithInterest = pokes.where((doc) {
      final data = doc.data();
      final interested = data['interestedPeople'] as List?;
      return interested != null && interested.isNotEmpty;
    }).toList();

    if (activePokesWithInterest.isEmpty) {
      return const Center(child: Text("No active pokes with interest yet."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: activePokesWithInterest.length,
      itemBuilder: (context, index) {
        final doc = activePokesWithInterest[index];
        final data = doc.data();
        final pokeId = doc.id;
        final pokeText = data['text'] as String? ?? "Poke";
        final interestedPeople = List<Map<String, dynamic>>.from(
          data['interestedPeople'] ?? [],
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppStyling.primaryLight.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: AppStyling.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pokeText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Interested People:",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: interestedPeople.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final person = interestedPeople[i];
                  final name = person['name'] ?? person['firstName'] ?? 'User';
                  final pic = person['profilePic'];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: pic != null ? NetworkImage(pic) : null,
                      child: pic == null
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        try {
                          await PokeService.matchUser(pokeId, person);
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text("You matched with $name! 🎉"),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(
                            this.context,
                          ).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyling.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text("Allow"),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchedList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> pokes,
  ) {
    final allMatches = <Map<String, dynamic>>[];

    for (var doc in pokes) {
      final data = doc.data();
      final matches = List<Map<String, dynamic>>.from(
        data['matchedPeople'] ?? [],
      );
      final pokeText = data['text'] as String? ?? "Poke";

      for (var match in matches) {
        allMatches.add({...match, 'pokeText': pokeText, 'pokeId': doc.id});
      }
    }

    // Sort by matchedAt descending if available
    allMatches.sort((a, b) {
      final tA = a['matchedAt'] != null
          ? DateTime.parse(a['matchedAt'])
          : DateTime(0);
      final tB = b['matchedAt'] != null
          ? DateTime.parse(b['matchedAt'])
          : DateTime(0);
      return tB.compareTo(tA);
    });

    if (allMatches.isEmpty) {
      return const Center(child: Text("No matches yet."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: allMatches.length,
      itemBuilder: (context, index) {
        final match = allMatches[index];
        return _MatchedUserCard(match: match);
      },
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return "${diff.inMinutes} mins ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";
    return "${diff.inDays} days ago";
  }
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
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // 🔥 FULL-WIDTH INDICATOR
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: 3,
            width: double.infinity, // ✅ THIS IS THE KEY
            decoration: BoxDecoration(
              color: active ? const Color(0xFF2EC7F0) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    ),
  );
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

class _MatchedUserCard extends StatelessWidget {
  final Map<String, dynamic> match;

  const _MatchedUserCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final name = match['name'] ?? match['firstName'] ?? 'Unknown';
    final pic = match['profilePic'];
    final pokeText = match['pokeText'];
    final uid = match['uid'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: pic != null ? NetworkImage(pic) : null,
                child: pic == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "MATCHED",
                      style: TextStyle(
                        fontSize: 10,
                        color: AppStyling.primaryColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "$pokeText",
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  final chatId = await ChatService.createChat(uid, match);
                  if (context.mounted) {
                    context.push(
                      '/app/chat/$chatId',
                      extra: {'name': name, 'otherUid': uid, 'profilePic': pic},
                    );
                  }
                } catch (e) {
                  debugPrint("Error opening chat: $e");
                }
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 19),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppStyling.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                foregroundColor: AppStyling.primaryColor,
              ),
              label: const Text(
                "Message",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
