import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class AuthService extends GetxController {
  static AuthService get instance => Get.find();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // User state
  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Écouter les changements d'authentification
    user.bindStream(_auth.authStateChanges());
  }

  // Inscription avec email et mot de passe
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    try {
      isLoading.value = true;
      
      // Créer le compte Firebase
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Mettre à jour le nom d'affichage
        await credential.user!.updateDisplayName(name);
        
        // Créer le profil utilisateur dans Firestore
        UserModel userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          displayName: name,
          photoURL: credential.user!.photoURL,
          role: 'candidate',
          createdAt: DateTime.now(),
          profile: {
            'firstName': name.split(' ').first,
            'lastName': name.split(' ').length > 1 ? name.split(' ').last : '',
            'bio': '',
            'skills': [],
            'location': '',
          },
        );

        // Sauvegarder dans Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toJson());

        Get.snackbar('Succès', 'Compte créé avec succès !');
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

  // Connexion avec email et mot de passe
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        Get.snackbar('Succès', 'Connexion réussie !');
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

  // Connexion avec Google
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Déclencher le processus de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false; // Utilisateur a annulé

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer les credentials Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Se connecter à Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Vérifier si l'utilisateur existe déjà dans Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Créer un nouveau profil utilisateur
          UserModel userModel = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email!,
            displayName: userCredential.user!.displayName ?? 'Utilisateur',
            photoURL: userCredential.user!.photoURL,
            role: 'candidate',
            createdAt: DateTime.now(),
            profile: {
              'firstName': userCredential.user!.displayName?.split(' ').first ?? '',
              'lastName': (userCredential.user!.displayName?.split(' ').length ?? 0) > 1 
                  ? userCredential.user!.displayName!.split(' ').last : '',
              'bio': '',
              'skills': [],
              'location': '',
            },
          );

          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toJson());
        }

        Get.snackbar('Succès', 'Connexion Google réussie !');
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

  // Récupération de mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Succès', 'Email de récupération envoyé !');
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

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      Get.snackbar('Succès', 'Déconnexion réussie');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la déconnexion: $e');
    }
  }

  // Obtenir les données utilisateur depuis Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (_auth.currentUser != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        
        if (doc.exists) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  // Gestion des erreurs Firebase Auth
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'Le mot de passe est trop faible.';
        break;
      case 'email-already-in-use':
        message = 'Un compte existe déjà avec cet email.';
        break;
      case 'user-not-found':
        message = 'Aucun utilisateur trouvé avec cet email.';
        break;
      case 'wrong-password':
        message = 'Mot de passe incorrect.';
        break;
      case 'invalid-email':
        message = 'Email invalide.';
        break;
      case 'user-disabled':
        message = 'Ce compte a été désactivé.';
        break;
      case 'too-many-requests':
        message = 'Trop de tentatives. Réessayez plus tard.';
        break;
      default:
        message = 'Erreur d\'authentification: ${e.message}';
    }
    Get.snackbar('Erreur', message);
  }

  // Getters utiles
  bool get isLoggedIn => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;
}