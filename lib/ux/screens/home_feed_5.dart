import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:poke_up/services/location/location_service.dart';
import 'package:poke_up/services/poke/poke_service.dart';
import 'package:poke_up/ux/sub_screens/create_poke_screen.dart';

class HomeFeed5 extends StatefulWidget {
  const HomeFeed5({super.key});

  @override
  State<HomeFeed5> createState() => _HomeFeed5State();
}

class _HomeFeed5State extends State<HomeFeed5> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final pos = await LocationService.current();
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 239, 239),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyling.primaryColor,
        onPressed: () async {
          // 1. Check Service
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Please enable Location Services to create a poke.",
                  ),
                ),
              );
            }
            return;
          }

          // 2. Check Permission
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            // 3. Ask Permission
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
              // 4. Denied
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Pokes cannot be created without location access.",
                    ),
                  ),
                );
              }
              return;
            }
          }

          if (permission == LocationPermission.deniedForever) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Location permission is permanently denied. Please enable it in settings.",
                  ),
                ),
              );
            }
            return;
          }

          // 5. Proceed (Get Location)
          try {
            final position = await LocationService.current();

            if (position == null) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Unable to get current location."),
                  ),
                );
              }
              return;
            }

            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePokeScreen(position: position),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error fetching location.")),
              );
            }
          }
        },
        child: const Icon(Icons.add, size: 28, color: AppStyling.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "LOCATION",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Text(
                            "Nearby Vibes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppStyling.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: const [
                      Icon(Icons.notifications_none, size: 28),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 🔹 Filters
            SizedBox(
              height: 38,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: const [
                  _FilterChip(label: "All", active: true),
                  _FilterChip(label: "<1 mile"),
                  _FilterChip(label: "Coffee"),
                  _FilterChip(label: "Sports"),
                  _FilterChip(label: "Gaming"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 🔹 Feed
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: PokeService.homeFeedStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final pokes = snapshot.data ?? [];
                  if (pokes.isEmpty) {
                    return const Center(
                      child: Text("No pokes nearby. Create one!"),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pokes.length,
                    itemBuilder: (context, index) {
                      final poke = pokes[index];
                      return _PokeCard(
                        poke: poke,
                        currentPosition: _currentPosition,
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

class _PokeCard extends StatelessWidget {
  final Map<String, dynamic> poke;
  final Position? currentPosition;

  const _PokeCard({required this.poke, this.currentPosition});

  @override
  Widget build(BuildContext context) {
    final uid = poke['uid'] as String;
    final text = poke['text'] as String? ?? "";
    final category = poke['category'] as String? ?? "General";
    final locationMap = poke['location'] as Map<String, dynamic>?;
    final createdAt = (poke['createdAt'] as Timestamp?)?.toDate();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // Loading...
        }
        final userDoc = snapshot.data!;
        if (!userDoc.exists) return const SizedBox.shrink();

        final userData = userDoc.data() as Map<String, dynamic>?;
        final name = userData?['firstName'] as String? ?? "Unknown";
        final ageRange = userData?['ageRange'] as String?;
        final profilePic = userData?['profilePic'] as String?;

        final displayAge = ageRange ?? "";

        // Calculate distance
        String distanceStr = "";
        if (currentPosition != null && locationMap != null) {
          final double lat = locationMap['lat'];
          final double lng = locationMap['lng'];
          final double distInMeters = Geolocator.distanceBetween(
            currentPosition!.latitude,
            currentPosition!.longitude,
            lat,
            lng,
          );
          final double distInMiles = distInMeters * 0.000621371;
          distanceStr = "${distInMiles.toStringAsFixed(1)} mi";
        }

        // Time ago
        String timeAgo = "";
        if (createdAt != null) {
          final diff = DateTime.now().difference(createdAt);
          if (diff.inMinutes < 60) {
            timeAgo = "${diff.inMinutes} mins ago";
          } else if (diff.inHours < 24) {
            timeAgo = "${diff.inHours} hrs ago";
          } else {
            timeAgo = "${diff.inDays} days ago";
          }
        }

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
                  CircleAvatar(
                    backgroundImage: profilePic != null
                        ? NetworkImage(profilePic)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: profilePic == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayAge.isNotEmpty ? "$name, $displayAge" : name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "$category • $timeAgo",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (distanceStr.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppStyling.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        distanceStr,
                        style: const TextStyle(
                          color: AppStyling.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle join
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Join 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: active ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
