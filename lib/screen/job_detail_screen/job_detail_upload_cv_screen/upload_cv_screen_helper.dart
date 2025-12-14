import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/screen/manager_section/Notification/notification_services.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/services/unified_translation_service.dart';

class UploadCvScreenHelper {
  // Show application confirmation dialog
  static void showApplicationConfirmationDialog(JobDetailsUploadCvController controller, var args) {
    final translationService = Get.find<UnifiedTranslationService>();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.work_outline,
                size: 50,
                color: Color(0xFF4A90E2),
              ),
              const SizedBox(height: 15),
              Text(
                translationService.getText('confirm_application'),
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorRes.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                translationService.getText('confirm_application_message')
                    .replaceAll('{{position}}', args["doc"]["Position"])
                    .replaceAll('{{company}}', args["doc"]["CompanyName"]),
                textAlign: TextAlign.center,
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorRes.grey,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColorRes.grey),
                        ),
                        child: Text(
                          translationService.getText('cancel_button'),
                          style: appTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ColorRes.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Get.back(); // Close dialog first
                        
                        // Send notification
                        SendNotificationModel notification = SendNotificationModel(
                          title: PreferencesService.getString(PrefKeys.fullName),
                          body: "applied your vacancies",
                          fcmTokens: [args["doc"]["deviceToken"]],
                        );
                        NotificationService.sendNotification(notification);
                        
                        // Submit application
                        await controller.onTapApply(args: args["doc"]);
                        
                        // Show success popup
                        showSuccessPopup(args["doc"]);
                      },
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF4A90E2),
                        ),
                        child: Text(
                          translationService.getText('send_button'),
                          style: appTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show success popup after application submission
  static void showSuccessPopup(var jobDoc) {
    final translationService = Get.find<UnifiedTranslationService>();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green,
              ),
              const SizedBox(height: 15),
              Text(
                translationService.getText('application_sent'),
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorRes.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                translationService.getText('application_sent_message')
                    .replaceAll('{{position}}', jobDoc["Position"])
                    .replaceAll('{{company}}', jobDoc["CompanyName"]),
                textAlign: TextAlign.center,
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorRes.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translationService.getText('confirmation_email_info'),
                textAlign: TextAlign.center,
                style: appTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF4A90E2),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.back(); // Close dialog
                },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green,
                  ),
                  child: Text(
                    translationService.getText('perfect_button'),
                    style: appTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}