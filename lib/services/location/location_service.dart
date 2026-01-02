import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Request permission and return true if granted
  static Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position (returns null if permission denied)
  static Future<Position?> current() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  /// 🔹 Update User Location in Firestore
  static Future<void> updateUserLocation(Position position) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'currentLocation': {
        'lat': position.latitude,
        'lng': position.longitude,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    });
  }

  /// 🔹 Get readable address (City, State)
  static Future<String?> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // e.g. "San Francisco, CA" or "New York"
        if (place.locality != null && place.administrativeArea != null) {
          return "${place.locality}, ${place.administrativeArea}";
        }
        return place.locality ?? place.administrativeArea ?? "Unknown Location";
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
