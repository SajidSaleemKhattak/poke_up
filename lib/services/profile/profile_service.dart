import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  /// Step 1: Basic profile (CreateProfile3)
  static Future<void> updateBasicProfile({
    required String firstName,
    required int age,
    String? profilePicUrl,
  }) async {
    await _firestore.collection('users').doc(_uid).update({
      'firstName': firstName,
      'age': age,
      if (profilePicUrl != null) 'profilePic': profilePicUrl,
    });
  }

  /// Step 2: Interests (InterestSelection4)
  static Future<void> updateInterests(List<String> interests) async {
    await _firestore.collection('users').doc(_uid).update({
      'interests': interests,
      'onboardingCompletedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Used by router / guards
  static bool isBasicProfileComplete(Map<String, dynamic> data) {
    return data['firstName'] != null && data['age'] != null;
  }

  static bool isOnboardingComplete(Map<String, dynamic> data) {
    return isBasicProfileComplete(data) &&
        data['interests'] != null &&
        (data['interests'] as List).isNotEmpty;
  }

  /// 🔹 Get stream of current user profile
  static Stream<DocumentSnapshot<Map<String, dynamic>>> get myProfileStream {
    return _firestore.collection('users').doc(_uid).snapshots();
  }

  /// 🔹 Get user data by UID
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<String> uploadProfilePic(File file) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final ref = FirebaseStorage.instance.ref(
      'profile_pics/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final snapshot = await ref.putFile(file, metadata);
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  static Future<void> updateProfilePic(String url) async {
    await _firestore.collection('users').doc(_uid).update({'profilePic': url});
  }
}
