import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// 🚪 Sign out from BOTH Google & Firebase
  static Future<void> signOut() async {
    await _googleSignIn.signOut(); // clears account chooser cache
    await _auth.signOut(); // Firebase logout
  }
}
