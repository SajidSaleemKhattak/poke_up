import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:poke_up/services/location/location_service.dart';
import 'package:poke_up/ux/sub_screens/create_poke_screen.dart';

class HomeFeed5 extends StatelessWidget {
  const HomeFeed5({super.key});

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
            // const SizedBox(height: 12),

            // 🔹 Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 16), // L, T, R, B
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _VibeCard(
                    name: "Sarah",
                    age: "21",
                    tag: "Student • 5 mins ago",
                    distance: "0.2 mi",
                    text:
                        "Bored at the library, someone come save me with coffee? ☕️",
                    buttonText: "Join 👋",
                  ),

                  _VibeCard(
                    name: "Mike",
                    age: "23",
                    tag: "Athlete • 12 mins ago",
                    distance: "1.5 mi",
                    text: "Spikeball at the park in 20 mins. Need a 4th! 🏐",
                    buttonText: "I'm Down 🔥",
                    showMap: true,
                  ),

                  _VibeCard(
                    name: "Jessica",
                    age: "20",
                    tag: "Gamer • 30 mins ago",
                    distance: "0.8 mi",
                    text: "Anyone down for a quick Mario Kart session? 🏎️",
                    buttonText: "Let's Go 🎮",
                  ),

                  _VibeCard(
                    name: "Alex",
                    age: "22",
                    tag: "Quiet • 1 hr ago",
                    distance: "0.1 mi",
                    text:
                        "Quiet study session at the cafe. Don't talk to me unless it's snacks. 🤫🥐",
                    buttonText: "Quietly Join 🤫",
                    highlighted: true,
                  ),

                  SizedBox(height: 80),
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
/// Filter Chip
/// ===============================
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;

  const _FilterChip({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: active ? Colors.black : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// Vibe Card
/// ===============================
class _VibeCard extends StatelessWidget {
  final String name;
  final String age;
  final String tag;
  final String distance;
  final String text;
  final String buttonText;
  final bool showMap;
  final bool highlighted;

  const _VibeCard({
    required this.name,
    required this.age,
    required this.tag,
    required this.distance,
    required this.text,
    required this.buttonText,
    this.showMap = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? AppStyling.highlighting
            : const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "$name",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        "$age",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                          color: AppStyling.secondaryColor,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    tag,
                    style: const TextStyle(
                      color: AppStyling.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppStyling.primaryLight,
                ),
                child: Text(
                  distance,
                  style: const TextStyle(
                    color: AppStyling.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),

          if (showMap) ...[
            const SizedBox(height: 16),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text("Map Preview")),
            ),
          ],

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: highlighted
                    ? AppStyling.secondaryBtnColor
                    : AppStyling.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: AppStyling.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
