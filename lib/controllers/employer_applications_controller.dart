// Employer applications controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/models/application_model.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/services/job_service.dart';
import 'package:timeless/services/email_service.dart';
import 'package:timeless/services/preferences_service.dart';

// Employer applications controller
class EmployerApplicationsController extends GetxController {

  // All applications
  final applications = <ApplicationModel>[].obs;

  // Filtered applications
  final filteredApplications = <ApplicationModel>[].obs;

  // Employer job offers
  final employerJobs = <JobOfferModel>[].obs;

  // Loading state
  final isLoading = false.obs;

  // Selected job filter
  final selectedJob = Rx<JobOfferModel?>(null);

  // Selected status filters
  final selectedStatuses = <ApplicationStatus>[].obs;

  // Sort option
  final sortBy = 'date_desc'.obs;

  // Employer ID from preferences
  String get employerId => PreferencesService.getString('userId');

  @override
  void onInit() {
    super.onInit();
    loadEmployerData();
  }

  // Load jobs and applications
  Future<void> loadEmployerData() async {
    try {
      isLoading.value = true;

      if (employerId.isEmpty) {
        throw Exception('Employer not logged in');
      }

      await loadEmployerJobs();
      await loadAllApplications();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load employer jobs
  Future<void> loadEmployerJobs() async {
    List<JobOfferModel> jobs = await JobService.getEmployerJobs(employerId);
    employerJobs.value = jobs;
  }

  // Load all applications for all jobs
  Future<void> loadAllApplications() async {
    List<ApplicationModel> allApps = [];

    for (JobOfferModel job in employerJobs) {
      List<ApplicationModel> jobApps =
          await JobService.getJobApplications(job.id);
      allApps.addAll(jobApps);
    }

    applications.value = allApps;
    _applyFilters();
  }

  // Select job filter
  void selectJob(JobOfferModel? job) {
    selectedJob.value = job;
    _applyFilters();
  }

  // Add status filter
  void addStatusFilter(ApplicationStatus status) {
    if (!selectedStatuses.contains(status)) {
      selectedStatuses.add(status);
      _applyFilters();
    }
  }

  // Remove status filter
  void removeStatusFilter(ApplicationStatus status) {
    selectedStatuses.remove(status);
    _applyFilters();
  }

  // Reset all filters
  void clearFilters() {
    selectedStatuses.clear();
    selectedJob.value = null;
    _applyFilters();
  }

  // Change sort option
  void changeSortOrder(String newSortBy) {
    sortBy.value = newSortBy;
    _applyFilters();
  }

  // Apply filters and sorting
  void _applyFilters() {
    List<ApplicationModel> filtered = List.from(applications);

    // Filter by job
    if (selectedJob.value != null) {
      filtered = filtered
          .where((app) => app.jobId == selectedJob.value!.id)
          .toList();
    }

    // Filter by status
    if (selectedStatuses.isNotEmpty) {
      filtered = filtered
          .where((app) => selectedStatuses.contains(app.status))
          .toList();
    }

    // Sort results
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

  // Update application status
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus newStatus,
  ) async {
    try {
      await JobService.updateApplicationStatus(applicationId, newStatus);

      // Update local list
      int index =
          applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        applications[index] =
            applications[index].copyWith(status: newStatus);
        _applyFilters();
      }

      Get.snackbar(
        'Status updated',
        'Application status changed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- Stats ---

  // Total applications
  int get totalApplications => applications.length;

  // By status
  int get pendingApplications =>
      applications.where((app) => app.status == ApplicationStatus.pending).length;

  int get viewedApplications =>
      applications.where((app) => app.status == ApplicationStatus.viewed).length;

  int get shortlistedApplications =>
      applications.where((app) => app.status == ApplicationStatus.shortlisted).length;

  int get interviewApplications =>
      applications.where((app) => app.status == ApplicationStatus.interview).length;

  int get hiredApplications =>
      applications.where((app) => app.status == ApplicationStatus.hired).length;

  int get rejectedApplications =>
      applications.where((app) => app.status == ApplicationStatus.rejected).length;

  // Applications from today
  List<ApplicationModel> get todayApplications {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return applications.where((app) =>
      app.appliedAt.isAfter(startOfDay) &&
      app.appliedAt.isBefore(endOfDay)
    ).toList();
  }

  // Applications from this week
  List<ApplicationModel> get thisWeekApplications {
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return applications
        .where((app) => app.appliedAt.isAfter(startOfWeekDay))
        .toList();
  }

  // Get job linked to application
  JobOfferModel? getJobForApplication(ApplicationModel application) {
    return employerJobs
        .firstWhereOrNull((job) => job.id == application.jobId);
  }

  // Reload all data
  Future<void> refreshData() async {
    await loadEmployerData();
  }

  // Status label
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

  // Status color
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

  // Send interview invitation
  Future<void> sendInterviewInvitation({
    required ApplicationModel application,
    required DateTime interviewDate,
    required String location,
    String? additionalMessage,
  }) async {
    try {
      // Get job details for the invitation
      final job = getJobForApplication(application);
      if (job == null) {
        throw Exception('Job not found for this application');
      }

      // Send the invitation email
      final emailSent = await EmailService.sendInterviewInvitation(
        candidateEmail: application.candidateEmail,
        candidateName: application.candidateName,
        companyName: job.companyName,
        jobTitle: job.title,
        interviewDate: interviewDate,
        location: location,
        additionalMessage: additionalMessage,
      );

      if (emailSent) {
        // Update application status to interview
        await updateApplicationStatus(application.id, ApplicationStatus.interview);

        Get.snackbar(
          '✅ Interview Invitation Sent!',
          'The candidate has been notified and the application status has been updated.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        throw Exception('Failed to send email invitation');
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to send interview invitation: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
