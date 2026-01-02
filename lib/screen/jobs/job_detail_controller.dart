import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/services/job_service.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';

class JobDetailController extends GetxController {
  final JobOfferModel job;

  JobDetailController(this.job);

  // Observable variables
  final isBookmarked = false.obs;
  final hasAlreadyApplied = false.obs;
  final isCheckingApplication = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkApplicationStatus();
    loadBookmarkStatus();
  }

  // Check if user has already applied to this job
  Future<void> checkApplicationStatus() async {
    try {
      isCheckingApplication.value = true;
      
      // Get current user ID (candidate)
      String candidateId = PreferencesService.getString(PrefKeys.userId);
      if (candidateId.isEmpty) {
        hasAlreadyApplied.value = false;
        return;
      }

      // Check if application exists
      bool applied = await JobService.hasApplied(candidateId, job.id);
      hasAlreadyApplied.value = applied;
      
    } catch (e) {
      print('Error checking application status: $e');
      hasAlreadyApplied.value = false;
    } finally {
      isCheckingApplication.value = false;
    }
  }

  // Load bookmark status from preferences
  void loadBookmarkStatus() {
    try {
      // Note: Bookmark persistence not yet implemented
      isBookmarked.value = false;
    } catch (e) {
      print('Error loading bookmark status: $e');
    }
  }

  // Toggle bookmark status
  void toggleBookmark() {
    try {
      isBookmarked.value = !isBookmarked.value;
      
      // Note: Persistence will be added in future version
      
      Get.snackbar(
        isBookmarked.value ? 'Favori ajouté' : 'Favori supprimé',
        isBookmarked.value 
            ? 'L\'offre a été ajoutée à vos favoris'
            : 'L\'offre a été supprimée de vos favoris',
        backgroundColor: isBookmarked.value ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier les favoris',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Share job offer
  Future<void> shareJob() async {
    try {
      '''
🚀 Nouvelle opportunité !

${job.title}
${job.companyName}

📍 ${job.location}
💼 ${job.jobTypeDisplay}
⭐ ${job.experienceLevelDisplay}
💰 ${job.salaryDisplay}

${job.description.length > 200 ? '${job.description.substring(0, 200)}...' : job.description}

Postulez dès maintenant sur Timeless !
      '''.trim();

      // Feature temporarily disabled - share functionality removed
      Get.snackbar(
        'Partage',
        'Fonctionnalité de partage temporairement indisponible',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur de partage',
        'Impossible de partager cette offre',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get similar jobs (future implementation)
  Future<List<JobOfferModel>> getSimilarJobs() async {
    try {
      // TODO: Implement algorithm to find similar jobs
      // Could be based on skills, industry, location, etc.
      
      return await JobService.getAllJobOffers(
        limit: 5,
        // Could filter by similar criteria
      );
    } catch (e) {
      print('Error getting similar jobs: $e');
      return [];
    }
  }

  // Report job (future implementation)
  void reportJob(String reason) {
    try {
      // TODO: Implement job reporting functionality
      Get.snackbar(
        'Signalement envoyé',
        'Merci pour votre signalement. Nous examinerons cette offre.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'envoyer le signalement',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Calculate application competition level
  String get competitionLevel {
    if (job.applicationsCount <= 5) {
      return 'Faible';
    } else if (job.applicationsCount <= 15) {
      return 'Modérée';
    } else if (job.applicationsCount <= 30) {
      return 'Élevée';
    } else {
      return 'Très élevée';
    }
  }

  // Get application deadline urgency
  String? get deadlineUrgency {
    if (job.deadline == null) return null;
    
    final now = DateTime.now();
    final difference = job.deadline!.difference(now).inDays;
    
    if (difference < 0) return 'Expiré';
    if (difference == 0) return 'Dernier jour !';
    if (difference <= 3) return 'Urgent ($difference jours)';
    if (difference <= 7) return 'Bientôt ($difference jours)';
    
    return null;
  }
}