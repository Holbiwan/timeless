import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerMigrationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Migration script to validate existing employers and mark their jobs
  static Future<Map<String, int>> migrateExistingEmployers() async {
    int employersProcessed = 0;
    int jobsMarked = 0;
    int employersActivated = 0;

    try {
      print('🚀 Starting employer migration...');

      // Get all employers from the employers collection
      final employersSnapshot = await _firestore.collection('employers').get();

      for (var employerDoc in employersSnapshot.docs) {
        final employerId = employerDoc.id;
        final employerData = employerDoc.data();

        print(
            '👤 Processing employer: ${employerData['companyName'] ?? 'Unknown'} ($employerId)');

        // Validate employer data
        bool isValid = _validateEmployerData(employerData);

        if (isValid) {
          // Mark employer as active and verified
          await _firestore.collection('employers').doc(employerId).update({
            'isActive': true,
            'isVerified': true,
            'migratedAt': FieldValue.serverTimestamp(),
            'validationStatus': 'auto-migrated',
          });

          employersActivated++;
          print('✅ Employer activated: ${employerData['companyName']}');

          // Find and mark all jobs from this employer
          final jobsSnapshot = await _firestore
              .collection('allPost')
              .where('EmployerId', isEqualTo: employerId)
              .get();

          final batch = _firestore.batch();
          for (var jobDoc in jobsSnapshot.docs) {
            batch.update(jobDoc.reference, {
              'isFromVerifiedEmployer': true,
              'employerVerifiedAt': FieldValue.serverTimestamp(),
              'migrationStatus': 'auto-verified',
            });
            jobsMarked++;
          }

          await batch.commit();
          print(
              '📝 Marked ${jobsSnapshot.docs.length} jobs for employer ${employerData['companyName']}');
        } else {
          // Mark employer as requiring manual review
          await _firestore.collection('employers').doc(employerId).update({
            'isActive': false,
            'isVerified': false,
            'requiresReview': true,
            'migrationStatus': 'requires-manual-review',
            'migratedAt': FieldValue.serverTimestamp(),
          });

          print('⚠️ Employer requires review: ${employerData['companyName']}');
        }

        employersProcessed++;
      }

      // Mark jobs without a valid employer as unverified
      await _markOrphanJobs();

      print('🎉 Migration completed!');
      print('📊 Stats:');
      print('  - Employers processed: $employersProcessed');
      print('  - Employers activated: $employersActivated');
      print('  - Jobs marked as verified: $jobsMarked');

      return {
        'employersProcessed': employersProcessed,
        'employersActivated': employersActivated,
        'jobsMarked': jobsMarked,
      };
    } catch (e) {
      print('❌ Migration error: $e');
      throw e;
    }
  }

  // Validate employer data for completeness
  static bool _validateEmployerData(Map<String, dynamic> data) {
    // Required fields for a valid employer
    final requiredFields = [
      'companyName',
      'email',
      'siretCode',
    ];

    for (String field in requiredFields) {
      if (data[field] == null || data[field].toString().trim().isEmpty) {
        print('⚠️ Missing required field: $field');
        return false;
      }
    }

    // Validate SIRET format (basic check)
    String siret = data['siretCode'].toString().trim();
    if (siret.length < 14) {
      print('⚠️ Invalid SIRET code format: $siret');
      return false;
    }

    // Validate email format
    String email = data['email'].toString().trim();
    if (!email.contains('@') || !email.contains('.')) {
      print('⚠️ Invalid email format: $email');
      return false;
    }

    return true;
  }

  // Mark jobs without valid employers as unverified
  static Future<void> _markOrphanJobs() async {
    try {
      print('🔍 Looking for orphan jobs...');

      final allJobsSnapshot = await _firestore.collection('allPost').get();
      final batch = _firestore.batch();
      int orphanJobs = 0;

      for (var jobDoc in allJobsSnapshot.docs) {
        final jobData = jobDoc.data();
        final employerId = jobData['EmployerId'];

        if (employerId == null) {
          // Job without employer ID
          batch.update(jobDoc.reference, {
            'isFromVerifiedEmployer': false,
            'orphanStatus': 'no-employer-id',
            'migrationStatus': 'orphan-job',
          });
          orphanJobs++;
          continue;
        }

        // Check if employer exists and is active
        final employerDoc =
            await _firestore.collection('employers').doc(employerId).get();

        if (!employerDoc.exists) {
          // Employer doesn't exist
          batch.update(jobDoc.reference, {
            'isFromVerifiedEmployer': false,
            'orphanStatus': 'employer-not-found',
            'migrationStatus': 'orphan-job',
          });
          orphanJobs++;
        } else {
          final employerData = employerDoc.data()!;
          if (employerData['isActive'] != true ||
              employerData['isVerified'] != true) {
            // Employer exists but is not active/verified
            batch.update(jobDoc.reference, {
              'isFromVerifiedEmployer': false,
              'orphanStatus': 'employer-not-verified',
              'migrationStatus': 'orphan-job',
            });
            orphanJobs++;
          }
        }
      }

      await batch.commit();
      print('🗑️ Marked $orphanJobs orphan jobs as unverified');
    } catch (e) {
      print('❌ Error marking orphan jobs: $e');
    }
  }

  // Clean up demo data and test employers
  static Future<int> cleanupDemoData() async {
    try {
      print('🧹 Cleaning up demo data...');

      int deletedJobs = 0;
      final demoPatterns = [
        'DemoToday',
        'FinanceExpert',
        'TestCompany',
        'Demo',
      ];

      for (String pattern in demoPatterns) {
        final jobsSnapshot = await _firestore
            .collection('allPost')
            .where('CompanyName', isEqualTo: pattern)
            .get();

        final batch = _firestore.batch();
        for (var doc in jobsSnapshot.docs) {
          batch.delete(doc.reference);
          deletedJobs++;
        }
        await batch.commit();
      }

      print('🗑️ Deleted $deletedJobs demo jobs');
      return deletedJobs;
    } catch (e) {
      print('❌ Error cleaning demo data: $e');
      return 0;
    }
  }

  // Generate report of current employers and jobs status
  static Future<Map<String, dynamic>> generateStatusReport() async {
    try {
      final employersSnapshot = await _firestore.collection('employers').get();
      final jobsSnapshot = await _firestore.collection('allPost').get();

      int activeEmployers = 0;
      int verifiedEmployers = 0;
      int totalEmployers = employersSnapshot.docs.length;

      int verifiedJobs = 0;
      int totalJobs = jobsSnapshot.docs.length;

      for (var doc in employersSnapshot.docs) {
        final data = doc.data();
        if (data['isActive'] == true) activeEmployers++;
        if (data['isVerified'] == true) verifiedEmployers++;
      }

      for (var doc in jobsSnapshot.docs) {
        final data = doc.data();
        if (data['isFromVerifiedEmployer'] == true) verifiedJobs++;
      }

      return {
        'employers': {
          'total': totalEmployers,
          'active': activeEmployers,
          'verified': verifiedEmployers,
          'activePercentage': totalEmployers > 0
              ? (activeEmployers / totalEmployers * 100).round()
              : 0,
        },
        'jobs': {
          'total': totalJobs,
          'verified': verifiedJobs,
          'unverified': totalJobs - verifiedJobs,
          'verifiedPercentage':
              totalJobs > 0 ? (verifiedJobs / totalJobs * 100).round() : 0,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error generating status report: $e');
    }
  }
}
