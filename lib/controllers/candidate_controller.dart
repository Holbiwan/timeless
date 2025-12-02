// Contrôleur pour la gestion des candidats avec GetX
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../models/candidate_profile_model.dart';
import '../models/application_model.dart';
import '../services/candidate_api_service.dart';
import '../utils/app_theme.dart';

class CandidateController extends GetxController {
  // État du profil candidat
  final Rx<CandidateProfileModel?> _candidateProfile =
      Rx<CandidateProfileModel?>(null);
  CandidateProfileModel? get candidateProfile => _candidateProfile.value;

  // Liste des CVs
  final RxList<CVModel> _cvs = <CVModel>[].obs;
  List<CVModel> get cvs => _cvs;

  // Liste des candidatures
  final RxList<ApplicationModel> _applications = <ApplicationModel>[].obs;
  List<ApplicationModel> get applications => _applications;

  // États de chargement
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isUploadingCV = false.obs;
  bool get isUploadingCV => _isUploadingCV.value;

  final RxBool _isApplying = false.obs;
  bool get isApplying => _isApplying.value;

  // Statistiques
  final RxMap<String, dynamic> _stats = <String, dynamic>{}.obs;
  Map<String, dynamic> get stats => _stats;

  // Messages d'erreur
  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // Initialiser les données du candidat
  Future<void> _initializeData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Charger le profil candidat
      await loadCandidateProfile();

