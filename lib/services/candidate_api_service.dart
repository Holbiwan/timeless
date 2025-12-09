// API service for candidate profiles, resumes (CVs), and applications
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

  // Firestore collections
  static CollectionReference get _candidatesCollection =>
      _firestore.collection('candidate_profiles');
  static CollectionReference get _cvsCollection => _firestore.collection('cvs');
  static CollectionReference get _applicationsCollection =>
      _firestore.collection('applications');
  static CollectionReference get _usersCollection =>
      _firestore.collection('users');

  // === HANDLE CANDIDATES PROFILES ===

  // Create a new candidate profile
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

      // Check if profile already exists
      final existingProfile = await _candidatesCollection.doc(user.uid).get();
      if (existingProfile.exists) {
        throw Exception('Candidate profile already exists');
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

      // Transaction to create profile and update user role
      await _firestore.runTransaction((transaction) async {
        // Create candidate profile
        transaction.set(_candidatesCollection.doc(user.uid), profile.toJson());

        // Update user role
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

  // Get current candidate profile
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

  // Update candidate profile
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

  // Stream candidate profile for real-time updates
  static Stream<CandidateProfileModel?> candidateProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _candidatesCollection.doc(user.uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CandidateProfileModel.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  // === HANDLE RESUMES (CVs) ===

  // Upload a resume (CV)
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

      // Get a unique ID for the resume (CV)
      final cvId = DateTime.now().millisecondsSinceEpoch.toString();
      final storagePath = 'cvs/${user.uid}/$cvId/$fileName';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Create the resume (CV) model
      final cvModel = CVModel(
        id: cvId,
        candidateId: user.uid,
        fileName: fileName,
        downloadUrl: downloadUrl,
        fileSize: fileSize,
        contentType: _getContentType(extension),
        uploadedAt: DateTime.now(),
      );

      // Save to Firestore
      await _cvsCollection.doc(cvId).set(cvModel.toJson());

      // Update candidate profile with current resume (CV)
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

  // Get list of candidate resumes (CVs)
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

  // Delete a candidate's resume (CV)
  static Future<void> deleteCV(String cvId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Verify that the resume (CV) belongs to the user
      final cvDoc = await _cvsCollection.doc(cvId).get();
      if (!cvDoc.exists) {
        throw Exception('Resume (CV) not found');
      }

      final cvData = CVModel.fromJson(cvDoc.data() as Map<String, dynamic>);
      if (cvData.candidateId != user.uid) {
        throw Exception('Not authorized to delete this resume (CV)');
      }

      // Delete the file from Storage
      final ref = _storage.refFromURL(cvData.downloadUrl);
      await ref.delete();

      // Delete from Firestore
      await _cvsCollection.doc(cvId).delete();

      // If it was the current resume (CV), remove it from the profile
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

  // === HANDLES APPLICATIONS (CANDIDATURES) ===

  // Apply to a job
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

      // Retrieve candidate profile to get necessary information
      final candidateProfile = await getCurrentCandidateProfile();
      if (candidateProfile == null) {
        throw Exception('Candidate profile not found');
      }

      // Retrieve job information to get employerId
      final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      Map<String, dynamic>? jobData;

      if (jobDoc.exists) {
        jobData = jobDoc.data();
      } else {
        // Check in legacy collections
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

      // Verify that the user has not already applied
      final existingApplication = await _applicationsCollection
          .where('jobId', isEqualTo: jobId)
          .where('candidateId', isEqualTo: user.uid)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        throw Exception('Candidature déjà envoyée pour cette annonce');
      }

      // Récup  CV
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
        // Use the current resume (CV) if none is specified
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

      // Generate a unique ID for the application
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

      // Save the application
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

  // Retrieve candidate applications
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

  // Revoke an application
  static Future<void> withdrawApplication(String applicationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Verify that the application belongs to the user
      final appDoc = await _applicationsCollection.doc(applicationId).get();
      if (!appDoc.exists) {
        throw Exception('Application not found');
      }

      final appData =
          ApplicationModel.fromJson(appDoc.data() as Map<String, dynamic>);
      if (appData.candidateId != user.uid) {
        throw Exception('Non autorisé à retirer cette candidature');
      }

      // Update the status
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

  // === UTILITY METHODS ===

  // Get MIME type from extension
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

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhone(String phone) {
    return RegExp(r'^[+]?[\d\s\-\(\)]{8,15}$').hasMatch(phone);
  }

  // Clean and validate a URL
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

  // Get candidate statistics
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
