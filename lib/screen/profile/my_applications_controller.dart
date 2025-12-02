import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/models/application_model.dart';
import 'package:timeless/services/job_service.dart';
import 'package:timeless/services/preferences_service.dart';

class MyApplicationsController extends GetxController {
  // Observable variables
  final applications = <ApplicationModel>[].obs;
  final filteredApplications = <ApplicationModel>[].obs;
  final isLoading = false.obs;
  final selectedStatuses = <ApplicationStatus>[].obs;
  final activeFilters = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  // Getters for statistics
  List<ApplicationModel> get pendingApplications => 
      applications.where((app) => app.status == ApplicationStatus.pending).toList();
  
  List<ApplicationModel> get viewedApplications => 
      applications.where((app) => app.status == ApplicationStatus.viewed).toList();
  
  List<ApplicationModel> get respondedApplications => 
      applications.where((app) => 
          app.status == ApplicationStatus.shortlisted || 
          app.status == ApplicationStatus.interview ||
          app.status == ApplicationStatus.hired ||
          app.status == ApplicationStatus.rejected
      ).toList();

  bool get hasActiveFilters => selectedStatuses.isNotEmpty;

  // Load applications from Firebase
  Future<void> loadApplications() async {
    try {
      isLoading.value = true;
      
      String candidateId = PreferencesService.getString('userId');
      if (candidateId.isEmpty) {
        throw Exception('Utilisateur non connecté');
      }

      List<ApplicationModel> apps = await JobService.getCandidateApplications(candidateId);
      applications.value = apps;
      _applyFilters();
      
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger vos candidatures: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      applications.clear();
      filteredApplications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh applications
  Future<void> refreshApplications() async {
    await loadApplications();
  }

  // Filter management
  void addStatusFilter(ApplicationStatus status) {
    if (!selectedStatuses.contains(status)) {
      selectedStatuses.add(status);
      activeFilters.add(_getStatusLabel(status));
      _applyFilters();
    }
  }

  void removeStatusFilter(ApplicationStatus status) {
    selectedStatuses.remove(status);
    activeFilters.remove(_getStatusLabel(status));
    _applyFilters();
  }

  void removeFilter(String filterLabel) {
    // Find and remove corresponding status
    ApplicationStatus? statusToRemove;
    for (ApplicationStatus status in ApplicationStatus.values) {
      if (_getStatusLabel(status) == filterLabel) {
        statusToRemove = status;
        break;
      }
    }
    
    if (statusToRemove != null) {
      selectedStatuses.remove(statusToRemove);
    }
    
    activeFilters.remove(filterLabel);
    _applyFilters();
  }

  void clearFilters() {
    selectedStatuses.clear();
    activeFilters.clear();
    _applyFilters();
  }

  // Apply current filters
  void _applyFilters() {
    if (selectedStatuses.isEmpty) {
      filteredApplications.value = List.from(applications);
    } else {
      filteredApplications.value = applications
          .where((app) => selectedStatuses.contains(app.status))
          .toList();
    }
  }

  // Sort applications
  void sortApplications(String sortBy) {
    switch (sortBy) {
      case 'date_desc':
        applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        break;
      case 'date_asc':
        applications.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
        break;
      case 'status':
        applications.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
    }
    _applyFilters();
  }

  // Helper methods
  String _getStatusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'En attente';
      case ApplicationStatus.viewed:
        return 'Vue';
      case ApplicationStatus.shortlisted:
        return 'Présélectionnée';
      case ApplicationStatus.interview:
        return 'Entretien';
      case ApplicationStatus.rejected:
        return 'Refusée';
      case ApplicationStatus.hired:
        return 'Embauchée';
      case ApplicationStatus.withdrawn:
        return 'Retirée';
      case ApplicationStatus.accepted:
        return 'Acceptée';
    }
  }

  // Get applications by status count
  int getApplicationsCountByStatus(ApplicationStatus status) {
    return applications.where((app) => app.status == status).length;
  }

  // Get success rate (hired / total)
  double get successRate {
    if (applications.isEmpty) return 0.0;
    int hiredCount = applications.where((app) => app.status == ApplicationStatus.hired).length;
    return (hiredCount / applications.length) * 100;
  }

  // Get response rate (not pending / total)
  double get responseRate {
    if (applications.isEmpty) return 0.0;
    int respondedCount = applications.where((app) => app.status != ApplicationStatus.pending).length;
    return (respondedCount / applications.length) * 100;
  }

  // Get most recent application
  ApplicationModel? get mostRecentApplication {
    if (applications.isEmpty) return null;
    return applications.reduce((a, b) => a.appliedAt.isAfter(b.appliedAt) ? a : b);
  }

  // Get applications this month
  List<ApplicationModel> get thisMonthApplications {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return applications.where((app) => 
        app.appliedAt.isAfter(startOfMonth) || 
        app.appliedAt.isAtSameMomentAs(startOfMonth)
    ).toList();
  }

  // Export applications data (future implementation)
  Future<void> exportApplications() async {
    try {
      // TODO: Implement export functionality
      Get.snackbar(
        'Export en cours',
        'Fonctionnalité en cours de développement',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur d\'export',
        'Impossible d\'exporter les données',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Withdraw application (future implementation)
  Future<void> withdrawApplication(String applicationId) async {
    try {
      // TODO: Implement withdraw functionality
      Get.snackbar(
        'Candidature retirée',
        'Votre candidature a été retirée',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      
      // Refresh the list
      await refreshApplications();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de retirer la candidature',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}