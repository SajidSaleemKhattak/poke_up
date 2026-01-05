import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<String> createChat(
    String otherUserId,
    Map<String, dynamic> otherUserData,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ids = [user.uid, otherUserId]..sort();
    final conversationId = '${ids[0]}_${ids[1]}';

    final existing = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .get();
    if (existing.exists) return conversationId;

    final myDoc = await _firestore.collection('users').doc(user.uid).get();
    final myData = myDoc.data()!;

    await _firestore.collection('conversations').doc(conversationId).set({
      'conversation_id': conversationId,
      'participants': [user.uid, otherUserId],
      'participantDetails': {
        user.uid: {
          'name': myData['firstName'] ?? 'User',
          'profilePic': myData['profilePic'],
        },
        otherUserId: {
          'name': otherUserData['name'] ?? otherUserData['firstName'] ?? 'User',
          'profilePic': otherUserData['profilePic'],
        },
      },
      'last_message': 'Chat started',
      'last_message_time': FieldValue.serverTimestamp(),
      'last_read': {user.uid: FieldValue.serverTimestamp(), otherUserId: null},
      'created_at': FieldValue.serverTimestamp(),
    });

    return conversationId;
  }

  static Future<void> sendMessage(String chatId, String text) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });

    await _firestore.collection('conversations').doc(chatId).update({
      'last_message': text.trim(),
      'last_message_time': FieldValue.serverTimestamp(),
      'last_read': {
        user.uid: FieldValue.serverTimestamp(),
      },
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> get myChatsStream {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesStream(
    String chatId,
  ) {
    return _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  static Future<void> markConversationRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('conversations').doc(chatId).update({
      'last_read': {user.uid: FieldValue.serverTimestamp()},
    });
  }

  static Stream<int> get unreadConversationsCountStream {
    final user = _auth.currentUser;
    if (user == null) return const Stream<int>.empty();
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) {
      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp? lastMsg = data['last_message_time'] as Timestamp?;
        final Map<String, dynamic>? lastRead =
            data['last_read'] as Map<String, dynamic>?;
        Timestamp? myRead = lastRead?[user.uid] as Timestamp?;
        if (lastMsg != null) {
          if (myRead == null || lastMsg.compareTo(myRead) > 0) {
            count++;
          }
        }
      }
      return count;
    });
  }
}
