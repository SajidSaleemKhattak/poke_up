import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:poke_up/services/location/location_service.dart';
import 'package:poke_up/services/poke/poke_service.dart';
import 'package:poke_up/ux/sub_screens/create_poke_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_up/services/profile/profile_service.dart';

class HomeFeed5 extends StatefulWidget {
  const HomeFeed5({super.key});

  @override
  State<HomeFeed5> createState() => _HomeFeed5State();
}

class _HomeFeed5State extends State<HomeFeed5> {
  Position? _currentPosition;
  String? _currentAddress;
  String _selectedFilter = "All";
  bool _isLoadingLocation = false;
  bool _showNotifications = false;

  final List<String> _filters = [
    "All",
    "<1 mile",
    "<3 miles",
    "<7 miles",
    "<10 miles",
    "Food",
    "Chill",
    "Active",
    "Study",
    "Party",
    "Gaming",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    // Try to fetch location on init (silent check)
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      // Check permission first without requesting if possible, but LocationService.current() requests it.
      // We'll trust LocationService to handle the flow, or we can check permission manually first.
      // The user wants: "if we dont have it we would say something like no location"
      // So initially, if we don't have permission, we just stay in "No Location" state.

      final pos = await LocationService.current();
      if (mounted && pos != null) {
        // 1. Update State
        final address = await LocationService.getAddressFromPosition(pos);
        setState(() {
          _currentPosition = pos;
          _currentAddress = address;
        });

        // 2. Update Firestore
        await LocationService.updateUserLocation(pos);
      } else {
        if (mounted) {
          setState(() {
            _currentPosition = null;
            _currentAddress = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _requestLocationAccess() async {
    // This is called when user taps the header or the big button
    await _fetchLocation();

    if (_currentPosition == null && mounted) {
      // If still null, it means permission denied or service disabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enable Location Services.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Location permission is permanently denied. Please enable it in settings.",
            ),
            action: SnackBarAction(
              label: "Settings",
              onPressed: Geolocator.openAppSettings,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location access is required to view pokes nearby."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 239, 239),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyling.primaryColor,
        onPressed: () async {
          if (_currentPosition == null) {
            await _requestLocationAccess();
            return;
          }

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreatePokeScreen(position: _currentPosition!),
              ),
            );
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
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: ProfileService.myProfileStream,
                    builder: (context, snap) {
                      final data = snap.data?.data();
                      final profilePic = data?['profilePic'] as String?;
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        backgroundImage: profilePic != null
                            ? NetworkImage(profilePic)
                            : null,
                        child: profilePic == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _requestLocationAccess,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "LOCATION",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Row(
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                _currentAddress ?? "No Location Access",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _currentPosition != null
                                  ? Icons.location_on
                                  : Icons.location_off,
                              size: 16,
                              color: _currentPosition != null
                                  ? AppStyling.primaryColor
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      context.push('/notifications');
                    },
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _notificationsStream,
                      builder: (context, snap) {
                        final hasUnread = (snap.data?.docs ?? []).any(
                          (d) => (d.data()['read'] as bool?) == false,
                        );
                        return Stack(
                          children: [
                            const Icon(Icons.notifications_none, size: 28),
                            if (hasUnread)
                              const Positioned(
                                right: 0,
                                top: 0,
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: Colors.red,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // 🔹 Filters
            SizedBox(
              height: 38,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  return GestureDetector(
                    onTap: () {
                      if (_currentPosition == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Enable location to use filters."),
                          ),
                        );
                        _requestLocationAccess();
                        return;
                      }
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: _FilterChip(
                      label: filter,
                      active: _selectedFilter == filter,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 0),
            // 🔹 Feed or Location Prompt
            Expanded(
              child: _currentPosition == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Enable Location to see Pokes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _requestLocationAccess,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyling.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoadingLocation
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Allow Access"),
                          ),
                        ],
                      ),
                    )
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: PokeService.homeFeedStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        final allPokes = snapshot.data ?? [];

                        // 🔎 Filter Logic
                        final filteredPokes = allPokes.where((poke) {
                          // 1. Must have location
                          final loc = poke['location'] as Map<String, dynamic>?;
                          if (loc == null || _currentPosition == null)
                            return false;

                          // 2. Calculate Distance
                          final double lat = loc['lat'];
                          final double lng = loc['lng'];
                          final double distMeters = Geolocator.distanceBetween(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            lat,
                            lng,
                          );
                          final double distMiles = distMeters * 0.000621371;

                          // 3. Base Constraint: < 15 miles
                          if (distMiles >= 15.0) return false;

                          // 4. Specific Filters
                          if (_selectedFilter == "All") return true;

                          // Distance Filters
                          if (_selectedFilter.startsWith("<")) {
                            if (_selectedFilter == "<1 mile") {
                              return distMiles < 1.0;
                            } else if (_selectedFilter == "<3 miles") {
                              return distMiles < 3.0;
                            } else if (_selectedFilter == "<7 miles") {
                              return distMiles < 7.0;
                            } else if (_selectedFilter == "<10 miles") {
                              return distMiles < 10.0;
                            }
                          }

                          // Category Filters
                          // Check exact match or "Others"
                          final category =
                              poke['category'] as String? ?? "Others";
                          if (_selectedFilter == "Others") {
                            // If it's not one of the main categories, it's Others
                            const mainCats = {
                              "Food",
                              "Chill",
                              "Active",
                              "Study",
                              "Party",
                              "Gaming",
                            };
                            return !mainCats.contains(category);
                          } else {
                            return category == _selectedFilter;
                          }
                        }).toList();

                        if (filteredPokes.isEmpty) {
                          return Center(
                            child: Text(
                              "No pokes found for $_selectedFilter",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 0),
                          itemCount: filteredPokes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 0),
                          itemBuilder: (context, index) {
                            return _PokeCard(
                              poke: filteredPokes[index],
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

extension on _HomeFeed5State {
  Stream<QuerySnapshot<Map<String, dynamic>>> get _notificationsStream {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  Widget _buildNotificationsPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error loading notifications");
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Text("No notifications");
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final title = data['title'] as String? ?? '';
              final body = data['body'] as String? ?? '';
              final read = data['read'] as bool? ?? false;
              return ListTile(
                dense: true,
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: read ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
                subtitle: Text(body),
                onTap: () async {
                  final action = data['action'] as Map<String, dynamic>?;
                  final docRef = docs[i].reference;
                  await docRef.update({'read': true});
                  if (action != null) {
                    final route = action['route'] as String?;
                    if (route != null) {
                      if (mounted) context.push(route);
                    }
                  }
                  setState(() => _showNotifications = false);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PokeCard extends StatefulWidget {
  final Map<String, dynamic> poke;
  final Position? currentPosition;

  const _PokeCard({required this.poke, this.currentPosition});

  @override
  State<_PokeCard> createState() => _PokeCardState();
}

class _PokeCardState extends State<_PokeCard> {
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    final pokeId = widget.poke['id'] as String;
    final uid = widget.poke['uid'] as String;
    final text = widget.poke['text'] as String? ?? "";
    final category = widget.poke['category'] as String? ?? "General";
    final locationMap = widget.poke['location'] as Map<String, dynamic>?;
    final createdAt = (widget.poke['createdAt'] as Timestamp?)?.toDate();
    final interestedPeople = widget.poke['interestedPeople'] as List?;

    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isAlreadyInterested =
        interestedPeople != null &&
        currentUser != null &&
        interestedPeople.any((p) => p['uid'] == currentUser.uid);

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
        if (widget.currentPosition != null && locationMap != null) {
          final double lat = locationMap['lat'];
          final double lng = locationMap['lng'];
          final double distInMeters = Geolocator.distanceBetween(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
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
          margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Container(
              // margin: const EdgeInsets.only(bottom: 16),
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
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18, // bigger, bold name
                                    color: Colors.black,
                                  ),
                                ),
                                if (displayAge.isNotEmpty)
                                  TextSpan(
                                    text: ", $displayAge",
                                    style: const TextStyle(
                                      fontWeight: FontWeight
                                          .normal, // or w500 if you want a bit of weight
                                      fontSize: 14, // smaller age
                                      color: Colors.black,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            "$category • $timeAgo",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 80.0,

                      child: ElevatedButton(
                        onPressed: isAlreadyInterested || _isJoining
                            ? null
                            : () async {
                                setState(() => _isJoining = true);
                                try {
                                  await PokeService.joinPoke(pokeId);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "You joined this poke! 🎉",
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Failed to join: $e"),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted)
                                    setState(() => _isJoining = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAlreadyInterested
                              ? AppStyling.primaryColorLight
                              : AppStyling.primaryColor,
                          disabledBackgroundColor: AppStyling.primaryColorLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isJoining
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isAlreadyInterested ? "Joined" : "Join 👋",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
