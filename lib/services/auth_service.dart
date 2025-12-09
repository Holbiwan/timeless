
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model_unified.dart';

// AuthService
// Centralized authentication logic for Timeless.
// Handles:
// - Email/Password sign up & login
// - Google Sign-In
// - Password reset
// - Logout
// - User state stream (auth changes)
// - Firestore user profile creation/update

class AuthService extends GetxController {
  static AuthService get instance => Get.find();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Reactive variables for user state (used by GetX for UI updates)
  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen for changes in authentication state in real-time
    user.bindStream(_auth.authStateChanges());
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    try {
      isLoading.value = true;
      
      // Create new firebase account with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update FIrebase user display name
        await credential.user!.updateDisplayName(name);
        
        // Build unified user model profile model
        UserModel userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          firstName: name.split(' ').first,
          lastName: name.split(' ').length > 1 ? name.split(' ').skip(1).join(' ') : '',
          fullName: name,
          phoneNumber: null,
          photoURL: credential.user!.photoURL,
          title: '',
          bio: '',
          experience: 'junior',
          city: '',
          jobPreferences: {
            'categories': [],
            'workType': ['remote', 'hybrid', 'onsite'],
            'contractType': ['fulltime'],
            'salaryRange': {'min': null, 'max': null, 'currency': 'EUR'}
          },
          savedJobs: [],
          appliedJobs: [],
          provider: 'email',
          role: 'user',
          profileCompleted: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        // Save user profile to Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());

        Get.snackbar('Welcome!', 'Your Timeless Job Search account has been created successfully!');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur est survenue: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Connexion with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        Get.snackbar('Welcome!', 'Successfully signed in to Timeless Job Search!');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur est survenue: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Trigger the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false; // User cancelled

      // Obtain authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user already exists in Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create a new user profile with the unified structure
          final displayName = userCredential.user!.displayName ?? 'User';
          final nameParts = displayName.split(' ');
          
          UserModel userModel = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email!,
            firstName: nameParts.isNotEmpty ? nameParts.first : '',
            lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
            fullName: displayName,
            phoneNumber: null,
            photoURL: userCredential.user!.photoURL,
            title: '',
            bio: '',
            experience: 'junior',
            city: '',
            jobPreferences: {
              'categories': [],
              'workType': ['remote', 'hybrid', 'onsite'],
              'contractType': ['fulltime'],
              'salaryRange': {'min': null, 'max': null, 'currency': 'EUR'}
            },
            savedJobs: [],
            appliedJobs: [],
            provider: 'google',
            role: 'user',
            profileCompleted: false,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toFirestore());
        } else {
          // Update the user's last login timestamp and isActive status
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({
            'lastLogin': FieldValue.serverTimestamp(),
            'isActive': true,
          });
        }

        Get.snackbar('Welcome!', 'Successfully signed in to Timeless Job Search!');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la connexion Google: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Recovery email sent!');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur est survenue: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      Get.snackbar('Success', 'Successfully signed out');
    } catch (e) {
      Get.snackbar('Error', 'Sign out error: $e');
    }
  }

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (_auth.currentUser != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

  // Handle Firebase authentication errors
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'Le mot de passe est trop faible.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email.';
        break;
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Mot de passe incorrect.';
        break;
      case 'invalid-email':
        message = 'Email invalide.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      default:
        message = 'Erreur d\'authentification: ${e.message}';
    }
    Get.snackbar('Erreur', message);
  }

  // Useful getters
  bool get isLoggedIn => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;
}