      // Charger les données associées si le profil existe
      if (_candidateProfile.value != null) {
        await Future.wait([
          loadCVs(),
          loadApplications(),
          loadStats(),
        ]);
      }
    } catch (e) {
      _errorMessage.value = 'Erreur lors du chargement des données: $e';
      if (kDebugMode) print('CandidateController init error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // === GESTION DU PROFIL ===

  // Charger le profil candidat
  Future<void> loadCandidateProfile() async {
    try {
      final profile = await CandidateApiService.getCurrentCandidateProfile();
      _candidateProfile.value = profile;
    } catch (e) {
      _errorMessage.value = 'Erreur lors du chargement du profil: $e';
      if (kDebugMode) print('CandidateController loadProfile error: $e');
    }
  }

  // Créer un profil candidat
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
        title: 'Succès',
        message: 'Profil candidat créé avec succès',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Erreur lors de la création du profil: $e';
      AppTheme.showStandardSnackBar(
        title: 'Erreur',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController createProfile error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Mettre à jour le profil candidat
  Future<bool> updateProfile(CandidateProfileModel updatedProfile) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final profile =
          await CandidateApiService.updateCandidateProfile(updatedProfile);
      _candidateProfile.value = profile;

      // Recharger les statistiques
      await loadStats();

      AppTheme.showStandardSnackBar(
        title: 'Succès',
        message: 'Profil mis à jour avec succès',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Erreur lors de la mise à jour: $e';
      AppTheme.showStandardSnackBar(
        title: 'Erreur',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController updateProfile error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Ajouter une compétence
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

  // Supprimer une compétence
  void removeSkill(String skill) {
    if (_candidateProfile.value == null) return;

    final currentSkills = List<String>.from(_candidateProfile.value!.skills);
    currentSkills.remove(skill);
    final updatedProfile =
        _candidateProfile.value!.copyWith(skills: currentSkills);
    updateProfile(updatedProfile);
  }

  // Ajouter une expérience
  void addExperience(WorkExperience experience) {
    if (_candidateProfile.value == null) return;

    final currentExperience =
        List<WorkExperience>.from(_candidateProfile.value!.experience);
    currentExperience.add(experience);
    final updatedProfile =
        _candidateProfile.value!.copyWith(experience: currentExperience);
    updateProfile(updatedProfile);
  }

  // Supprimer une expérience
  void removeExperience(String experienceId) {
    if (_candidateProfile.value == null) return;

    final currentExperience =
        List<WorkExperience>.from(_candidateProfile.value!.experience);
    currentExperience.removeWhere((exp) => exp.id == experienceId);
    final updatedProfile =
        _candidateProfile.value!.copyWith(experience: currentExperience);
    updateProfile(updatedProfile);
  }

  // Ajouter une formation
  void addEducation(Education education) {
    if (_candidateProfile.value == null) return;

    final currentEducation =
        List<Education>.from(_candidateProfile.value!.education);
    currentEducation.add(education);
    final updatedProfile =
        _candidateProfile.value!.copyWith(education: currentEducation);
    updateProfile(updatedProfile);
  }

  // Supprimer une formation
  void removeEducation(String educationId) {
    if (_candidateProfile.value == null) return;

    final currentEducation =
        List<Education>.from(_candidateProfile.value!.education);
    currentEducation.removeWhere((edu) => edu.id == educationId);
    final updatedProfile =
        _candidateProfile.value!.copyWith(education: currentEducation);
    updateProfile(updatedProfile);
  }

  // === GESTION DES CVS ===

  // Charger la liste des CVs
  Future<void> loadCVs() async {
    try {
      final cvsList = await CandidateApiService.getCandidateCVs();
      _cvs.value = cvsList;
    } catch (e) {
      _errorMessage.value = 'Erreur lors du chargement des CVs: $e';
      if (kDebugMode) print('CandidateController loadCVs error: $e');
    }
  }

  // Upload d'un CV
  Future<bool> uploadCV() async {
    try {
      _isUploadingCV.value = true;
      _errorMessage.value = '';

      // Sélectionner un fichier
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // Upload via le service
      final cvModel = await CandidateApiService.uploadCV(
        file: file,
        fileName: fileName,
      );

      // Mettre à jour la liste des CVs
      _cvs.add(cvModel);

      // Recharger le profil pour avoir le CV actuel mis à jour
      await loadCandidateProfile();

      AppTheme.showStandardSnackBar(
        title: 'Succès',
        message: 'CV uploadé avec succès',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Erreur lors de l\'upload: $e';
      AppTheme.showStandardSnackBar(
        title: 'Erreur',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController uploadCV error: $e');
      return false;
    } finally {
      _isUploadingCV.value = false;
    }
  }

  // Supprimer un CV
  Future<bool> deleteCV(String cvId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await CandidateApiService.deleteCV(cvId);

      // Retirer de la liste locale
      _cvs.removeWhere((cv) => cv.id == cvId);

      // Recharger le profil si c'était le CV actuel
      await loadCandidateProfile();

      AppTheme.showStandardSnackBar(
        title: 'Succès',
        message: 'CV supprimé avec succès',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Erreur lors de la suppression: $e';
      AppTheme.showStandardSnackBar(
        title: 'Erreur',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController deleteCV error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Définir un CV comme actuel
  Future<bool> setCurrentCV(String cvId) async {
    if (_candidateProfile.value == null) return false;

    final updatedProfile = _candidateProfile.value!.copyWith(currentCVId: cvId);
    return await updateProfile(updatedProfile);
  }

  // === GESTION DES CANDIDATURES ===

  // Charger la liste des candidatures
  Future<void> loadApplications() async {
    try {
      final applicationsList =
          await CandidateApiService.getCandidateApplications();
      _applications.value = applicationsList;
    } catch (e) {
      _errorMessage.value = 'Erreur lors du chargement des candidatures: $e';
      if (kDebugMode) print('CandidateController loadApplications error: $e');
    }
  }

  // Postuler à une annonce
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

      // Ajouter à la liste locale
      _applications.add(application);

      // Recharger les statistiques
      await loadStats();

      AppTheme.showStandardSnackBar(
        title: 'Succès',
        message: 'Candidature envoyée avec succès',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Erreur lors de la candidature: $e';
      AppTheme.showStandardSnackBar(
        title: 'Erreur',
        message: _errorMessage.value,
        isError: true,
      );
      if (kDebugMode) print('CandidateController applyToJob error: $e');
      return false;
    } finally {
      _isApplying.value = false;
    }
  }

  // Retirer une candidature
  Future<bool> withdrawApplication(String applicationId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await CandidateApiService.withdrawApplication(applicationId);

      // Mettre à jour le statut dans la liste locale
      final index = _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        _applications[index] =
            _applications[index].copyWith(status: ApplicationStatus.withdrawn);
        _applications.refresh();
      }

      AppTheme.showStandardSnackBar(
        title: 'Succès',
        message: 'Candidature retirée',
        isSuccess: true,
      );

      return true;
    } catch (e) {
      _errorMessage.value = 'Erreur lors du retrait: $e';
      AppTheme.showStandardSnackBar(
        title: 'Erreur',
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

  // Vérifier si l'utilisateur a déjà postulé à une annonce
  bool hasAppliedToJob(String jobId) {
    return _applications.any((app) =>
        app.jobId == jobId && app.status != ApplicationStatus.withdrawn);
  }

  // === STATISTIQUES ===

  // Charger les statistiques du candidat
  Future<void> loadStats() async {
    try {
      final statistics = await CandidateApiService.getCandidateStats();
      _stats.value = statistics;
    } catch (e) {
      if (kDebugMode) print('CandidateController loadStats error: $e');
    }
  }

  // === MÉTHODES UTILITAIRES ===

  // Vérifier si le profil est complet
  bool get isProfileComplete => _candidateProfile.value?.isComplete ?? false;

  // Obtenir le score de complétion du profil
  int get profileCompletionScore =>
      _candidateProfile.value?.profileCompletionScore ?? 0;

  // Obtenir le nombre de candidatures par statut
  int getApplicationCountByStatus(ApplicationStatus status) {
    return _applications.where((app) => app.status == status).length;
  }

  // Rafraîchir toutes les données
  Future<void> refreshAll() async {
    await _initializeData();
  }

  // Nettoyer les données
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

// Extensions pour faciliter l'utilisation
extension ApplicationModelExtension on ApplicationModel {
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
