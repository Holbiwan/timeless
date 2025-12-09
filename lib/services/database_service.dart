import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DatabaseService extends GetxController {
  static DatabaseService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Test Jobs Collection
  Future<void> createSampleJobs() async {
    try {
      List<Map<String, dynamic>> sampleJobs = [
        {
          'id': 'job_001',
          'title': 'Senior Flutter Developer',
          'company': 'TechCorp',
          'description': 'Join our team to develop innovative mobile applications with Flutter.',
          'requirements': ['Flutter', 'Dart', 'Firebase', '3+ years experience'],
          'location': 'Paris, France',
          'salary': '50000-65000',
          'salaryRange': {
            'min': 50000,
            'max': 65000,
            'currency': 'EUR'
          },
          'type': 'CDI',
          'remote': true,
          'createdAt': Timestamp.now(),
          'isActive': true,
          'postedBy': 'recruiter_demo',
          'applicationsCount': 0,
        },
        {
          'id': 'job_002', 
          'title': 'Designer UI/UX',
          'company': 'Creative Studio',
          'description': 'Create exceptional user interfaces for our mobile applications.',
          'requirements': ['Figma', 'Adobe Creative Suite', 'Design System', 'Portfolio'],
          'location': 'Lyon, France',
          'salary': '40000-50000',
          'salaryRange': {
            'min': 40000,
            'max': 50000,
            'currency': 'EUR'
          },
          'type': 'CDI',
          'remote': false,
          'createdAt': Timestamp.now(),
          'isActive': true,
          'postedBy': 'recruiter_demo',
          'applicationsCount': 0,
        },
        {
          'id': 'job_003',
          'title': 'React Native Developer',
          'company': 'StartupTech',
          'description': 'Cross-platform mobile application development with React Native.',
          'requirements': ['React Native', 'JavaScript', 'Redux', 'API REST'],
          'location': 'Remote',
          'salary': '45000-55000',
          'salaryRange': {
            'min': 45000,
            'max': 55000,
            'currency': 'EUR'
          },
          'type': 'CDI',
          'remote': true,
          'createdAt': Timestamp.now(),
          'isActive': true,
          'postedBy': 'recruiter_demo',
          'applicationsCount': 0,
        }
      ];

      // Add jobs to Firestore
      WriteBatch batch = _firestore.batch();
      
      for (Map<String, dynamic> job in sampleJobs) {
        DocumentReference jobRef = _firestore.collection('jobs').doc(job['id']);
        batch.set(jobRef, job);
      }

      await batch.commit();
      print('✅ Demo jobs created successfully');
    } catch (e) {
      print('❌ Error creating jobs: $e');
    }
  }

  // Retrieve job list
  Future<List<Map<String, dynamic>>> getJobs() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error retrieving jobs: $e');
      return [];
    }
  }

  // Get a specific job by ID
  Future<Map<String, dynamic>?> getJob(String jobId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error retrieving job: $e');
      return null;
    }
  }

  // Create an application (adapted to your existing structure)
  Future<bool> createApplication({
    required String jobId,
    required String candidateId,
    required String candidateName,
    required String candidateEmail,
    String? coverLetter,
    String? cvUrl,
  }) async {
    try {
      Map<String, dynamic> application = {
        'jobId': jobId,
        'uid': candidateId,
        'userName': candidateName,
        'email': candidateEmail,
        'motivation': coverLetter ?? '',
        'cvFileName': cvUrl ?? 'resume.pdf',
        'status': 'submitted',
        'appliedAt': Timestamp.now(),
        'applicationSource': 'mobile_app',
        'matchScore': 85, // Default score
      };

      await _firestore.collection('Apply').add(application);
      
      // Increment the job application counter
      await _firestore.collection('jobs').doc(jobId).update({
        'applicationsCount': FieldValue.increment(1),
      });

      Get.snackbar('Success', 'Application sent successfully!');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'envoi de la candidature: $e');
      return false;
    }
  }

  // Retrieve a user's applications
  Future<List<Map<String, dynamic>>> getUserApplications(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Apply')
          .where('uid', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)
          .get();

      List<Map<String, dynamic>> applications = [];
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> appData = doc.data() as Map<String, dynamic>;
        appData['id'] = doc.id;
        
        // Retrieve job details
        Map<String, dynamic>? jobData = await getJob(appData['jobId']);
        if (jobData != null) {
          appData['job'] = jobData;
        }
        
        applications.add(appData);
      }
      
      return applications;
    } catch (e) {
      print('Error retrieving applications: $e');
      return [];
    }
  }

  // Initialize the database with test data
  Future<void> initializeDatabase() async {
    try {
      // Check if jobs already exist
      QuerySnapshot jobsSnapshot = await _firestore.collection('jobs').limit(1).get();
      
      if (jobsSnapshot.docs.isEmpty) {
        print(' Initializing database...');
        await createSampleJobs();
      } else {
        print('✅ Database already initialized with ${jobsSnapshot.docs.length}+ jobs');
      }
    } catch (e) {
      print('❌ Database initialization error: $e');
    }
  }

  // Configure security rules (info for Firebase Console)
  String getFirestoreRules() {
    return '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - vos utilisateurs existants
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null;
    }
    
    // Jobs collection - vos emplois existants
    match /jobs/{jobId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Apply collection - vos candidatures existantes
    match /Apply/{applicationId} {
      allow read, write: if request.auth != null && (
        resource.data.uid == request.auth.uid ||
        request.auth != null
      );
    }
    
    // Autres collections existantes
    match /Auth/{docId} {
      allow read, write: if request.auth != null;
    }
    
    match /BookMark/{docId} {
      allow read, write: if request.auth != null;
    }
    
    match /notifications/{docId} {
      allow read, write: if request.auth != null;
    }
  }
}
    ''';
  }
}