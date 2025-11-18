// lib/service/google_auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Configuration Google Sign-In avec le vrai Web Client ID  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web client ID depuis Firebase Console (pour OAuth)
    serverClientId: '266056580802-s1n7ha6hvuqoiqsqqri67pprmpg10p4a.apps.googleusercontent.com',
  );

  /// Main method for Google Sign-In
  /// Utilise google_sign_in package pour Android/iOS et Firebase Auth pour Web
  static Future<User?> signInWithGoogle() async {
    try {
      if (kDebugMode) print('GoogleAuthService: Starting sign-in...');

      UserCredential credential;

      if (kIsWeb) {
        // Pour le Web, utiliser Firebase Auth directement
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile')
          ..setCustomParameters({'prompt': 'select_account'});
        
        credential = await _auth.signInWithPopup(provider);
      } else {
        // Pour Android/iOS, utiliser google_sign_in package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          if (kDebugMode) print('GoogleAuthService: User cancelled sign-in');
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(authCredential);
      }

      final user = credential.user;
      if (user != null && kDebugMode) {
        print('GoogleAuthService: Sign-in successful for ${user.email}');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('GoogleAuthService FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('GoogleAuthService error: $e');
      rethrow;
    }
  }

  /// Save user data to Firestore
  static Future<void> saveUserToFirestore(User user) async {
    try {
      final userDoc = _firestore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid);

      await userDoc.set({
        "Email": user.email ?? "",
        "fullName": user.displayName ?? "",
        "photoURL": user.photoURL ?? "",
        "provider": "google",
        "createdAt": FieldValue.serverTimestamp(),
        "uid": user.uid,
      }, SetOptions(merge: true));

      if (kDebugMode) print('GoogleAuthService: User data saved to Firestore');
    } catch (e) {
      if (kDebugMode) print('GoogleAuthService Firestore error: $e');
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      if (kDebugMode) print('GoogleAuthService: Sign-out successful');
    } catch (e) {
      if (kDebugMode) print('GoogleAuthService sign-out error: $e');
      rethrow;
    }
  }

  /// Check if user is signed in
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}