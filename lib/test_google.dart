import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleTest {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> testWithGooglePackage() async {
    try {
      print('Testing with google_sign_in package...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('User cancelled');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print('Success! User: ${userCredential.user?.email}');
    } catch (e) {
      print('Error with google_sign_in: $e');
    }
  }

  static Future<void> testWithFirebaseOnly() async {
    try {
      print('Testing with Firebase only...');

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final UserCredential userCredential =
          await _auth.signInWithProvider(googleProvider);
      print('Success! User: ${userCredential.user?.email}');
    } catch (e) {
      print('Error with Firebase only: $e');
    }
  }
}
