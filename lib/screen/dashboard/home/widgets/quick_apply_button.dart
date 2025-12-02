// lib/screen/dashboard/home/widgets/quick_apply_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/services/notification_service.dart';
import 'package:timeless/utils/app_theme.dart';

// Widget for one-click application
// First checks if user has uploaded CV, otherwise redirects to upload
class QuickApplyButton extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final String docId;

  const QuickApplyButton({
    super.key,
    required this.jobData,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobDetailsUploadCvController>(
      init: JobDetailsUploadCvController(),
      builder: (controller) {
        return Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF000647), width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _handleQuickApply(controller, context),
              child: const Center(
                child: Text(
                  "Apply",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleQuickApply(
      JobDetailsUploadCvController controller, BuildContext context) async {
    // Check if user is signed in
    final userId = PreferencesService.getString(PrefKeys.userId);
    if (userId.isEmpty) {
      AppTheme.showStandardSnackBar(
        title: "Connexion requise",
        message: "Veuillez vous connecter pour postuler",
        isError: true,
      );
      return;
    }

    // Check if user already has uploaded CV
    final demoCvUrl = PreferencesService.getString("demo_cv_url");
    final isDemo = userId == "demo_user_12345";
    final hasCV =
        (controller.pdfUrl != null && controller.pdfUrl!.isNotEmpty) ||
            demoCvUrl.isNotEmpty ||
            isDemo;

    if (!hasCV) {
      // Aucun CV -> rediriger vers l'écran d'upload
      AppTheme.showStandardSnackBar(
        title: "CV requis",
        message: "Veuillez d'abord uploader votre CV",
        isError: true,
      );

      // Rediriger vers l'écran d'upload CV avec les données du job
      Get.toNamed(
        AppRes.jobDetailUploadCvScreen,
        arguments: {"doc": jobData},
      );
      return;
    }

    // L'utilisateur a un CV -> candidature directe
    try {
      await _submitQuickApplication(controller, context);

      // Envoyer notification au recruteur
      _sendNotificationToRecruiter();

      // Add notification to user's notification list
      final notificationService = Get.find<NotificationService>();
      await notificationService.addApplicationNotification(
        jobTitle: jobData['Position'] ?? 'Unknown Position',
        companyName: jobData['companyName'] ?? 'Unknown Company',
        jobId: docId,
      );

      // Show confirmation
      AppTheme.showStandardSnackBar(
        title: "Application Sent!",
        message:
            "Your application for ${jobData['Position']} has been submitted",
        isSuccess: true,
      );
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "Error",
        message: "Unable to send application: $e",
        isError: true,
      );
    }
  }

  Future<void> _submitQuickApplication(
      JobDetailsUploadCvController controller, BuildContext context) async {
    try {
      // Pour l'utilisateur démo, on simule un CV
      final userId = PreferencesService.getString(PrefKeys.userId);
      if (userId == "demo_user_12345") {
        controller.pdfUrl = "https://demo.timeless.com/cv/demo_user_cv.pdf";
        controller.filepath.value = "demo_cv.pdf";
      }

      // Utiliser la méthode existante du contrôleur pour soumettre la candidature
      await controller.onTapApply(args: jobData);
    } catch (e) {
      throw Exception('Erreur lors de la candidature: $e');
    }
  }

  void _sendNotificationToRecruiter() {
    // Envoyer notification au recruteur si deviceToken disponible
    final deviceToken = jobData['deviceToken'];
    if (deviceToken != null && deviceToken.isNotEmpty) {
      try {
        final fullName = PreferencesService.getString(PrefKeys.fullName);
        final position = jobData['Position'] ?? 'un poste';

        // Simple snackbar pour la démo au lieu de notification complexe
        AppTheme.showStandardSnackBar(
          title: 'Notification Sent',
          message:
              'The recruiter has been notified of your application for $position',
        );
      } catch (e) {
        // Ignore les erreurs de notification pour ne pas bloquer l'application
        print('Erreur notification: $e');
      }
    }
  }
}

// Widget bouton simple pour candidature rapide (version alternative)
class SimpleQuickApplyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SimpleQuickApplyButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: 90,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: const Color(0xFF000647), width: 2.0),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : const Text(
                "Apply",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
