import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class PokeService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> createPoke({
    required String text,
    required String category,
    required double validForHours,
    required bool friendsOnly,
    required Position position,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('pokes').add({
      'uid': user.uid,
      'text': text.trim(),
      'category': category,
      'validForHours': validForHours,
      'friendsOnly': friendsOnly,

      'location': {'lat': position.latitude, 'lng': position.longitude},

      // social state
      'interestedPeople': [],
      'matchedPeople': [],

      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
