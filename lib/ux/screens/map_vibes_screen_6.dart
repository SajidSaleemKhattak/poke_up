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

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() => _position = pos);
  }

  Future<void> _openExternalNavigation(LatLng dest) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${dest.latitude},${dest.longitude}&travelmode=walking',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final center = LatLng(_position!.latitude, _position!.longitude);

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: PokeService.nearbyPokesStream(
          lat: center.latitude,
          lng: center.longitude,
          radiusKm: 10,
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
      ),
    );
  }
}
