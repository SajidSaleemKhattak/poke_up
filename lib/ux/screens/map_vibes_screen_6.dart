import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poke_up/services/poke/poke_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MapVibesScreen extends StatefulWidget {
  const MapVibesScreen({super.key});

  @override
  State<MapVibesScreen> createState() => _MapVibesScreenState();
}

class _MapVibesScreenState extends State<MapVibesScreen> {
  GoogleMapController? _mapController;
  Position? _position;
  bool _locationDenied = false;
  bool _serviceDisabled = false;
  double _radiusKm = 10;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _serviceDisabled = true;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationDenied = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationDenied = true;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _position = pos;
        _serviceDisabled = false;
        _locationDenied = false;
      });
    } catch (e) {
      setState(() {
        _locationDenied = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          if (_position == null) ...[
            _buildLocationGate(),
          ] else ...[
            _buildGoogleMap(),
          ],

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

  Widget _buildLocationGate() {
    final text = _serviceDisabled
        ? "Turn on Location Services to view nearby pokes"
        : _locationDenied
        ? "Allow location permission to show nearby pokes"
        : "Fetching location...";
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          if (_serviceDisabled)
            ElevatedButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
              },
              child: const Text("Open Settings"),
            )
          else if (_locationDenied)
            ElevatedButton(
              onPressed: _initLocation,
              child: const Text("Retry"),
            ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    final center = LatLng(_position!.latitude, _position!.longitude);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: PokeService.nearbyPokesStream(
        lat: center.latitude,
        lng: center.longitude,
        radiusKm: _radiusKm,
      ),
      builder: (context, snapshot) {
        final markers = <Marker>{};
        if (snapshot.hasData) {
          for (final poke in snapshot.data!) {
            final loc = poke['location'] as Map<String, dynamic>?;
            final pLat = (loc?['lat'] as num?)?.toDouble();
            final pLng = (loc?['lng'] as num?)?.toDouble();
            if (pLat == null || pLng == null) continue;
            final id = poke['id'] as String? ?? '${pLat}_${pLng}';
            final text = poke['text'] as String? ?? 'Poke';
            final category = poke['category'] as String? ?? 'Vibe';

            markers.add(
              Marker(
                markerId: MarkerId(id),
                position: LatLng(pLat, pLng),
                infoWindow: InfoWindow(
                  title: category,
                  snippet: text,
                  onTap: () => _openExternalNavigation(LatLng(pLat, pLng)),
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
            );
          }
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(target: center, zoom: 14),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          markers: markers,
          onMapCreated: (c) => _mapController = c,
        );
      },
    );
  }

  Future<void> _openExternalNavigation(LatLng dest) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${dest.latitude},${dest.longitude}&travelmode=walking',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
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
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.05),
          ),
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

  Widget _zoomControls() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
          child: _circleButton(Icons.add),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
          child: _circleButton(Icons.remove),
        ),
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
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            _position != null
                ? "Lat ${_position!.latitude.toStringAsFixed(3)}, Lng ${_position!.longitude.toStringAsFixed(3)}"
                : "Location",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
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
            child: Container(
              height: 140,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.place, color: Colors.grey, size: 40),
              ),
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
