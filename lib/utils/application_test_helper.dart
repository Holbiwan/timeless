import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/color_res.dart';

class ApplicationTestHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crée une candidature de test pour permettre de tester la fonction de suppression
  static Future<void> createTestApplication({
    required String companyName,
    String userName = 'Test Candidate',
    String email = 'test.candidate@example.com',
    String jobTitle = 'Test Position',
  }) async {
    if (!kDebugMode) {
      Get.snackbar(
        'Test Mode Only',
        'Cette fonction n\'est disponible qu\'en mode debug',
        backgroundColor: ColorRes.brightYellow,
        colorText: Colors.black,
      );
      return;
    }

    try {
      await _firestore.collection('Apply').add({
        'userName': userName,
        'email': email,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'NEW',
        'isTestData': true, // Marquer comme données de test
        'createdBy': 'ApplicationTestHelper',
      });

      Get.snackbar(
        '✅ Test Application Created',
        'Candidature de test créée pour $userName',
        backgroundColor: Colors.green[600],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );

      if (kDebugMode) {
        print('🧪 Test application created:');
        print('   - Candidate: $userName');
        print('   - Email: $email');
        print('   - Position: $jobTitle');
        print('   - Company: $companyName');
      }
    } catch (e) {
      Get.snackbar(
        '❌ Test Creation Failed',
        'Erreur lors de la création de la candidature de test: $e',
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );

      if (kDebugMode) {
        print('❌ Error creating test application: $e');
      }
    }
  }

  // Supprime toutes les candidatures de test
  static Future<void> cleanupTestApplications({
    required String companyName,
  }) async {
    if (!kDebugMode) {
      Get.snackbar(
        'Test Mode Only',
        'Cette fonction n\'est disponible qu\'en mode debug',
        backgroundColor: ColorRes.brightYellow,
        colorText: Colors.black,
      );
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('Apply')
          .where('companyName', isEqualTo: companyName)
          .where('isTestData', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar(
          'No Test Data',
          'Aucune candidature de test trouvée',
          backgroundColor: ColorRes.brightYellow,
          colorText: Colors.black,
        );
        return;
      }

      // Supprimer tous les documents de test
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      Get.snackbar(
        '🗑️ Test Data Cleaned',
        '${querySnapshot.docs.length} candidature(s) de test supprimée(s)',
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );

      if (kDebugMode) {
        print('🗑️ Cleaned up ${querySnapshot.docs.length} test applications');
      }
    } catch (e) {
      Get.snackbar(
        '❌ Cleanup Failed',
        'Erreur lors du nettoyage: $e',
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );

      if (kDebugMode) {
        print('❌ Error cleaning up test applications: $e');
      }
    }
  }

  // Crée plusieurs candidatures de test avec des données variées
  static Future<void> createMultipleTestApplications({
    required String companyName,
    int count = 3,
  }) async {
    if (!kDebugMode) return;

    final List<Map<String, String>> testCandidates = [
      {
        'userName': 'Alice Martin',
        'email': 'alice.martin@example.com',
        'jobTitle': 'UI/UX Designer',
      },
      {
        'userName': 'Bob Dupont',
        'email': 'bob.dupont@example.com',
        'jobTitle': 'Full Stack Developer',
      },
      {
        'userName': 'Claire Rousseau',
        'email': 'claire.rousseau@example.com',
        'jobTitle': 'Marketing Manager',
      },
      {
        'userName': 'David Leroy',
        'email': 'david.leroy@example.com',
        'jobTitle': 'Data Analyst',
      },
      {
        'userName': 'Emma Bernard',
        'email': 'emma.bernard@example.com',
        'jobTitle': 'Project Manager',
      },
    ];

    for (int i = 0; i < count && i < testCandidates.length; i++) {
      await createTestApplication(
        companyName: companyName,
        userName: testCandidates[i]['userName']!,
        email: testCandidates[i]['email']!,
        jobTitle: testCandidates[i]['jobTitle']!,
      );

      // Petite pause pour éviter de surcharger Firestore
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
