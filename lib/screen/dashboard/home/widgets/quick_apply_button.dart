// lib/screen/dashboard/home/widgets/quick_apply_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';

/// Widget pour candidature en un clic
/// Vérifie d'abord si l'utilisateur a un CV uploadé, sinon redirige vers l'upload
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
            gradient: const LinearGradient(colors: [
              ColorRes.gradientColor,
              ColorRes.containerColor,
            ]),
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
                    color: Colors.white,
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

  void _handleQuickApply(JobDetailsUploadCvController controller, BuildContext context) async {
    // Vérifier si l'utilisateur est connecté
    final userId = PrefService.getString(PrefKeys.userId);
    if (userId.isEmpty) {
      Get.snackbar(
        "Connexion requise",
        "Veuillez vous connecter pour postuler",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ColorRes.appleGreen,
        colorText: Colors.white,
      );
      return;
    }

    // Vérifier si l'utilisateur a déjà un CV uploadé
    final demoCvUrl = PrefService.getString("demo_cv_url");
    final isDemo = userId == "demo_user_12345";
    final hasCV = (controller.pdfUrl != null && controller.pdfUrl!.isNotEmpty) || 
                  demoCvUrl.isNotEmpty || 
                  isDemo;
                  
    if (!hasCV) {
      // Aucun CV -> rediriger vers l'écran d'upload
      Get.snackbar(
        "CV requis",
        "Veuillez d'abord uploader votre CV",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
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
      
      // Afficher confirmation
      Get.snackbar(
        "Candidature envoyée !",
        "Votre candidature pour ${jobData['Position']} a été transmise",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible d'envoyer la candidature: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitQuickApplication(JobDetailsUploadCvController controller, BuildContext context) async {
    try {
      // Pour l'utilisateur démo, on simule un CV
      final userId = PrefService.getString(PrefKeys.userId);
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
        final fullName = PrefService.getString(PrefKeys.fullName);
        final position = jobData['Position'] ?? 'un poste';
        
        // Simple snackbar pour la démo au lieu de notification complexe
        Get.snackbar(
          'Notification envoyée',
          'Le recruteur a été notifié de votre candidature pour $position',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        // Ignore les erreurs de notification pour ne pas bloquer l'application
        print('Erreur notification: $e');
      }
    }
  }
}

/// Widget bouton simple pour candidature rapide (version alternative)
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
          backgroundColor: const Color(0xFF1FA24A),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Apply",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}