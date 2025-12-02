import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/screen/profile/profile_view_screen.dart';
import 'package:timeless/screen/settings/settings_screen.dart';
import 'package:timeless/screen/accessibility/accessibility_panel.dart';

Widget homeAppBar() {
  final TranslationService translationService = Get.find<TranslationService>();
  final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
  
  return Obx(() => Container(
    padding: const EdgeInsets.all(AppTheme.spacingMedium),
    margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingRegular),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      boxShadow: AppTheme.shadowMedium,
    ),
    child: Row(
      children: [
        // Section de salutation centrée et moderne
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                translationService.getText('welcome'),
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: AppTheme.fontSizeXLarge,
                  color: AppTheme.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                PreferencesService.getString(PrefKeys.fullName).isNotEmpty 
                    ? PreferencesService.getString(PrefKeys.fullName)
                    : 'User',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: AppTheme.fontSizeXLarge,
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Actions modernes
        Row(
          children: [
            // Menu utilisateur élégant
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
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                  boxShadow: AppTheme.shadowLight,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryRed,
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
          _buildMenuItem(Icons.person_outline, 'Profile', () {
            Get.back();
            Get.to(() => const ProfileViewScreen()); // Navigation vers l'écran profile
          }),
          _buildMenuItem(Icons.settings_outlined, 'Settings', () {
            Get.back();
            Get.to(() => const SettingsScreenU()); // Navigation vers les paramètres
          }),
          _buildMenuItem(Icons.accessibility, 'Accessibility', () {
            Get.back();
            Get.to(() => const AccessibilityPanel()); // Navigation vers l'accessibilité
          }),
          _buildMenuItem(Icons.help_outline, 'Help', () {
            Get.back();
            _showHelpDialog(); // Affichage de l'aide
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

void _showHelpDialog() {
  final TranslationService translationService = Get.find<TranslationService>();
  
  Get.dialog(
    AlertDialog(
      title: Text(translationService.getText('help')),
      content: Text(
        '${translationService.getText('help_welcome')}\n\n'
        '${translationService.getText('help_profile_desc')}\n'
        '${translationService.getText('help_settings_desc')}\n'
        '${translationService.getText('help_accessibility_desc')}\n'
        '${translationService.getText('help_help_desc')}\n\n'
        '${translationService.getText('help_contact')}',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(translationService.getText('close')),
        ),
      ],
    ),
  );
}
