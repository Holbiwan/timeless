// lib/common/widgets/language_toggle.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/utils/app_theme.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final translationService = UnifiedTranslationService.instance;
      final isEnglish = translationService.currentLanguage.value == 'en';
      
      return InkWell(
        onTap: () {
          translationService.toggleLanguage();
          AppTheme.showStandardSnackBar(
            title: translationService.getText('language_switched'),
            message: isEnglish 
              ? translationService.getText('switched_to_french')
              : translationService.getText('switched_to_english'),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF000647),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF000647), width: 2.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEnglish ? '' : '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                isEnglish ? 'EN' : 'FR',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.swap_horiz,
                size: 14,
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    });
  }
}