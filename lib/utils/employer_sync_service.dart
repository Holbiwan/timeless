import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EmployerSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Company data to sync
  static final List<Map<String, dynamic>> _companiesToSync = [
    {
      'id': 'vitoranda_company_id',
      'companyName': 'VITORANDA',
      'email': 'vitoranda@outlook.com',
      'address': '25 Rue de Rivoli',
      'postalCode': '75001',
      'city': 'Paris',
      'country': 'France',
      'siretCode': '12345678901235',
      'apeCode': '6202A',
      'isActive': true,
      'isVerified': true,
    },
    {
      'id': 'ets_sainte_therese_id',
      'companyName': 'ETS SAINTE THERESE',
      'email': 'Classe.Sainte-Therese@outlook.com',
      'address': '1 rue du test',
      'postalCode': '75015',
      'city': 'Paris',
      'country': 'France',
      'siretCode': '12345678901234',
      'apeCode': '8542Z',
      'isActive': true,
      'isVerified': true,
    },
    {
      'id': 'holbiwan_corp_id',
      'companyName': 'HOLBIWAN CORP',
      'email': 'holbiwansabrina@gmail.com',
      'address': '14 rue du moulin',
      'postalCode': '92110',
      'city': 'Clichy',
      'country': 'France',
      'siretCode': '12345678901236',
      'apeCode': '6202Z',
      'isActive': true,
      'isVerified': true,
    },
  ];

  // Sample job data for each company
  static final List<Map<String, dynamic>> _jobsToSync = [
    // VITORANDA jobs
    {
      'companyId': 'vitoranda_company_id',
      'CompanyName': 'VITORANDA',
      'Position': 'Développeur Full Stack Senior',
      'description':
          'Rejoignez notre équipe pour développer des solutions innovantes. Expertise en React, Node.js et bases de données requise.',
      'category': 'Dev',
      'location': 'Paris, France',
      'salary': '50000-70000',
      'jobType': 'Full-time',
      'remote': false,
    },
    {
      'companyId': 'vitoranda_company_id',
      'CompanyName': 'VITORANDA',
      'Position': 'Chef de Projet Digital',
      'description':
          'Pilotez des projets digitaux d\'envergure. Management d\'équipe et méthodologies agiles requis.',
      'category': 'Management',
      'location': 'Paris, France',
      'salary': '45000-60000',
      'jobType': 'Full-time',
      'remote': false,
    },

    // ETS SAINTE THERESE jobs
    {
      'companyId': 'ets_sainte_therese_id',
      'CompanyName': 'ETS SAINTE THERESE',
      'Position': 'Professeur de Mathématiques',
      'description':
          'Enseigner les mathématiques aux élèves de collège et lycée. Diplôme universitaire en mathématiques requis.',
      'category': 'Education',
      'location': 'Paris, France',
      'salary': '35000-45000',
      'jobType': 'Full-time',
      'remote': false,
    },
    {
      'companyId': 'ets_sainte_therese_id',
      'CompanyName': 'ETS SAINTE THERESE',
      'Position': 'Assistant d\'Éducation',
      'description':
          'Accompagner les élèves dans leur scolarité et assurer la surveillance. Formation en éducation appréciée.',
      'category': 'Education',
      'location': 'Paris, France',
      'salary': '25000-30000',
      'jobType': 'Part-time',
      'remote': false,
    },

    // HOLBIWAN CORP jobs
    {
      'companyId': 'holbiwan_corp_id',
      'CompanyName': 'HOLBIWAN CORP',
      'Position': 'Ingénieur Logiciel',
      'description':
          'Développement d\'applications mobiles et web. Maîtrise de Flutter, React et architectures cloud.',
      'category': 'Software',
      'location': 'Clichy, France',
      'salary': '55000-75000',
      'jobType': 'Full-time',
      'remote': true,
    },
    {
      'companyId': 'holbiwan_corp_id',
      'CompanyName': 'HOLBIWAN CORP',
      'Position': 'Product Manager',
      'description':
          'Gestion produit et stratégie. Expérience en méthodologies agiles et analyse de données requise.',
      'category': 'Management',
      'location': 'Clichy, France',
      'salary': '50000-65000',
      'jobType': 'Full-time',
      'remote': true,
    },
  ];

  // Synchronize all employer data
  static Future<void> syncAllEmployers() async {
    try {
      Get.snackbar(
        'Synchronisation',
        'Début de la synchronisation des employeurs...',
        duration: const Duration(seconds: 2),
      );

      int companiesSynced = 0;
      int jobsSynced = 0;

      // 1. Sync company data
      for (var company in _companiesToSync) {
        await _syncCompanyData(company);
        companiesSynced++;
      }

      // 2. Sync job data
      for (var job in _jobsToSync) {
        await _syncJobData(job);
        jobsSynced++;
      }

      Get.snackbar(
        'Succès!',
        'Synchronisation terminée: $companiesSynced entreprises, $jobsSynced postes',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      if (kDebugMode) {
        print('✅ Sync completed: $companiesSynced companies, $jobsSynced jobs');
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la synchronisation: $e',
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
      if (kDebugMode) {
        print('❌ Sync error: $e');
      }
    }
  }

  // Sync individual company data
  static Future<void> _syncCompanyData(Map<String, dynamic> companyData) async {
    try {
      final companyId = companyData['id'];

      await _firestore.collection('employers').doc(companyId).set({
        'companyName': companyData['companyName'],
        'email': companyData['email'],
        'address': companyData['address'],
        'postalCode': companyData['postalCode'],
        'city': companyData['city'],
        'country': companyData['country'],
        'siretCode': companyData['siretCode'],
        'apeCode': companyData['apeCode'],
        'isActive': companyData['isActive'],
        'isVerified': companyData['isVerified'],
        'syncedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Synced company: ${companyData['companyName']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing company ${companyData['companyName']}: $e');
      }
    }
  }

  // Sync individual job data
  static Future<void> _syncJobData(Map<String, dynamic> jobData) async {
    try {
      await _firestore.collection('allPost').add({
        'EmployerId': jobData['companyId'],
        'CompanyName': jobData['CompanyName'],
        'Position': jobData['Position'],
        'description': jobData['description'],
        'category': jobData['category'],
        'location': jobData['location'],
        'salary': jobData['salary'],
        'jobType': jobData['jobType'],
        'remote': jobData['remote'],
        'isActive': true,
        'isFromVerifiedEmployer': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
        'applicationsCount': 0,
        'viewsCount': 0,
        'logoUrl': 'https://zupimages.net/up/25/51/vaft.png',
        'employerVerifiedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print(
            '✅ Synced job: ${jobData['Position']} at ${jobData['CompanyName']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing job ${jobData['Position']}: $e');
      }
    }
  }

  // Get company data by ID
  static Future<Map<String, dynamic>?> getCompanyById(String companyId) async {
    try {
      final doc = await _firestore.collection('employers').doc(companyId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting company $companyId: $e');
      }
      return null;
    }
  }

  // Get all verified companies
  static Future<List<Map<String, dynamic>>> getVerifiedCompanies() async {
    try {
      final snapshot = await _firestore
          .collection('employers')
          .where('isVerified', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting verified companies: $e');
      }
      return [];
    }
  }

  // Check if company email exists
  static Future<bool> isCompanyEmailRegistered(String email) async {
    try {
      final snapshot = await _firestore
          .collection('employers')
          .where('email', isEqualTo: email)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking company email: $e');
      }
      return false;
    }
  }

  // Clean demo data (remove test entries)
  static Future<void> cleanDemoData() async {
    try {
      // Remove demo jobs
      final jobsSnapshot = await _firestore
          .collection('allPost')
          .where('CompanyName', whereIn: ['DemoToday', 'FinanceExpert']).get();

      final batch = _firestore.batch();
      for (var doc in jobsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      Get.snackbar(
        'Nettoyage',
        'Données de démonstration supprimées',
        backgroundColor: const Color(0xFF2196F3),
        colorText: Colors.white,
      );

      if (kDebugMode) {
        print('✅ Demo data cleaned');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cleaning demo data: $e');
      }
    }
  }

  // Fix Vitoranda account specifically
  static Future<void> fixVitorandaAccount() async {
    try {
      Get.snackbar(
        'Fixing Account',
        'Updating Vitoranda account...',
        duration: const Duration(seconds: 2),
      );

      // Find Vitoranda by email
      final querySnapshot = await _firestore
          .collection('employers')
          .where('email', isEqualTo: 'vitoranda@outlook.com')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar(
          'Not Found',
          'Vitoranda account not found',
          backgroundColor: const Color(0xFFFF9800),
          colorText: Colors.white,
        );
        return;
      }

      final doc = querySnapshot.docs.first;

      // Update with missing fields
      await doc.reference.update({
        'logoUrl': 'https://zupimages.net/up/25/51/vaft.png',
        'isActive': true,
        'isVerified': true,
        'status': 'active',
        'verifiedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success!',
        'Vitoranda account has been fixed and is now ready to post jobs!',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      if (kDebugMode) {
        print('✅ Vitoranda account fixed successfully');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error fixing Vitoranda account: $e',
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
      if (kDebugMode) {
        print('❌ Error fixing Vitoranda account: $e');
      }
    }
  }

  // Fix existing employer accounts to add missing fields
  static Future<void> fixEmployerAccounts() async {
    try {
      Get.snackbar(
        'Fixing Accounts',
        'Updating employer accounts with missing fields...',
        duration: const Duration(seconds: 2),
      );

      // Get all employers
      final querySnapshot = await _firestore
          .collection('employers')
          .get();

      int updatedCount = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Check if fields are missing and update
        Map<String, dynamic> updates = {};

        if (!data.containsKey('logoUrl') || data['logoUrl'] == null) {
          updates['logoUrl'] = 'https://zupimages.net/up/25/51/vaft.png';
        }

        if (!data.containsKey('isActive')) {
          updates['isActive'] = true;
        }

        if (!data.containsKey('verifiedAt') && data['isVerified'] == true) {
          updates['verifiedAt'] = FieldValue.serverTimestamp();
        }

        // Ensure status and isVerified are set
        if (data['status'] != 'active') {
          updates['status'] = 'active';
        }

        if (data['isVerified'] != true) {
          updates['isVerified'] = true;
        }

        // Update if there are changes
        if (updates.isNotEmpty) {
          await doc.reference.update(updates);
          updatedCount++;

          if (kDebugMode) {
            print('✅ Updated employer ${data['companyName']}: $updates');
          }
        }
      }

      Get.snackbar(
        'Success!',
        'Updated $updatedCount employer account(s)',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      if (kDebugMode) {
        print('✅ Fixed $updatedCount employer accounts');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error fixing employer accounts: $e',
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
      if (kDebugMode) {
        print('❌ Error fixing employer accounts: $e');
      }
    }
  }

  // Update VITORANDA email address migration
  static Future<void> migrateVitorandaEmail() async {
    try {
      Get.snackbar(
        'Migration',
        'Updating VITORANDA email and auth account...',
        duration: const Duration(seconds: 2),
      );

      // Find VITORANDA company by SIRET
      final querySnapshot = await _firestore
          .collection('employers')
          .where('siretCode', isEqualTo: '12345678901235')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final employerData = doc.data();
        final currentEmail = employerData['email'] ?? '';
        
        // Step 1: Create Firebase Auth account with new email
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'vitoranda@outlook.com',
            password: 'Lecture2025',
          );
          
          if (kDebugMode) {
            print('✅ Firebase Auth account created for vitoranda@outlook.com');
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            if (kDebugMode) {
              print('ℹ️ Firebase Auth account already exists for vitoranda@outlook.com');
            }
          } else {
            throw e;
          }
        }
        
        // Step 2: Update the email address and ensure account is active
        await doc.reference.update({
          'email': 'vitoranda@outlook.com',
          'previousEmail': currentEmail,
          'isActive': true,
          'isVerified': true,
          'emailVerified': true,
          'lastUpdated': FieldValue.serverTimestamp(),
          'emailMigratedAt': FieldValue.serverTimestamp(),
        });

        Get.snackbar(
          'Success!',
          'VITORANDA email updated to vitoranda@outlook.com',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        if (kDebugMode) {
          print('✅ VITORANDA email migrated successfully from $currentEmail to vitoranda@outlook.com');
        }
      } else {
        Get.snackbar(
          'Warning',
          'VITORANDA company not found in database',
          backgroundColor: const Color(0xFFFF9800),
          colorText: Colors.white,
        );

        if (kDebugMode) {
          print('⚠️ VITORANDA company not found for migration');
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error during VITORANDA email migration: $e',
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
      if (kDebugMode) {
        print('❌ VITORANDA migration error: $e');
      }
    }
  }
}
