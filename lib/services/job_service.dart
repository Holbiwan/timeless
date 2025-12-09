import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/models/application_model.dart';
import 'package:timeless/services/email_service.dart';
import 'dart:io';

class JobService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String jobsCollection = 'allPost';  // Changed from 'jobs' to 'allPost'
  static const String applicationsCollection = 'applications';

  // Job offers management








  // == Create a new job offer
  static Future<String> createJobOffer(JobOfferModel job) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(jobsCollection).add(job.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating job offer: $e');
    }
  }

  // Get all active job offers
  static Future<List<JobOfferModel>> getAllJobOffers({
    int limit = 20,
    String? searchTerm,
    String? location,
    JobType? jobType,
    ExperienceLevel? experienceLevel,
  }) async {
    try {
      Query query = _firestore
          .collection(jobsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (limit > 0) {
        query = query.limit(limit);
      }

      QuerySnapshot snapshot = await query.get();
      List<JobOfferModel> jobs =
          snapshot.docs.map((doc) => JobOfferModel.fromFirestore(doc)).toList();

      // Apply client-side filters
      if (searchTerm != null && searchTerm.isNotEmpty) {
        jobs = jobs
            .where((job) =>
                job.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
                job.description
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase()) ||
                job.companyName
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase()))
            .toList();
      }

      if (location != null && location.isNotEmpty) {
        jobs = jobs
            .where((job) =>
                job.location.toLowerCase().contains(location.toLowerCase()))
            .toList();
      }

      if (jobType != null) {
        jobs = jobs.where((job) => job.jobType == jobType).toList();
      }

      if (experienceLevel != null) {
        jobs = jobs
            .where((job) => job.experienceLevel == experienceLevel)
            .toList();
      }

      return jobs;
    } catch (e) {
      throw Exception('Erreur lors du chargement des offres: $e');
    }
  }

  // Get job offers by employer
  static Future<List<JobOfferModel>> getJobsByEmployer(
      String employerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(jobsCollection)
          .where('employerId', isEqualTo: employerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => JobOfferModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement des offres de l\'employeur: $e');
    }
  }

  // Get job offers by employer (alias method for consistency)
  static Future<List<JobOfferModel>> getEmployerJobs(String employerId) async {
    return getJobsByEmployer(employerId);
  }

  // Get single job offer
  static Future<JobOfferModel?> getJobOffer(String jobId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(jobsCollection).doc(jobId).get();
      if (doc.exists) {
        return JobOfferModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'offre: $e');
    }
  }

  // Update job offer
  static Future<void> updateJobOffer(
      String jobId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(jobsCollection).doc(jobId).update(updates);
    } catch (e) {
      throw Exception('Error updating job offer: $e');
    }
  }

  // Delete job offer (soft delete)
  static Future<void> deleteJobOffer(String jobId) async {
    try {
      await _firestore.collection(jobsCollection).doc(jobId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'offre: $e');
    }
  }

  // 













  // == APPLICATIONS MANAGEMENT
  // 













  // Submit an application with CV upload
  static Future<String> submitApplication({
    required String jobId,
    required String candidateId,
    required String employerId,
    required String candidateName,
    required String candidateEmail,
    String? candidatePhone,
    required File cvFile,
    String? coverLetter,
    Map<String, dynamic>? candidateProfile,
  }) async {
    try {
      // Upload CV to Firebase Storage
      String cvUrl = await _uploadCV(cvFile, candidateId, jobId);
      String cvFileName = cvFile.path.split('/').last;

      // Create application
      ApplicationModel application = ApplicationModel(
        id: '',
        jobId: jobId,
        candidateId: candidateId,
        employerId: employerId,
        candidateName: candidateName,
        candidateEmail: candidateEmail,
        candidatePhone: candidatePhone,
        cvUrl: cvUrl,
        cvFileName: cvFileName,
        coverLetter: coverLetter,
        appliedAt: DateTime.now(),
        candidateProfile: candidateProfile,
      );

      // Save to Firestore
      DocumentReference docRef = await _firestore
          .collection(applicationsCollection)
          .add(application.toFirestore());

      // Update job applications count
      await _firestore.collection(jobsCollection).doc(jobId).update({
        'applicationsCount': FieldValue.increment(1),
      });

      // Send confirmation emails
      await _sendApplicationEmails(application, jobId);

      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de la candidature: $e');
    }
  }

  // Upload CV to Firebase Storage
  static Future<String> _uploadCV(
      File cvFile, String candidateId, String jobId) async {
    try {
      String fileName =
          'cv_${candidateId}_${jobId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      Reference ref = _storage.ref().child('cvs/$fileName');
      UploadTask uploadTask = ref.putFile(cvFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur lors de l\'upload du CV: $e');
    }
  }

  // Send confirmation emails
  static Future<void> _sendApplicationEmails(
      ApplicationModel application, String jobId) async {
    try {
      // Get job details
      JobOfferModel? job = await getJobOffer(jobId);
      if (job == null) return;

      // Send confirmation email to candidate
      await EmailService.sendApplicationConfirmation(
        email: application.candidateEmail,
        userName: application.candidateName,
        jobTitle: job.title,
        companyName: job.companyName,
        salary: _formatSalary(job.salaryMin, job.salaryMax),
        location: job.location,
        jobType: job.jobType.name,
      );

      // Send notification email to employer (if they have an email)
      // TODO: Get employer email from employers collection
    } catch (e) {
      print('Erreur envoi emails: $e');
      // Don't throw here to avoid blocking the application
    }
  }

  // Get applications for a candidate
  static Future<List<ApplicationModel>> getCandidateApplications(
      String candidateId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(applicationsCollection)
          .where('candidateId', isEqualTo: candidateId)
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des candidatures: $e');
    }
  }

  // Get applications for an employer
  static Future<List<ApplicationModel>> getEmployerApplications(
      String employerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(applicationsCollection)
          .where('employerId', isEqualTo: employerId)
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des candidatures: $e');
    }
  }

  // Get applications for a specific job
  static Future<List<ApplicationModel>> getJobApplications(String jobId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(applicationsCollection)
          .where('jobId', isEqualTo: jobId)
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement des candidatures pour cette offre: $e');
    }
  }

  // Update application status
  static Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status, {
    String? reviewNotes,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'status': status.toString().split('.').last,
        'reviewedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (reviewNotes != null) {
        updates['reviewNotes'] = reviewNotes;
      }

      await _firestore
          .collection(applicationsCollection)
          .doc(applicationId)
          .update(updates);
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }

  // Check if candidate has already applied to job
  static Future<bool> hasApplied(String candidateId, String jobId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(applicationsCollection)
          .where('candidateId', isEqualTo: candidateId)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erreur lors de la vérification de candidature: $e');
    }
  }

  // Helper method to format salary range
  static String _formatSalary(double? salaryMin, double? salaryMax) {
    if (salaryMin == null && salaryMax == null) {
      return 'Salaire à négocier';
    }

    if (salaryMin != null && salaryMax != null) {
      return '${salaryMin.toInt()}€ - ${salaryMax.toInt()}€';
    }

    if (salaryMin != null) {
      return 'À partir de ${salaryMin.toInt()}€';
    }

    if (salaryMax != null) {
      return 'Jusqu\'à ${salaryMax.toInt()}€';
    }

    return 'Non spécifié';
  }
}
