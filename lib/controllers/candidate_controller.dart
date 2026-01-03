// Candidate controller (GetX)
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/candidate_profile_model.dart';
import '../models/application_model.dart';
import '../services/candidate_api_service.dart';
import '../utils/app_theme.dart';

class CandidateController extends GetxController {

  // Candidate profile
  final Rx<CandidateProfileModel?> _candidateProfile =
      Rx<CandidateProfileModel?>(null);
  CandidateProfileModel? get candidateProfile => _candidateProfile.value;

  // CV list
  final RxList<CVModel> _cvs = <CVModel>[].obs;
  List<CVModel> get cvs => _cvs;

  // Applications list
  final RxList<ApplicationModel> _applications = <ApplicationModel>[].obs;
  List<ApplicationModel> get applications => _applications;

  // Loading flags
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isUploadingCV = false.obs;
  bool get isUploadingCV => _isUploadingCV.value;

  final RxBool _isApplying = false.obs;
  bool get isApplying => _isApplying.value;

  // Candidate stats
  final RxMap<String, dynamic> _stats = <String, dynamic>{}.obs;
  Map<String, dynamic> get stats => _stats;

  // Error message
  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // Load all candidate data
  Future<void> _initializeData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Load profile
      await loadCandidateProfile();

      // Load related data
      if (_candidateProfile.value != null) {
        await Future.wait([
          loadCVs(),
          loadApplications(),
          loadStats(),
        ]);
      }
    } catch (e) {
      _errorMessage.value = 'Failed to load data: $e';
      if (kDebugMode) print('CandidateController init error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // --- Profile ---

  // Upload profile picture
  Future<bool> uploadProfilePicture() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        _isLoading.value = false;
        return false;
      }

      final file = File(image.path);

      // Upload to Storage
      final photoUrl = await CandidateApiService.uploadProfilePhoto(file: file);

      // Update Profile with new URL
      if (_candidateProfile.value != null) {
        final updatedProfile = _candidateProfile.value!.copyWith(photoURL: photoUrl);
        await updateProfile(updatedProfile);
      }

      AppTheme.showStandardSnackBar(
        title: 'Success',
        message: 'Profile picture updated',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Photo upload failed: $e';
      AppTheme.showStandardSnackBar(
        title: 'Error',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController uploadProfilePicture error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Load candidate profile
  Future<void> loadCandidateProfile() async {
    try {
      final profile = await CandidateApiService.getCurrentCandidateProfile();
      _candidateProfile.value = profile;
    } catch (e) {
      _errorMessage.value = 'Failed to load profile: $e';
      if (kDebugMode) print('CandidateController loadProfile error: $e');
    }
  }

  // Create profile
  Future<bool> createProfile({
    required String email,
    required String fullName,
    String? phone,
    String? location,
    String? photoURL,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final profile = await CandidateApiService.createCandidateProfile(
        email: email,
        fullName: fullName,
        phone: phone,
        location: location,
        photoURL: photoURL,
      );

      _candidateProfile.value = profile;

      AppTheme.showStandardSnackBar(
        title: 'Success',
        message: 'Profile created',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Profile creation failed: $e';
      AppTheme.showStandardSnackBar(
        title: 'Error',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController createProfile error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update profile
  Future<bool> updateProfile(CandidateProfileModel updatedProfile) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final profile =
          await CandidateApiService.updateCandidateProfile(updatedProfile);
      _candidateProfile.value = profile;

      // Refresh stats
      await loadStats();

      AppTheme.showStandardSnackBar(
        title: 'Success',
        message: 'Profile updated',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Update failed: $e';
      AppTheme.showStandardSnackBar(
        title: 'Error',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController updateProfile error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Add a skill
  void addSkill(String skill) {
    if (_candidateProfile.value == null || skill.isEmpty) return;

    final currentSkills = List<String>.from(_candidateProfile.value!.skills);
    if (!currentSkills.contains(skill)) {
      currentSkills.add(skill);
      final updatedProfile =
          _candidateProfile.value!.copyWith(skills: currentSkills);
      updateProfile(updatedProfile);
    }
  }

  // Remove a skill
  void removeSkill(String skill) {
    if (_candidateProfile.value == null) return;

    final currentSkills = List<String>.from(_candidateProfile.value!.skills);
    currentSkills.remove(skill);
    final updatedProfile =
        _candidateProfile.value!.copyWith(skills: currentSkills);
    updateProfile(updatedProfile);
  }

  // Add work experience
  void addExperience(WorkExperience experience) {
    if (_candidateProfile.value == null) return;

    final currentExperience =
        List<WorkExperience>.from(_candidateProfile.value!.experience);
    currentExperience.add(experience);
    final updatedProfile =
        _candidateProfile.value!.copyWith(experience: currentExperience);
    updateProfile(updatedProfile);
  }

  // Remove work experience
  void removeExperience(String experienceId) {
    if (_candidateProfile.value == null) return;

    final currentExperience =
        List<WorkExperience>.from(_candidateProfile.value!.experience);
    currentExperience.removeWhere((exp) => exp.id == experienceId);
    final updatedProfile =
        _candidateProfile.value!.copyWith(experience: currentExperience);
    updateProfile(updatedProfile);
  }

  // Add education
  void addEducation(Education education) {
    if (_candidateProfile.value == null) return;

    final currentEducation =
        List<Education>.from(_candidateProfile.value!.education);
    currentEducation.add(education);
    final updatedProfile =
        _candidateProfile.value!.copyWith(education: currentEducation);
    updateProfile(updatedProfile);
  }

  // Remove education
  void removeEducation(String educationId) {
    if (_candidateProfile.value == null) return;

    final currentEducation =
        List<Education>.from(_candidateProfile.value!.education);
    currentEducation.removeWhere((edu) => edu.id == educationId);
    final updatedProfile =
        _candidateProfile.value!.copyWith(education: currentEducation);
    updateProfile(updatedProfile);
  }

  // --- CVs ---

  // Load CV list
  Future<void> loadCVs() async {
    try {
      final cvsList = await CandidateApiService.getCandidateCVs();
      _cvs.value = cvsList;
    } catch (e) {
      _errorMessage.value = 'Failed to load CVs: $e';
      if (kDebugMode) print('CandidateController loadCVs error: $e');
    }
  }

  // Upload a CV
  Future<bool> uploadCV() async {
    try {
      _isUploadingCV.value = true;
      _errorMessage.value = '';

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return false;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // Upload file
      final cvModel = await CandidateApiService.uploadCV(
        file: file,
        fileName: fileName,
      );

      // Update local list
      _cvs.add(cvModel);

      // Refresh profile
      await loadCandidateProfile();

      AppTheme.showStandardSnackBar(
        title: 'Success',
        message: 'CV uploaded',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Upload failed: $e';
      AppTheme.showStandardSnackBar(
        title: 'Error',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController uploadCV error: $e');
      return false;
    } finally {
      _isUploadingCV.value = false;
    }
  }

  // Delete a CV
  Future<bool> deleteCV(String cvId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await CandidateApiService.deleteCV(cvId);

      // Remove from list
      _cvs.removeWhere((cv) => cv.id == cvId);

      // Refresh profile
      await loadCandidateProfile();

      AppTheme.showStandardSnackBar(
        title: 'Success',
        message: 'CV deleted',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Delete failed: $e';
      AppTheme.showStandardSnackBar(
        title: 'Error',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController deleteCV error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Set current CV
  Future<bool> setCurrentCV(String cvId) async {
    if (_candidateProfile.value == null) return false;

    final updatedProfile = _candidateProfile.value!.copyWith(currentCVId: cvId);
    return await updateProfile(updatedProfile);
  }

  // --- Applications ---

  // Load applications
  Future<void> loadApplications() async {
    try {
      final applicationsList =
          await CandidateApiService.getCandidateApplications();
      _applications.value = applicationsList;
    } catch (e) {
      _errorMessage.value = 'Failed to load applications: $e';
      if (kDebugMode) print('CandidateController loadApplications error: $e');
    }
  }

  // Apply to a job
  Future<bool> applyToJob({
    required String jobId,
    String? coverLetter,
    String? cvId,
    Map<String, dynamic>? answers,
  }) async {
    try {
      _isApplying.value = true;
      _errorMessage.value = '';

      final application = await CandidateApiService.applyToJob(
        jobId: jobId,
        coverLetter: coverLetter,
        cvId: cvId,
        answers: answers,
      );

      // Add locally
      _applications.add(application);

      // Refresh stats
      await loadStats();

      AppTheme.showStandardSnackBar(
        title: 'Success',
        message: 'Application sent',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Application failed: $e';
      AppTheme.showStandardSnackBar(
        title: 'Error',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController applyToJob error: $e');
      return false;
    } finally {
      _isApplying.value = false;
    }
  }

  // Withdraw application
  Future<bool> withdrawApplication(String applicationId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await CandidateApiService.withdrawApplication(applicationId);

      // Update local status
      final index = _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        _applications[index] =
            _applications[index].copyWith(status: ApplicationStatus.withdrawn);
        _applications.refresh();
      }

      AppTheme.showStandardSnackBar(
        title: 'Success',
        message: 'Application withdrawn',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Withdraw failed: $e';
      AppTheme.showStandardSnackBar(
        title: 'Error',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) {
        print('CandidateController withdrawApplication error: $e');
      }
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Check if job already applied
  bool hasAppliedToJob(String jobId) {
    return _applications.any((app) =>
        app.jobId == jobId && app.status != ApplicationStatus.withdrawn);
  }

  // --- Stats ---

  // Load stats
  Future<void> loadStats() async {
    try {
      final statistics = await CandidateApiService.getCandidateStats();
      _stats.value = statistics;
    } catch (e) {
      if (kDebugMode) print('CandidateController loadStats error: $e');
    }
  }

  // --- Utils ---

  // Profile completion status
  bool get isProfileComplete => _candidateProfile.value?.isComplete ?? false;

  // Profile completion score
  int get profileCompletionScore =>
      _candidateProfile.value?.profileCompletionScore ?? 0;

  // Count applications by status
  int getApplicationCountByStatus(ApplicationStatus status) {
    return _applications.where((app) => app.status == status).length;
  }

  // Reload all data
  Future<void> refreshAll() async {
    await _initializeData();
  }

  // Clear local data
  void clearData() {
    _candidateProfile.value = null;
    _cvs.clear();
    _applications.clear();
    _stats.clear();
    _errorMessage.value = '';
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}

// Application helpers
extension ApplicationModelExtension on ApplicationModel {

  // Copy with updates
  ApplicationModel copyWith({
    String? id,
    String? jobId,
    String? candidateId,
    String? employerId,
    String? candidateName,
    String? candidateEmail,
    String? candidatePhone,
    String? cvUrl,
    String? cvFileName,
    String? coverLetter,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? reviewNotes,
    Map<String, dynamic>? candidateProfile,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      candidateId: candidateId ?? this.candidateId,
      employerId: employerId ?? this.employerId,
      candidateName: candidateName ?? this.candidateName,
      candidateEmail: candidateEmail ?? this.candidateEmail,
      candidatePhone: candidatePhone ?? this.candidatePhone,
      cvUrl: cvUrl ?? this.cvUrl,
      cvFileName: cvFileName ?? this.cvFileName,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      candidateProfile: candidateProfile ?? this.candidateProfile,
    );
  }
}
