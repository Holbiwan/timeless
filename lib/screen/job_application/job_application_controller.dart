import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/job_service.dart';
import 'dart:io';

class JobApplicationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable state
  RxBool isLoading = false.obs;
  RxBool hasApplied = false.obs;
  Rx<File?> selectedCV = Rx<File?>(null);
  RxString coverLetter = ''.obs;
  RxString phoneNumber = ''.obs;

  // Current user
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      currentUser.value = user;
    });
  }

  // Check if user has already applied for a specific job
  Future<void> checkApplicationStatus(String jobId) async {
    try {
      final user = currentUser.value;
      if (user != null) {
        final applied = await JobService.hasApplied(user.uid, jobId);
        hasApplied.value = applied;
      }
    } catch (e) {
      print('Error checking application status: $e');
    }
  }

  // Submit job application
  Future<bool> submitApplication({
    required String jobId,
    required Map<String, dynamic> jobData,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser.value;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      if (selectedCV.value == null) {
        throw Exception('CV is required');
      }

      if (phoneNumber.value.trim().isEmpty) {
        throw Exception('Phone number is required');
      }

      // Get employer ID from job data
      final employerId = jobData['EmployerId'] ?? 'unknown';

      await JobService.submitApplication(
        jobId: jobId,
        candidateId: user.uid,
        employerId: employerId,
        candidateName: user.displayName ?? 'Anonymous',
        candidateEmail: user.email ?? '',
        candidatePhone: phoneNumber.value.trim(),
        cvFile: selectedCV.value!,
        coverLetter: coverLetter.value.trim().isEmpty 
            ? null 
            : coverLetter.value.trim(), candidateProfile: {},
      );

      hasApplied.value = true;
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Set selected CV file
  void setSelectedCV(File? file) {
    selectedCV.value = file;
  }

  // Update cover letter
  void updateCoverLetter(String value) {
    coverLetter.value = value;
  }

  // Update phone number
  void updatePhoneNumber(String value) {
    phoneNumber.value = value;
  }

  // Clear application form
  void clearForm() {
    selectedCV.value = null;
    coverLetter.value = '';
    phoneNumber.value = '';
    hasApplied.value = false;
  }

  // Get user applications stream
  Stream<List<Map<String, dynamic>>> getUserApplicationsStream() {
    final user = currentUser.value;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('applications')
        .where('candidateId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> applications = [];
      
      for (var doc in snapshot.docs) {
        final appData = doc.data();
        
        // Get job details for each application
        try {
          final jobDoc = await _firestore
              .collection('allPost')
              .doc(appData['jobId'])
              .get();
              
          if (jobDoc.exists) {
            final jobData = jobDoc.data()!;
            applications.add({
              'id': doc.id,
              'jobId': appData['jobId'],
              'jobTitle': jobData['Position'] ?? 'Unknown Position',
              'company': jobData['CompanyName'] ?? 'Unknown Company',
              'location': jobData['location'] ?? 'Unknown Location',
              'appliedAt': appData['appliedAt'],
              'status': appData['status'] ?? 'pending',
              'coverLetter': appData['coverLetter'],
              'cvUrl': appData['cvUrl'],
            });
          }
        } catch (e) {
          print('Error getting job details for application: $e');
        }
      }
      
      // Sort applications by appliedAt date in memory (most recent first)
      applications.sort((a, b) {
        final aDate = a['appliedAt']?.toDate() ?? DateTime.now();
        final bDate = b['appliedAt']?.toDate() ?? DateTime.now();
        return bDate.compareTo(aDate);
      });
      
      return applications;
    });
  }

  @override
  void onClose() {
    clearForm();
    super.onClose();
  }
}