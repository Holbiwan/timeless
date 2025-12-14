// lib/services/realtime_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RealtimeFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream en temps réel de toutes les offres d'emploi actives
  static Stream<QuerySnapshot> getJobOffersStream() {
    return _firestore
        .collection('allPost')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream en temps réel des offres d'emploi par employeur
  static Stream<QuerySnapshot> getEmployerJobsStream(String employerId) {
    return _firestore
        .collection('allPost')
        .where('employerId', isEqualTo: employerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream en temps réel des candidatures pour un employeur
  static Stream<QuerySnapshot> getEmployerApplicationsStream(String employerId) {
    return _firestore
        .collection('applications')
        .where('employerId', isEqualTo: employerId)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  /// Stream en temps réel des candidatures pour un candidat
  static Stream<QuerySnapshot> getCandidateApplicationsStream(String candidateId) {
    return _firestore
        .collection('applications')
        .where('candidateId', isEqualTo: candidateId)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  /// Stream en temps réel des données employeur
  static Stream<DocumentSnapshot> getEmployerDataStream(String employerId) {
    return _firestore
        .collection('employers')
        .doc(employerId)
        .snapshots();
  }

  /// Stream en temps réel des candidatures pour une offre spécifique
  static Stream<QuerySnapshot> getJobApplicationsStream(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  /// Écouter les changements sur une offre d'emploi spécifique
  static Stream<DocumentSnapshot> getJobOfferStream(String jobId) {
    return _firestore
        .collection('allPost')
        .doc(jobId)
        .snapshots();
  }

  /// Mettre à jour le nombre de vues d'une offre en temps réel
  static Future<void> incrementJobViews(String jobId) async {
    try {
      await _firestore.collection('allPost').doc(jobId).update({
        'viewsCount': FieldValue.increment(1),
      });
      if (kDebugMode) print('👁️ Vue ajoutée pour l\'offre: $jobId');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur incrémentation vues: $e');
    }
  }

  /// Mettre à jour le statut d'une candidature en temps réel
  static Future<void> updateApplicationStatus(String applicationId, String status) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) print('✅ Statut candidature mis à jour: $applicationId → $status');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur mise à jour statut: $e');
    }
  }

  /// Obtenir les statistiques en temps réel pour un employeur
  static Stream<Map<String, dynamic>> getEmployerStatsStream(String employerId) {
    return _firestore
        .collection('employers')
        .doc(employerId)
        .snapshots()
        .asyncMap((employerDoc) async {
      if (!employerDoc.exists) return {};

      // Compter les offres actives
      final jobsQuery = await _firestore
          .collection('allPost')
          .where('employerId', isEqualTo: employerId)
          .where('isActive', isEqualTo: true)
          .get();

      // Compter les candidatures reçues
      final applicationsQuery = await _firestore
          .collection('applications')
          .where('employerId', isEqualTo: employerId)
          .get();

      // Compter les vues totales
      int totalViews = 0;
      for (var job in jobsQuery.docs) {
        totalViews += (job.data()['viewsCount'] ?? 0) as int;
      }

      return {
        'activeJobs': jobsQuery.docs.length,
        'totalApplications': applicationsQuery.docs.length,
        'totalViews': totalViews,
        'companyName': employerDoc.data()?['companyName'] ?? 'Entreprise',
      };
    });
  }

  /// Stream combiné des données essentielles pour le dashboard employeur
  static Stream<Map<String, dynamic>> getEmployerDashboardStream(String employerId) {
    return _firestore
        .collection('employers')
        .doc(employerId)
        .snapshots()
        .asyncMap((employerDoc) async {
      if (!employerDoc.exists) return {'error': 'Employeur non trouvé'};

      try {
        // Récupérer les offres avec leurs candidatures
        final jobsSnapshot = await _firestore
            .collection('allPost')
            .where('employerId', isEqualTo: employerId)
            .orderBy('createdAt', descending: true)
            .get();

        final jobs = jobsSnapshot.docs;
        int totalViews = 0;
        int totalApplications = 0;

        // Calculer les statistiques
        for (var job in jobs) {
          final jobData = job.data();
          totalViews += (jobData['viewsCount'] ?? 0) as int;
          totalApplications += (jobData['applicationsCount'] ?? 0) as int;
        }

        // Récupérer les candidatures récentes
        final recentApplicationsSnapshot = await _firestore
            .collection('applications')
            .where('employerId', isEqualTo: employerId)
            .orderBy('appliedAt', descending: true)
            .limit(5)
            .get();

        return {
          'employerData': employerDoc.data(),
          'stats': {
            'activeJobs': jobs.where((job) => job.data()['isActive'] == true).length,
            'totalJobs': jobs.length,
            'totalViews': totalViews,
            'totalApplications': totalApplications,
          },
          'recentJobs': jobs.take(3).map((job) => {
            'id': job.id,
            ...job.data(),
          }).toList(),
          'recentApplications': recentApplicationsSnapshot.docs.map((app) => {
            'id': app.id,
            ...app.data(),
          }).toList(),
        };
      } catch (e) {
        if (kDebugMode) print('❌ Erreur dashboard employeur: $e');
        return {'error': 'Erreur chargement dashboard'};
      }
    });
  }

  /// Écouter les nouvelles candidatures en temps réel pour notifications
  static Stream<QuerySnapshot> getNewApplicationsStream(String employerId) {
    final DateTime oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    
    return _firestore
        .collection('applications')
        .where('employerId', isEqualTo: employerId)
        .where('appliedAt', isGreaterThan: oneHourAgo)
        .snapshots();
  }

  /// Marquer toutes les candidatures comme lues
  static Future<void> markApplicationsAsRead(String employerId) async {
    try {
      final applicationsSnapshot = await _firestore
          .collection('applications')
          .where('employerId', isEqualTo: employerId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in applicationsSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      if (kDebugMode) print('✅ Candidatures marquées comme lues');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur marquage lecture: $e');
    }
  }
}