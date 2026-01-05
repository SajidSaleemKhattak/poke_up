import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poke_up/services/chat/chat_service.dart';

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

    final ref = await _firestore.collection('pokes').add({
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

    await _addNotification(
      user.uid,
      {
        'type': 'poke_posted',
        'title': 'Poke posted',
        'body': 'Your poke was posted successfully',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'action': {'route': '/app/profile'},
        'pokeId': ref.id,
      },
    );
  }

  /// 🔹 Join a Poke
  static Future<void> joinPoke(String pokeId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Fetch basic user details to store in the array (denormalization)
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) throw Exception('User profile not found');

    final userData = userDoc.data()!;
    final joinerInfo = {
      'uid': user.uid,
      'name': userData['firstName'] ?? 'Unknown',
      'profilePic': userData['profilePic'],
      'joinedAt': DateTime.now().toIso8601String(),
    };

    await _firestore.collection('pokes').doc(pokeId).update({
      'interestedPeople': FieldValue.arrayUnion([joinerInfo]),
    });

    final pokeSnap = await _firestore.collection('pokes').doc(pokeId).get();
    final pokeData = pokeSnap.data();
    final ownerUid = pokeData?['uid'] as String?;
    final text = pokeData?['text'] as String? ?? '';
    if (ownerUid != null) {
      await _addNotification(
        ownerUid,
        {
          'type': 'interest',
          'title': 'New interest',
          'body': '${joinerInfo['name']} is interested in your poke',
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
          'action': {'route': '/app/profile'},
          'pokeId': pokeId,
          'actorUid': user.uid,
          'pokeText': text,
        },
      );
    }
  }

  /// 🔹 Match a User
  static Future<void> matchUser(
    String pokeId,
    Map<String, dynamic> interestedUser,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final otherUid = interestedUser['uid'];

    // 1. Move from interested to matched
    final pokeRef = _firestore.collection('pokes').doc(pokeId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(pokeRef);
      if (!snapshot.exists) throw Exception("Poke not found");

      final data = snapshot.data()!;
      final interested = List<Map<String, dynamic>>.from(
        data['interestedPeople'] ?? [],
      );
      final matched = List<Map<String, dynamic>>.from(
        data['matchedPeople'] ?? [],
      );

      // Remove from interested
      interested.removeWhere((p) => p['uid'] == otherUid);

      // Add to matched (add matchedAt timestamp)
      final matchedUser = Map<String, dynamic>.from(interestedUser);
      matchedUser['matchedAt'] = DateTime.now().toIso8601String();
      matched.add(matchedUser);

      transaction.update(pokeRef, {
        'interestedPeople': interested,
        'matchedPeople': matched,
      });
    });

    // 2. Create Chat & Send Message
    final chatId = await ChatService.createChat(otherUid, interestedUser);
    await ChatService.sendMessage(chatId, "we matched");

    // 3. Notify the matched user
    await _addNotification(
      otherUid,
      {
        'type': 'matched',
        'title': 'You got matched',
        'body': 'You matched with ${_auth.currentUser?.displayName ?? 'someone'}',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'action': {'route': '/app/conversations'},
        'pokeId': pokeId,
        'actorUid': user.uid,
      },
    );
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
          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                final uid = data['uid'] as String?;
                // 1. Filter out my own pokes
                if (uid == user.uid) return false;

                // 2. Filter expired pokes
                final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                final validHours = data['validForHours'] as num? ?? 24;
                if (createdAt == null) return false;

                final expiresAt = createdAt.add(
                  Duration(minutes: (validHours * 60).toInt()),
                );
                if (now.isAfter(expiresAt)) return false;

                return true;
              })
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        });
  }

  /// 🔹 Get stream of nearby pokes within [radiusKm] of [lat,lng]
  static Stream<List<Map<String, dynamic>>> nearbyPokesStream({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('pokes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final radiusMeters = radiusKm * 1000;
          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                final uid = data['uid'] as String?;
                if (uid == user.uid) return false;

                final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                final validHours = data['validForHours'] as num? ?? 24;
                if (createdAt == null) return false;
                final expiresAt = createdAt.add(
                  Duration(minutes: (validHours * 60).toInt()),
                );
                if (now.isAfter(expiresAt)) return false;

                final location = data['location'] as Map<String, dynamic>?;
                final pLat = (location?['lat'] as num?)?.toDouble();
                final pLng = (location?['lng'] as num?)?.toDouble();
                if (pLat == null || pLng == null) return false;

                final distance = Geolocator.distanceBetween(
                  lat,
                  lng,
                  pLat,
                  pLng,
                );
                return distance <= radiusMeters;
              })
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        });
  }

  static Future<void> _addNotification(
    String userUid,
    Map<String, dynamic> payload,
  ) async {
    await _firestore
        .collection('notifications')
        .doc(userUid)
        .collection('items')
        .add(payload);
  }
}
