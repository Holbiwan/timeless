import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DatabaseService extends GetxController {
  static DatabaseService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection des emplois de test
  Future<void> createSampleJobs() async {
    try {
      List<Map<String, dynamic>> sampleJobs = [
        {
          'id': 'job_001',
          'title': 'Développeur Flutter Senior',
          'company': 'TechCorp',
          'description': 'Rejoignez notre équipe pour développer des applications mobiles innovantes avec Flutter.',
          'requirements': ['Flutter', 'Dart', 'Firebase', '3+ ans d\'expérience'],
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
          'description': 'Créez des interfaces utilisateur exceptionnelles pour nos applications mobiles.',
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
          'title': 'Développeur React Native',
          'company': 'StartupTech',
          'description': 'Développement d\'applications mobile cross-platform avec React Native.',
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

      // Ajouter les emplois dans Firestore
      WriteBatch batch = _firestore.batch();
      
      for (Map<String, dynamic> job in sampleJobs) {
        DocumentReference jobRef = _firestore.collection('jobs').doc(job['id']);
        batch.set(jobRef, job);
      }

      await batch.commit();
      print('✅ Emplois de démonstration créés avec succès');
    } catch (e) {
      print('❌ Erreur lors de la création des emplois: $e');
    }
  }

  // Récupérer la liste des emplois
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
      print('Erreur lors de la récupération des emplois: $e');
      return [];
    }
  }

  // Récupérer un emploi spécifique
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
      print('Erreur lors de la récupération de l\'emploi: $e');
      return null;
    }
  }

  // Créer une candidature (adaptée à votre structure existante)
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
        'matchScore': 85, // Score par défaut
      };

      await _firestore.collection('Apply').add(application);
      
      // Incrémenter le compteur de candidatures pour l'emploi
      await _firestore.collection('jobs').doc(jobId).update({
        'applicationsCount': FieldValue.increment(1),
      });

      Get.snackbar('Succès', 'Candidature envoyée avec succès !');
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'envoi de la candidature: $e');
      return false;
    }
  }

  // Récupérer les candidatures d'un utilisateur
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
        
        // Récupérer les détails de l'emploi
        Map<String, dynamic>? jobData = await getJob(appData['jobId']);
        if (jobData != null) {
          appData['job'] = jobData;
        }
        
        applications.add(appData);
      }
      
      return applications;
    } catch (e) {
      print('Erreur lors de la récupération des candidatures: $e');
      return [];
    }
  }

  // Initialiser la base de données avec des données de test
  Future<void> initializeDatabase() async {
    try {
      // Vérifier si des emplois existent déjà
      QuerySnapshot jobsSnapshot = await _firestore.collection('jobs').limit(1).get();
      
      if (jobsSnapshot.docs.isEmpty) {
        print('🔧 Initialisation de la base de données...');
        await createSampleJobs();
      } else {
        print('✅ Base de données déjà initialisée avec ${jobsSnapshot.docs.length}+ emplois');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation de la base de données: $e');
    }
  }

  // Configurer les règles de sécurité (info pour Firebase Console)
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