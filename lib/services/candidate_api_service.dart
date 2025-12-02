// Service API sécurisé pour la gestion des profils candidats
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/candidate_profile_model.dart';
import '../models/application_model.dart';

class CandidateApiService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  static CollectionReference get _candidatesCollection =>
      _firestore.collection('candidate_profiles');
  static CollectionReference get _cvsCollection => _firestore.collection('cvs');
  static CollectionReference get _applicationsCollection =>
      _firestore.collection('applications');
  static CollectionReference get _usersCollection =>
      _firestore.collection('users');

  // === GESTION DU PROFIL CANDIDAT ===

  // Créer un nouveau profil candidat
  static Future<CandidateProfileModel> createCandidateProfile({
    required String email,
    required String fullName,
    String? phone,
    String? location,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Vérifier que l'utilisateur n'a pas déjà un profil
      final existingProfile = await _candidatesCollection.doc(user.uid).get();
      if (existingProfile.exists) {
        throw Exception('Profil candidat déjà existant');
      }

      final profile = CandidateProfileModel(
        id: user.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        location: location,
        photoURL: photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Transaction pour créer le profil et mettre à jour l'utilisateur
      await _firestore.runTransaction((transaction) async {
        // Créer le profil candidat
        transaction.set(_candidatesCollection.doc(user.uid), profile.toJson());

        // Mettre à jour le rôle utilisateur
        transaction.set(
          _usersCollection.doc(user.uid),
          {
            'id': user.uid,
            'email': email,
            'displayName': fullName,
            'photoURL': photoURL,
            'role': 'candidate',
            'createdAt': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );
      });

      if (kDebugMode) {
        print('CandidateApiService: Profil créé pour ${user.uid}');
      }
      return profile;
    } catch (e) {
      if (kDebugMode) print('CandidateApiService createProfile error: $e');
      rethrow;
    }
  }

  // Récupérer le profil candidat de l'utilisateur connecté
  static Future<CandidateProfileModel?> getCurrentCandidateProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _candidatesCollection.doc(user.uid).get();
      if (!doc.exists) return null;

      return CandidateProfileModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) print('CandidateApiService getCurrentProfile error: $e');
      return null;
    }
  }

  // Mettre à jour le profil candidat
  static Future<CandidateProfileModel> updateCandidateProfile(
    CandidateProfileModel profile,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      if (profile.id != user.uid) {
        throw Exception('Non autorisé à modifier ce profil');
      }

      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());

      await _candidatesCollection.doc(user.uid).update(updatedProfile.toJson());

      if (kDebugMode) print('CandidateApiService: Profil mis à jour');
      return updatedProfile;
    } catch (e) {
      if (kDebugMode) print('CandidateApiService updateProfile error: $e');
      rethrow;
    }
  }

  // Stream du profil candidat pour updates en temps réel
  static Stream<CandidateProfileModel?> candidateProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _candidatesCollection.doc(user.uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CandidateProfileModel.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  // === GESTION DES CVS ===

  // Uploader un CV
  static Future<CVModel> uploadCV({
    required File file,
    required String fileName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Validations
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB max
        throw Exception('Fichier trop volumineux (max 10MB)');
      }

      final allowedTypes = ['pdf', 'doc', 'docx'];
      final extension = fileName.split('.').last.toLowerCase();
      if (!allowedTypes.contains(extension)) {
        throw Exception('Type de fichier non autorisé');
      }

      // Générer un ID unique pour le CV
      final cvId = DateTime.now().millisecondsSinceEpoch.toString();
      final storagePath = 'cvs/${user.uid}/$cvId/$fileName';

      // Upload vers Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Créer le modèle CV
      final cvModel = CVModel(
        id: cvId,
        candidateId: user.uid,
        fileName: fileName,
        downloadUrl: downloadUrl,
        fileSize: fileSize,
        contentType: _getContentType(extension),
        uploadedAt: DateTime.now(),
      );

      // Sauvegarder en Firestore
      await _cvsCollection.doc(cvId).set(cvModel.toJson());

      // Mettre à jour le profil candidat avec le CV actuel
      await _candidatesCollection.doc(user.uid).update({
        'currentCVId': cvId,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      if (kDebugMode) print('CandidateApiService: CV uploadé avec succès');
      return cvModel;
    } catch (e) {
      if (kDebugMode) print('CandidateApiService uploadCV error: $e');
      rethrow;
    }
  }

  // Récupérer la liste des CVs du candidat
  static Future<List<CVModel>> getCandidateCVs() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final query = await _cvsCollection
          .where('candidateId', isEqualTo: user.uid)
          .orderBy('uploadedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => CVModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('CandidateApiService getCVs error: $e');
      return [];
    }
  }

  // Supprimer un CV
  static Future<void> deleteCV(String cvId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Vérifier que le CV appartient à l'utilisateur
      final cvDoc = await _cvsCollection.doc(cvId).get();
      if (!cvDoc.exists) {
        throw Exception('CV introuvable');
      }

      final cvData = CVModel.fromJson(cvDoc.data() as Map<String, dynamic>);
      if (cvData.candidateId != user.uid) {
        throw Exception('Non autorisé à supprimer ce CV');
      }

      // Supprimer le fichier de Storage
      final ref = _storage.refFromURL(cvData.downloadUrl);
      await ref.delete();

      // Supprimer de Firestore
      await _cvsCollection.doc(cvId).delete();

      // Si c'était le CV actuel, le retirer du profil
      final profile = await getCurrentCandidateProfile();
      if (profile?.currentCVId == cvId) {
        await _candidatesCollection.doc(user.uid).update({
          'currentCVId': null,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      if (kDebugMode) print('CandidateApiService: CV supprimé');
    } catch (e) {
      if (kDebugMode) print('CandidateApiService deleteCV error: $e');
      rethrow;
    }
  }

  // === GESTION DES CANDIDATURES ===

  // Postuler à une annonce
  static Future<ApplicationModel> applyToJob({
    required String jobId,
    String? coverLetter,
    String? cvId,
    Map<String, dynamic>? answers,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Récupérer le profil candidat pour obtenir les informations nécessaires
      final candidateProfile = await getCurrentCandidateProfile();
      if (candidateProfile == null) {
        throw Exception('Profil candidat non trouvé');
      }

      // Récupérer les informations du job pour obtenir l'employerId
      final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      Map<String, dynamic>? jobData;

      if (jobDoc.exists) {
        jobData = jobDoc.data();
      } else {
        // Vérifier dans les collections legacy
        final legacyJobDoc =
            await _firestore.collection('allPost').doc(jobId).get();
        if (legacyJobDoc.exists) {
          jobData = legacyJobDoc.data();
        } else {
          throw Exception('Annonce introuvable');
        }
      }

      if (jobData == null) {
        throw Exception('Données de l\'annonce introuvables');
      }

      // Vérifier que l'utilisateur n'a pas déjà postulé
      final existingApplication = await _applicationsCollection
          .where('jobId', isEqualTo: jobId)
          .where('candidateId', isEqualTo: user.uid)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        throw Exception('Candidature déjà envoyée pour cette annonce');
      }

      // Récupérer les informations du CV
      String cvUrl = '';
      String cvFileName = '';

      if (cvId != null) {
        try {
          final cvDoc = await _cvsCollection.doc(cvId).get();
          if (cvDoc.exists) {
            final cvData = cvDoc.data() as Map<String, dynamic>;
            cvUrl = cvData['downloadUrl'] ?? '';
            cvFileName = cvData['fileName'] ?? '';
          }
        } catch (e) {
          if (kDebugMode) print('Erreur récupération CV: $e');
        }
      } else {
        // Utiliser le CV actuel si aucun n'est spécifié
        final currentCVId = candidateProfile.currentCVId;
        if (currentCVId != null) {
          try {
            final cvDoc = await _cvsCollection.doc(currentCVId).get();
            if (cvDoc.exists) {
              final cvData = cvDoc.data() as Map<String, dynamic>;
              cvUrl = cvData['downloadUrl'] ?? '';
              cvFileName = cvData['fileName'] ?? '';
              cvId = currentCVId;
            }
          } catch (e) {
            if (kDebugMode) print('Erreur récupération CV actuel: $e');
          }
        }
      }

      // Générer un ID unique pour la candidature
      final applicationId = DateTime.now().millisecondsSinceEpoch.toString();

      final application = ApplicationModel(
        id: applicationId,
        jobId: jobId,
        candidateId: user.uid,
        employerId: jobData['employerId'] ?? jobData['userId'] ?? '',
        candidateName: candidateProfile.fullName,
        candidateEmail: candidateProfile.email,
        candidatePhone: candidateProfile.phone,
        cvUrl: cvUrl,
        cvFileName: cvFileName,
        coverLetter: coverLetter,
        appliedAt: DateTime.now(),
        candidateProfile: answers,
      );

      // Sauvegarder la candidature
      await _applicationsCollection
          .doc(applicationId)
          .set(application.toJson());

      if (kDebugMode) print('CandidateApiService: Candidature envoyée');
      return application;
    } catch (e) {
      if (kDebugMode) print('CandidateApiService applyToJob error: $e');
      rethrow;
    }
  }

  // Récupérer les candidatures du candidat
  static Future<List<ApplicationModel>> getCandidateApplications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final query = await _applicationsCollection
          .where('candidateId', isEqualTo: user.uid)
          .orderBy('appliedAt', descending: true)
          .get();

      return query.docs
          .map((doc) =>
              ApplicationModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('CandidateApiService getApplications error: $e');
      return [];
    }
  }

  // Retirer une candidature
  static Future<void> withdrawApplication(String applicationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Vérifier que la candidature appartient à l'utilisateur
      final appDoc = await _applicationsCollection.doc(applicationId).get();
      if (!appDoc.exists) {
        throw Exception('Candidature introuvable');
      }

      final appData =
          ApplicationModel.fromJson(appDoc.data() as Map<String, dynamic>);
      if (appData.candidateId != user.uid) {
        throw Exception('Non autorisé à retirer cette candidature');
      }

      // Mettre à jour le statut
      await _applicationsCollection.doc(applicationId).update({
        'status': ApplicationStatus.withdrawn.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      if (kDebugMode) print('CandidateApiService: Candidature retirée');
    } catch (e) {
      if (kDebugMode) {
        print('CandidateApiService withdrawApplication error: $e');
      }
      rethrow;
    }
  }

  // === MÉTHODES UTILITAIRES ===

  // Obtenir le type MIME à partir de l'extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  // Valider l'email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Valider le téléphone
  static bool isValidPhone(String phone) {
    return RegExp(r'^[+]?[\d\s\-\(\)]{8,15}$').hasMatch(phone);
  }

  // Nettoyer et valider une URL
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    try {
      final uri = Uri.parse(url);
      return uri.hasAbsolutePath ? url : null;
    } catch (e) {
      return null;
    }
  }

  // Obtenir les statistiques du candidat
  static Future<Map<String, dynamic>> getCandidateStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final applications = await getCandidateApplications();
      final cvs = await getCandidateCVs();
      final profile = await getCurrentCandidateProfile();

      return {
        'totalApplications': applications.length,
        'pendingApplications': applications
            .where((app) => app.status == ApplicationStatus.pending)
            .length,
        'acceptedApplications': applications
            .where((app) => app.status == ApplicationStatus.accepted)
            .length,
        'rejectedApplications': applications
            .where((app) => app.status == ApplicationStatus.rejected)
            .length,
        'totalCVs': cvs.length,
        'profileCompletionScore': profile?.profileCompletionScore ?? 0,
        'isProfileComplete': profile?.isComplete ?? false,
      };
    } catch (e) {
      if (kDebugMode) print('CandidateApiService getStats error: $e');
      return {};
    }
  }
}
