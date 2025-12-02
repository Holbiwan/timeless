import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/models/application_model.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/services/job_service.dart';
import 'package:timeless/services/preferences_service.dart';

class EmployerApplicationsController extends GetxController {
  final applications = <ApplicationModel>[].obs;
  final filteredApplications = <ApplicationModel>[].obs;
  final employerJobs = <JobOfferModel>[].obs;
  final isLoading = false.obs;
  final selectedJob = Rx<JobOfferModel?>(null);
  final selectedStatuses = <ApplicationStatus>[].obs;
  final sortBy = 'date_desc'.obs;

  String get employerId => PreferencesService.getString('userId');

  @override
  void onInit() {
    super.onInit();
    loadEmployerData();
  }

  Future<void> loadEmployerData() async {
    try {
      isLoading.value = true;
      
      if (employerId.isEmpty) {
        throw Exception('Employeur non connecté');
      }

      await loadEmployerJobs();
      await loadAllApplications();
      
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEmployerJobs() async {
    List<JobOfferModel> jobs = await JobService.getEmployerJobs(employerId);
    employerJobs.value = jobs;
  }

  Future<void> loadAllApplications() async {
    List<ApplicationModel> allApps = [];
    
    for (JobOfferModel job in employerJobs) {
      List<ApplicationModel> jobApps = await JobService.getJobApplications(job.id);
      allApps.addAll(jobApps);
    }
    
    applications.value = allApps;
    _applyFilters();
  }

  void selectJob(JobOfferModel? job) {
    selectedJob.value = job;
    _applyFilters();
  }

  void addStatusFilter(ApplicationStatus status) {
    if (!selectedStatuses.contains(status)) {
      selectedStatuses.add(status);
      _applyFilters();
    }
  }

  void removeStatusFilter(ApplicationStatus status) {
    selectedStatuses.remove(status);
    _applyFilters();
  }

  void clearFilters() {
    selectedStatuses.clear();
    selectedJob.value = null;
    _applyFilters();
  }

  void changeSortOrder(String newSortBy) {
    sortBy.value = newSortBy;
    _applyFilters();
  }

  void _applyFilters() {
    List<ApplicationModel> filtered = List.from(applications);
    
    // Filter by job
    if (selectedJob.value != null) {
      filtered = filtered.where((app) => app.jobId == selectedJob.value!.id).toList();
    }
    
    // Filter by status
    if (selectedStatuses.isNotEmpty) {
      filtered = filtered.where((app) => selectedStatuses.contains(app.status)).toList();
    }
    
    // Sort
    switch (sortBy.value) {
      case 'date_desc':
        filtered.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
        break;
      case 'name':
        filtered.sort((a, b) => a.candidateName.compareTo(b.candidateName));
        break;
      case 'status':
        filtered.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
    }
    
    filteredApplications.value = filtered;
  }

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus newStatus) async {
    try {
      await JobService.updateApplicationStatus(applicationId, newStatus);
      
      // Update local data
      int index = applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        applications[index] = applications[index].copyWith(status: newStatus);
        _applyFilters();
      }
      
      Get.snackbar(
        'Statut mis à jour',
        'Le statut de la candidature a été modifié',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le statut',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Statistics
  int get totalApplications => applications.length;
  int get pendingApplications => applications.where((app) => app.status == ApplicationStatus.pending).length;
  int get viewedApplications => applications.where((app) => app.status == ApplicationStatus.viewed).length;
  int get shortlistedApplications => applications.where((app) => app.status == ApplicationStatus.shortlisted).length;
  int get interviewApplications => applications.where((app) => app.status == ApplicationStatus.interview).length;
  int get hiredApplications => applications.where((app) => app.status == ApplicationStatus.hired).length;
  int get rejectedApplications => applications.where((app) => app.status == ApplicationStatus.rejected).length;

  List<ApplicationModel> get todayApplications {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return applications.where((app) => 
        app.appliedAt.isAfter(startOfDay) && 
        app.appliedAt.isBefore(endOfDay)
    ).toList();
  }

  List<ApplicationModel> get thisWeekApplications {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return applications.where((app) => app.appliedAt.isAfter(startOfWeekDay)).toList();
  }

  JobOfferModel? getJobForApplication(ApplicationModel application) {
    return employerJobs.firstWhereOrNull((job) => job.id == application.jobId);
  }

  Future<void> refreshData() async {
    await loadEmployerData();
  }

  String getStatusLabel(ApplicationStatus status) {
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

  Color getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.viewed:
        return Colors.blue;
      case ApplicationStatus.shortlisted:
        return Colors.purple;
      case ApplicationStatus.interview:
        return Colors.teal;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.hired:
        return Colors.green;
      case ApplicationStatus.withdrawn:
        return Colors.grey;
      case ApplicationStatus.accepted:
        return Colors.green;
    }
  }
}