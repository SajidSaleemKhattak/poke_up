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
}
