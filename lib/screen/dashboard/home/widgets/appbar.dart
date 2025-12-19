import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/screen/settings/settings_screen.dart';
import 'package:timeless/screen/accessibility/accessibility_panel.dart';
import 'package:timeless/screen/profile/profile_controller.dart';

Widget homeAppBar() {
  final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
  final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
  final ProfileController profileController = Get.put(ProfileController());
  
  return Obx(() => Container(
    padding: const EdgeInsets.all(AppTheme.spacingMedium),
    margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingRegular),
    child: Row(
      children: [
        accessibilityService.buildAccessibleWidget(
          semanticLabel: 'Back to login',
          onTap: () {
            accessibilityService.triggerHapticFeedback();
            Get.offAllNamed('/');
          },
          child: Container(
            height: 38,
            width: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 18,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Photo du candidat (taille agrandie)
              Obx(() => Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF000647), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: profileController.profileImageUrl.value.isNotEmpty
                    ? Image.network(
                        profileController.profileImageUrl.value,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                ),
              )),
              // Texte de bienvenue
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '${translationService.getText('welcome')} ',
                  style: accessibilityService.getAccessibleTextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    color: const Color(0xFF000647),
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: PreferencesService.getString(PrefKeys.fullName).isNotEmpty 
                          ? PreferencesService.getString(PrefKeys.fullName)
                          : 'User',
                      style: accessibilityService.getAccessibleTextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Actions modernes
        Row(
          children: [
            accessibilityService.buildAccessibleWidget(
              semanticLabel: 'User menu',
              onTap: () {
                accessibilityService.triggerHapticFeedback();
                _showUserMenu();
              },
              child: Container(
                height: 38,
                width: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.black87,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ));
}

void _showUserMenu() {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      margin: const EdgeInsets.only(bottom: 80),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Menu items
          _buildMenuItem(Icons.settings_outlined, 'Settings', () {
            Get.back();
            Get.to(() => const SettingsScreenU());
          }),
          _buildMenuItem(Icons.accessibility, 'Accessibility', () {
            Get.back();
            Get.to(() => const AccessibilityPanel());
          }),
          _buildMenuItem(Icons.logout, 'Logout', () => Get.offAllNamed('/')),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
  final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
  
  return accessibilityService.buildAccessibleWidget(
    semanticLabel: title,
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryRed),
          const SizedBox(width: AppTheme.spacingRegular),
          Text(
            title,
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

