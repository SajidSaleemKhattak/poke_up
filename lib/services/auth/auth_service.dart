import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // IMPORTANT: keep GoogleSignIn as a singleton
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  /// Currently authenticated Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Firebase auth state stream (global auth listener)
  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// 🔐 Google Sign-In (FORCES account chooser every time)
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // 🔴 VERY IMPORTANT
      // This forces Google account selection every time
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User closed the picker
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // 🔹 Check if user doc exists, if not create it (Validation Logic Support)
      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'email': userCredential.user!.email,
                'uid': userCredential.user!.uid,
                'createdAt': FieldValue.serverTimestamp(),
                'firstName': null,
                'age': null,
                'interests': [],
                'currentLocation': null, // 📍 New field for location gating
                'lastName': null,
                'profilePic': userCredential.user!.photoURL,
              });
        }
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// 🚪 Sign out from BOTH Google & Firebase
  static Future<void> signOut() async {
    await _googleSignIn.signOut(); // clears account chooser cache
    await _auth.signOut(); // Firebase logout
  }

  static Future<UserCredential> signUpWithEmail(
    String email,
    String password,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'firstName': null,
          'age': null,
          'interests': [],
          'currentLocation': null,
          'lastName': null,
          'profilePic': user.photoURL,
        });
      }
    }
    return cred;
  }

  static Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
}
