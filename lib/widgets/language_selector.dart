import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/utils/color_res.dart';

class LanguageSelector extends StatelessWidget {
  final bool showTitle;
  final bool isCompact;

  const LanguageSelector({
    Key? key,
    this.showTitle = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentLang = context.locale.languageCode;
      
      if (isCompact) {
        return _buildCompactSelector(context, currentLang);
      }
      
      return _buildFullSelector(context, currentLang);
    });
  }

  Widget _buildFullSelector(BuildContext context, String currentLang) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              Row(
                children: [
                  Icon(Icons.language, color: ColorRes.primaryBlueDark),
                  const SizedBox(width: 8),
                  Text(
                    context.tr("language"),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            ...UnifiedTranslationService.instance.supportedLanguages.entries
                .where((entry) => ['en', 'fr', 'es'].contains(entry.key))
                .map((entry) => _buildLanguageOption(
                      context,
                      entry.key,
                      entry.value,
                      currentLang,
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSelector(BuildContext context, String currentLang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: ColorRes.primaryBlueDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLang,
          icon: const Icon(Icons.arrow_drop_down),
          items: [
            DropdownMenuItem(
              value: 'fr',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇫🇷'),
                  const SizedBox(width: 8),
                  Text('Français'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇬🇧'),
                  const SizedBox(width: 8),
                  Text('English'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'es',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇪🇸'),
                  const SizedBox(width: 8),
                  Text('Español'),
                ],
              ),
            ),
          ],
          onChanged: (String? newLanguage) {
            if (newLanguage != null) {
              _changeLanguage(context, newLanguage);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String langCode,
    String langName,
    String currentLang,
  ) {
    final isSelected = currentLang == langCode;
    final flag = UnifiedTranslationService.instance.languageFlags[langCode] ?? '';

    return InkWell(
      onTap: () => _changeLanguage(context, langCode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorRes.primaryBlueDark.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
              ? Border.all(color: ColorRes.primaryBlueDark, width: 2)
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                langName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? ColorRes.primaryBlueDark : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: ColorRes.primaryBlueDark,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, String langCode) async {
    try {
      // Changer avec EasyLocalization
      await context.setLocale(Locale(langCode));
      
      // Synchroniser avec UnifiedTranslationService
      UnifiedTranslationService.instance.setLanguage(langCode);
      
      // Feedback utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("language_changed")),
          duration: const Duration(seconds: 2),
          backgroundColor: ColorRes.primaryBlueDark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("error_changing_language")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Widget pour la barre d'application
class AppBarLanguageSelector extends StatelessWidget {
  const AppBarLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.language, color: ColorRes.white, size: 24),
      color: ColorRes.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onSelected: (String langCode) async {
        try {
          // Change locale immediately
          await context.setLocale(Locale(langCode));
          
          // Update UnifiedTranslationService
          UnifiedTranslationService.instance.setLanguage(langCode);
          
          // Force the entire app to rebuild
          Get.updateLocale(Locale(langCode));
          
          // Show success message
          Get.snackbar(
            langCode == 'fr' ? 'Langue' : 'Language',
            langCode == 'fr' ? 'Langue changée vers FRANÇAIS' : 'Language changed to ENGLISH',
            backgroundColor: ColorRes.primaryBlueDark,
            colorText: ColorRes.white,
            duration: Duration(seconds: 2),
          );
        } catch (e) {
          print('Error changing language: $e');
          Get.snackbar(
            'Error',
            'Could not change language',
            backgroundColor: Colors.red,
            colorText: ColorRes.white,
            duration: Duration(seconds: 2),
          );
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'fr',
          child: Row(
            children: [
              Text('🇫🇷', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(child: Text('Français')),
              if (context.locale.languageCode == 'fr')
                Icon(Icons.check, color: ColorRes.primaryBlueDark, size: 20),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Text('🇬🇧', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(child: Text('English')),
              if (context.locale.languageCode == 'en')
                Icon(Icons.check, color: ColorRes.primaryBlueDark, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}