// Modern language selector with accessibility support
// lib/common/widgets/modern_language_selector.dart
// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';

class ModernLanguageSelector extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;
  final bool showAutoTranslateToggle;

  const ModernLanguageSelector({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
    this.showAutoTranslateToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    final UnifiedTranslationService translationService =
        Get.find<UnifiedTranslationService>();
    final AccessibilityService accessibilityService =
        Get.find<AccessibilityService>();

    return Obx(
      () => GestureDetector(
        // Open language selection sheet
        onTap: () {
          accessibilityService.triggerHapticFeedback();
          _showLanguageSelection(context);
        },
        child: isCompact
            ? _buildCompactSelector(translationService, accessibilityService)
            : _buildFullSelector(translationService, accessibilityService),
      ),
    );
  }

  // Compact version used in tight layouts
  Widget _buildCompactSelector(
    UnifiedTranslationService translationService,
    AccessibilityService accessibilityService,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accessibilityService.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accessibilityService.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current language flag
          Text(
            translationService.currentFlag ?? '🌐',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          // Language code (EN / FR)
          Text(
            translationService.currentLanguage.value.toUpperCase(),
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: AppTheme.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: accessibilityService.primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.expand_more,
            size: 16,
            color: accessibilityService.primaryColor,
          ),
        ],
      ),
    );
  }

  // Full version with label and gradient
  Widget _buildFullSelector(
    UnifiedTranslationService translationService,
    AccessibilityService accessibilityService,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: AppTheme.shadowRegular,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current language flag
          Text(
            translationService.currentFlag ?? '🌐',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          // Optional language label
          if (showLabel) ...[
            Text(
              translationService.currentLanguageName,
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Bottom sheet to choose language and options
  void _showLanguageSelection(BuildContext context) {
    final UnifiedTranslationService translationService =
        Get.find<UnifiedTranslationService>();
    final AccessibilityService accessibilityService =
        Get.find<AccessibilityService>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: accessibilityService.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: accessibilityService.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.translate,
                          color: accessibilityService.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Choose Language',
                          style: accessibilityService.getAccessibleTextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: accessibilityService.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Auto-translation toggle
                  if (showAutoTranslateToggle) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(
                        () => _buildAutoTranslateToggle(
                          translationService,
                          accessibilityService,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],

                  // Language list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount:
                          translationService.availableLanguageCodes.length,
                      itemBuilder: (context, index) {
                        final langCode =
                            translationService.availableLanguageCodes[index];
                        final isSelected =
                            translationService.currentLanguage.value ==
                                langCode;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildLanguageOption(
                            context,
                            langCode,
                            translationService.getLanguageName(langCode),
                            translationService.getLanguageFlag(langCode),
                            isSelected,
                            translationService,
                            accessibilityService,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Toggle for automatic translation
  Widget _buildAutoTranslateToggle(
    UnifiedTranslationService translationService,
    AccessibilityService accessibilityService,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accessibilityService.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accessibilityService.borderColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_fix_high,
            color: accessibilityService.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto Translation',
                  style: accessibilityService.getAccessibleTextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Automatically translate content',
                  style: accessibilityService.getAccessibleTextStyle(
                    fontSize: AppTheme.fontSizeSmall,
                    color: accessibilityService.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: translationService.isAutoTranslateEnabled.value,
            onChanged: (value) {
              accessibilityService.triggerHapticFeedback();
              translationService.toggleAutoTranslate();
            },
            activeThumbColor: accessibilityService.primaryColor,
          ),
        ],
      ),
    );
  }

  // Single language option item
  Widget _buildLanguageOption(
    BuildContext context,
    String langCode,
    String languageName,
    String flag,
    bool isSelected,
    UnifiedTranslationService translationService,
    AccessibilityService accessibilityService,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          accessibilityService.triggerHapticFeedback();
          translationService.setLanguage(langCode);
        }
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accessibilityService.primaryColor.withOpacity(0.1)
              : accessibilityService.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? accessibilityService.primaryColor
                : accessibilityService.borderColor.withOpacity(0.3),
            width: isSelected
                ? 2
                : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? accessibilityService.primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Language name and code
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? accessibilityService.primaryColor
                          : accessibilityService.textColor,
                    ),
                  ),
                  Text(
                    langCode.toUpperCase(),
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: accessibilityService.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Selected check icon
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accessibilityService.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Floating button version for quick language switch
class FloatingLanguageSelector extends StatelessWidget {
  const FloatingLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final UnifiedTranslationService translationService =
        Get.find<UnifiedTranslationService>();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: Obx(
        () => FloatingActionButton.small(
          heroTag: "language_selector",
          onPressed: () {
            _showQuickLanguageSwitch(context);
          },
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 4,
          child: Text(
            translationService.currentFlag ?? '🌐',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  // Quick toggle between languages
  void _showQuickLanguageSwitch(BuildContext context) {
    final UnifiedTranslationService translationService =
        Get.find<UnifiedTranslationService>();
    translationService.toggleLanguage();
  }
}
