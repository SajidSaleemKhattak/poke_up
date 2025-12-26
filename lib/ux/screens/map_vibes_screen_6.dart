import 'package:flutter/material.dart';

class MapVibesScreen extends StatelessWidget {
  const MapVibesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          /// 🔹 Map Placeholder (replace later with GoogleMap)
          Container(color: const Color(0xFFF2F2F2)),

          /// 🔹 Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _searchBar(),
                  const SizedBox(height: 12),
                  _categoryChips(),
                ],
              ),
            ),
          ),

          /// 🔹 Center Pulse Marker
          Center(child: _pulseMarker()),

          /// 🔹 Floating Controls
          Positioned(right: 16, top: 220, child: _zoomControls()),

          Positioned(right: 16, bottom: 200, child: _compassButton()),

          /// 🔹 Location Tag
          Positioned(left: 16, bottom: 260, child: _locationTag()),

          /// 🔹 Bottom Live Card
          Positioned(left: 0, right: 0, bottom: 0, child: _liveNowCard()),
        ],
      ),
    );
  }

  // =========================
  // Widgets
  // =========================

  Widget _searchBar() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Color(0xFF2EC7F0)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Find a vibe nearby...",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          Icon(Icons.tune, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _categoryChips() {
    return Row(
      children: const [
        _Chip(active: true, label: "All Vibes"),
        SizedBox(width: 10),
        _Chip(icon: Icons.local_fire_department, label: "Trending"),
        SizedBox(width: 10),
        _Chip(icon: Icons.school, label: "Study"),
      ],
    );
  }

  Widget _pulseMarker() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2EC7F0).withOpacity(0.15),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2EC7F0),
              ),
              child: const Icon(Icons.map, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: const Text(
                "12",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoomControls() {
    return Column(
      children: [
        _circleButton(Icons.add),
        const SizedBox(height: 10),
        _circleButton(Icons.remove),
      ],
    );
  }

  Widget _compassButton() {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: const Icon(Icons.navigation, color: Colors.black),
    );
  }

  Widget _locationTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.local_fire_department, color: Colors.orange),
          SizedBox(width: 8),
          Text("Downtown Plaza", style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _liveNowCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              "https://images.unsplash.com/photo-1520974735194-6c3d5c1f8f4f",
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: const [
              _LiveBadge(),
              SizedBox(width: 8),
              Text(
                "Downtown Plaza",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),

          const SizedBox(height: 6),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text("0.4 mi away", style: TextStyle(color: Colors.grey)),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(
                child: Text(
                  "Very active • Friends are here",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFF2EC7F0),
                ),
                child: Row(
                  children: const [
                    Text(
                      "I'm Heading There",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Icon(icon),
    );
  }
}

// =========================
// Small Widgets
// =========================

class _Chip extends StatelessWidget {
  final bool active;
  final String label;
  final IconData? icon;

  const _Chip({this.active = false, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: active ? Colors.black : Colors.white,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: active ? Colors.white : Colors.black),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "LIVE NOW",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
