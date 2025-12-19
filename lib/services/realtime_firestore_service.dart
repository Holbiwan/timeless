// lib/services/realtime_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RealtimeFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time stream of all active job offers
  static Stream<QuerySnapshot> getJobOffersStream() {
    return _firestore
        .collection('allPost')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Real-time stream of job offers by employer
  static Stream<QuerySnapshot> getEmployerJobsStream(String employerId) {
    return _firestore
        .collection('allPost')
        .where('employerId', isEqualTo: employerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Real-time stream of applications for employer
  static Stream<QuerySnapshot> getEmployerApplicationsStream(
      String employerId) {
    return _firestore
        .collection('applications')
        .where('employerId', isEqualTo: employerId)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  // Real-time stream of applications for candidate
  static Stream<QuerySnapshot> getCandidateApplicationsStream(
      String candidateId) {
    return _firestore
        .collection('applications')
        .where('candidateId', isEqualTo: candidateId)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  // Real-time stream of employer data
  static Stream<DocumentSnapshot> getEmployerDataStream(String employerId) {
    return _firestore.collection('employers').doc(employerId).snapshots();
  }

  // Real-time stream of applications for specific offer
  static Stream<QuerySnapshot> getJobApplicationsStream(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  // Listen to changes on specific job offer
  static Stream<DocumentSnapshot> getJobOfferStream(String jobId) {
    return _firestore.collection('allPost').doc(jobId).snapshots();
  }

  // Update job offer view count in real-time
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

  // Update application status in real-time
  static Future<void> updateApplicationStatus(
      String applicationId, String status) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode)
        print('✅ Statut candidature mis à jour: $applicationId → $status');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur mise à jour statut: $e');
    }
  }

  // Get real-time statistics for employer
  static Stream<Map<String, dynamic>> getEmployerStatsStream(
      String employerId) {
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

      // Count received applications
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

  // Combined stream of essential data for employer dashboard
  static Stream<Map<String, dynamic>> getEmployerDashboardStream(
      String employerId) {
    return _firestore
        .collection('employers')
        .doc(employerId)
        .snapshots()
        .asyncMap((employerDoc) async {
      if (!employerDoc.exists) return {'error': 'Employeur non trouvé'};

      try {
        // Get offers with their applications
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

        // Get recent applications
        final recentApplicationsSnapshot = await _firestore
            .collection('applications')
            .where('employerId', isEqualTo: employerId)
            .orderBy('appliedAt', descending: true)
            .limit(5)
            .get();

        return {
          'employerData': employerDoc.data(),
          'stats': {
            'activeJobs':
                jobs.where((job) => job.data()['isActive'] == true).length,
            'totalJobs': jobs.length,
            'totalViews': totalViews,
            'totalApplications': totalApplications,
          },
          'recentJobs': jobs
              .take(3)
              .map((job) => {
                    'id': job.id,
                    ...job.data(),
                  })
              .toList(),
          'recentApplications': recentApplicationsSnapshot.docs
              .map((app) => {
                    'id': app.id,
                    ...app.data(),
                  })
              .toList(),
        };
      } catch (e) {
        if (kDebugMode) print('❌ Erreur dashboard employeur: $e');
        return {'error': 'Erreur chargement dashboard'};
      }
    });
  }

  // Listen to new applications in real-time for notifications
  static Stream<QuerySnapshot> getNewApplicationsStream(String employerId) {
    final DateTime oneHourAgo =
        DateTime.now().subtract(const Duration(hours: 1));

    return _firestore
        .collection('applications')
        .where('employerId', isEqualTo: employerId)
        .where('appliedAt', isGreaterThan: oneHourAgo)
        .snapshots();
  }

  // Marquer toutes les candidatures comme lues
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
