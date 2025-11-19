// lib/common/widgets/language_toggle.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/service/translation_service.dart';
import 'package:timeless/utils/color_res.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final translationService = TranslationService.instance;
      final isEnglish = translationService.currentLanguage.value == 'en';
      
      return InkWell(
        onTap: () {
          translationService.toggleLanguage();
          Get.snackbar(
            translationService.getText('language_switched'),
            isEnglish 
              ? translationService.getText('switched_to_french')
              : translationService.getText('switched_to_english'),
            backgroundColor: ColorRes.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorRes.darkGold, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: ColorRes.darkGold.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEnglish ? '🇺🇸' : '🇫🇷',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                isEnglish ? 'EN' : 'FR',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ColorRes.darkGold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.swap_horiz,
                size: 14,
                color: ColorRes.orange,
              ),
            ],
          ),
        ),
      );
    });
  }
}