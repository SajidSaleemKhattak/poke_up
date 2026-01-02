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

  /// 🔹 Get stream of my pokes (ordered by time)
  static Stream<QuerySnapshot<Map<String, dynamic>>> get myPokesStream {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('pokes')
        .where('uid', isEqualTo: user.uid)
        .snapshots();
  }

  /// 🔹 Get stream of home feed pokes (everyone else's pokes)
  static Stream<List<Map<String, dynamic>>> get homeFeedStream {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('pokes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final uid = data['uid'] as String?;
        // 1. Filter out my own pokes
        if (uid == user.uid) return false;

        // 2. Filter expired pokes
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final validHours = data['validForHours'] as num? ?? 24;
        if (createdAt == null) return false;

        final expiresAt =
            createdAt.add(Duration(minutes: (validHours * 60).toInt()));
        if (now.isAfter(expiresAt)) return false;

        return true;
      }).map((doc) => {...doc.data(), 'id': doc.id}).toList();
    });
  }
}
