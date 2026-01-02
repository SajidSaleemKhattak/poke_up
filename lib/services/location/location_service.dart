import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  static final GeoFlutterFire _geo = GeoFlutterFire();

  /// one-shot
  static Future<Position?> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p != LocationPermission.whileInUse && p != LocationPermission.always)
      return null;
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  /// continuous stream (battery-friendly)
  static Stream<Position> stream() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      distanceFilter: 50,
      accuracy: LocationAccuracy.high,
    ),
  );

  /// city name for header
  static Future<String> cityFrom(Position p) async {
    final list = await placemarkFromCoordinates(p.latitude, p.longitude);
    if (list.isEmpty) return 'Nearby';
    return list.first.locality ?? 'Nearby';
  }

  /// posts within radiusKm
  static Stream<List<DocumentSnapshot>> nearbyPosts(
    Position center,
    double radiusKm,
  ) {
    final geoPoint = GeoFirePoint(center.latitude, center.longitude);
    return _geo
        .collection(
          collectionRef: FirebaseFirestore.instance.collection('posts'),
        )
        .within(
          center: geoPoint,
          radius: radiusKm,
          field: 'geoPoint',
          strictMode: true,
        );
  }

  /// returns true if we end up with a usable location
  static Future<bool> requestPermission() async {
    final pos = await current(); // already asks permission inside
    return pos != null;
  }
}
