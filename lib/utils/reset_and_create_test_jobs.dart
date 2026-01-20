import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Reset allPost collection and create clean test jobs
class ResetAndCreateTestJobs {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> execute() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) print('❌ No user logged in');
        return;
      }

      if (kDebugMode) {
        print('═══════════════════════════════════════════');
        print('🗑️  CLEANING AND CREATING TEST JOBS');
        print('═══════════════════════════════════════════');
      }

      // Get employer data
      final employerDoc =
          await _firestore.collection('employers').doc(user.uid).get();

      if (!employerDoc.exists) {
        if (kDebugMode) print('❌ Employer not found');
        return;
      }

      final employerData = employerDoc.data()!;
      final companyName = employerData['companyName'] ?? 'Test Company';
      final employerEmail = employerData['email'] ?? 'test@example.com';
      final siretCode = employerData['siretCode'] ?? '12345678901234';
      final apeCode = employerData['apeCode'] ?? '6201Z';
      final companyInfo = employerData['companyInfo'] ?? 'Tech company';
      final logoUrl =
          employerData['logoUrl'] ?? 'https://i.imgur.com/bdlYq1p.png';

      // Step 1: Delete all jobs from this employer
      if (kDebugMode) print('\n🗑️  Step 1: Deleting old jobs...');
      final oldJobs = await _firestore
          .collection('allPost')
          .where('EmployerId', isEqualTo: user.uid)
          .get();

      final deleteBatch = _firestore.batch();
      for (var doc in oldJobs.docs) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit();
      if (kDebugMode) print('   ✅ Deleted ${oldJobs.docs.length} old jobs');

      // Step 2: Create test jobs with perfect data
      if (kDebugMode) print('\n📝 Step 2: Creating new test jobs...');

      final testJobs = [
        {
          'Position': 'Software Engineer',
          'category': 'Backend',
          'location': 'Paris',
          'salaryMin': '45000',
          'salaryMax': '60000',
          'salary': '45000-60000',
          'jobType': 'full-time',
          'remote': true,
          'workMode': 'Remote',
          'description':
              'We are looking for a talented Software Engineer to join our team. You will work on exciting backend projects using modern technologies.',
        },
        {
          'Position': 'Frontend Developer',
          'category': 'Frontend',
          'location': 'Lyon',
          'salaryMin': '40000',
          'salaryMax': '55000',
          'salary': '40000-55000',
          'jobType': 'full-time',
          'remote': false,
          'workMode': 'On-site',
          'description':
              'Join our frontend team to build amazing user interfaces. Experience with React or Vue.js is a plus.',
        },
        {
          'Position': 'DevOps Engineer',
          'category': 'DevOps',
          'location': 'Marseille',
          'salaryMin': '50000',
          'salaryMax': '70000',
          'salary': '50000-70000',
          'jobType': 'contract',
          'remote': true,
          'workMode': 'Remote',
          'description':
              'We need a DevOps expert to help us improve our CI/CD pipelines and infrastructure automation.',
        },
        {
          'Position': 'Data Scientist Intern',
          'category': 'Data',
          'location': 'Paris',
          'salaryMin': '1200',
          'salaryMax': '1500',
          'salary': '1200-1500',
          'jobType': 'internship',
          'remote': false,
          'workMode': 'On-site',
          'description':
              'Internship opportunity for a data science student. You will work on machine learning projects and data analysis.',
        },
        {
          'Position': 'Mobile Developer',
          'category': 'Mobile',
          'location': 'Toulouse',
          'salaryMin': '42000',
          'salaryMax': '58000',
          'salary': '42000-58000',
          'jobType': 'full-time',
          'remote': true,
          'workMode': 'Remote',
          'description':
              'We are seeking a mobile developer with Flutter or React Native experience to build cross-platform applications.',
        },
        {
          'Position': 'UI/UX Designer',
          'category': 'Design',
          'location': 'Paris',
          'salaryMin': '38000',
          'salaryMax': '52000',
          'salary': '38000-52000',
          'jobType': 'part-time',
          'remote': true,
          'workMode': 'Remote',
          'description':
              'Part-time position for a creative UI/UX designer. You will design user interfaces and create wireframes.',
        },
      ];

      final createBatch = _firestore.batch();
      int count = 0;

      for (var jobData in testJobs) {
        final completeJobData = {
          ...jobData,
          // Employer data
          'CompanyName': companyName,
          'EmployerId': user.uid,
          'employerEmail': employerEmail,
          'siretCode': siretCode,
          'apeCode': apeCode,
          'companyInfo': companyInfo,
          'logoUrl': logoUrl,
          // Metadata
          'isActive': true,
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
          'timestamp': FieldValue.serverTimestamp(),
          'applicationsCount': 0,
          'viewsCount': 0,
          'BookMarkUserList': [],
          // Verification
          'isFromVerifiedEmployer': true,
          'employerVerifiedAt': FieldValue.serverTimestamp(),
        };

        final docRef = _firestore.collection('allPost').doc();
        createBatch.set(docRef, completeJobData);
        count++;

        if (kDebugMode) {
          print(
              '   ✅ ${jobData['Position']} - ${jobData['location']} (${jobData['jobType']})');
        }
      }

      await createBatch.commit();

      if (kDebugMode) {
        print('\n═══════════════════════════════════════════');
        print('✅ DONE! Created $count test jobs');
        print('═══════════════════════════════════════════');
        print('\n📊 Test Jobs Summary:');
        print('   • 3 jobs in Paris (full-time, internship, part-time)');
        print('   • 1 job in Lyon (full-time)');
        print('   • 1 job in Marseille (contract)');
        print('   • 1 job in Toulouse (full-time)');
        print('\n🧪 Test Filters:');
        print('   ✅ Location: Paris (3 results)');
        print('   ✅ Location: Lyon (1 result)');
        print('   ✅ Type: full-time (3 results)');
        print('   ✅ Type: internship (1 result)');
        print('   ✅ Category: Backend, Frontend, etc.');
        print('   ✅ Search: "$companyName", "Software", "Developer"');
        print('\n');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error: $e');
    }
  }
}
