// lib/common/widgets/language_switcher.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;

  const LanguageSwitcher({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

    return Obx(() => accessibilityService.buildAccessibleWidget(
      semanticLabel: 'Change language. Current language: ${translationService.currentLanguageName}',
      onTap: () {
        accessibilityService.triggerHapticFeedback();
        _showLanguageDialog(context);
      },
      child: isCompact ? _buildCompactSwitch() : _buildFullSwitch(),
    ));
  }

  Widget _buildCompactSwitch() {
    final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: accessibilityService.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: accessibilityService.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.translate,
            size: 16,
            color: accessibilityService.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            translationService.currentLanguage.value.toUpperCase(),
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: AppTheme.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: accessibilityService.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullSwitch() {
    final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingRegular,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
        boxShadow: AppTheme.shadowLight,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.translate,
            color: AppTheme.white,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          if (showLabel) ...[
            Text(
              translationService.currentLanguage.value.toUpperCase(),
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.white,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: accessibilityService.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
            side: BorderSide(
              color: accessibilityService.borderColor,
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.translate,
                color: accessibilityService.primaryColor,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                'Choose Language',
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                'English',
                '🇺🇸',
                'en',
                translationService.currentLanguage.value == 'en',
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              _buildLanguageOption(
                context,
                'Français',
                '🇫🇷',
                'fr',
                translationService.currentLanguage.value == 'fr',
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              _buildLanguageOption(
                context,
                'Español',
                '🇪🇸',
                'es',
                translationService.currentLanguage.value == 'es',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: accessibilityService.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageName,
    String flag,
    String languageCode,
    bool isSelected,
  ) {
    final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

    return accessibilityService.buildAccessibleWidget(
      semanticLabel: '$languageName. ${isSelected ? 'Currently selected' : 'Tap to select'}',
      onTap: () {
        if (!isSelected) {
          accessibilityService.triggerHapticFeedback();
          translationService.setLanguage(languageCode);
          
          // Provide immediate visual feedback to the user that the language has changed.
          AppTheme.showStandardSnackBar(
            title: 'Language Changed',
            message: languageCode == 'en' 
                ? 'Switched to English'
                : languageCode == 'fr'
                ? 'Switched to French'
                : languageCode == 'es'
                ? 'Switched to Spanish'
                : 'Language changed',
            isSuccess: true,
          );
        }
        Navigator.of(context).pop();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingRegular),
        decoration: BoxDecoration(
          color: isSelected 
              ? accessibilityService.primaryColor.withOpacity(0.1)
              : accessibilityService.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected 
                ? accessibilityService.primaryColor
                : accessibilityService.borderColor,
            width: isSelected 
                ? 2 
                : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppTheme.spacingRegular),
            Expanded(
              child: Text(
                languageName,
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? accessibilityService.primaryColor
                      : accessibilityService.textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: accessibilityService.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// A floating widget that allows users to switch languages from anywhere on the screen.
class FloatingLanguageSwitcher extends StatelessWidget {
  const FloatingLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppTheme.spacingRegular,
      right: AppTheme.spacingRegular,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
          boxShadow: AppTheme.shadowRegular,
        ),
        child: const LanguageSwitcher(
          showLabel: false,
          isCompact: true,
        ),
      ),
    );
  }
}