// lib/services/easy_translation_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/app_theme.dart';

class EasyTranslationService extends GetxController {
  static EasyTranslationService get instance => Get.find();
  
  var currentLanguage = 'en'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadLanguageFromPreferences();
  }
  
  void loadLanguageFromPreferences() {
    // Charger la langue depuis les préférences ou utiliser la langue du système
    final savedLang = PreferencesService.getString(PrefKeys.currentLanguage);
    if (savedLang.isNotEmpty) {
      currentLanguage.value = savedLang;
      setLanguage(savedLang);
    } else {
      // Détecter la langue du système
      final systemLocale = Get.deviceLocale?.languageCode ?? 'en';
      final supportedLangs = ['en', 'fr', 'es'];
      currentLanguage.value = supportedLangs.contains(systemLocale) ? systemLocale : 'en';
    }
  }
  
  void setLanguage(String langCode) {
    if (['en', 'fr', 'es'].contains(langCode)) {
      currentLanguage.value = langCode;
      
      // Changer la locale avec Easy Localization
      Get.context?.setLocale(Locale(langCode));
      
      // Sauvegarder la préférence
      PreferencesService.setValue(PrefKeys.currentLanguage, langCode);
      
      // Notification de succès
      final langNames = {
        'en': 'English',
        'fr': 'Français', 
        'es': 'Español'
      };
      
      AppTheme.showStandardSnackBar(
        title: "Language Changed",
        message: "Switched to ${langNames[langCode]}",
        isSuccess: true,
      );
    }
  }
  
  // Méthodes de commodité pour changer de langue rapidement
  void setEnglish() => setLanguage('en');
  void setFrench() => setLanguage('fr');
  void setSpanish() => setLanguage('es');
  
  // Toggle entre les langues (pour un bouton toggle)
  void toggleLanguage() {
    switch (currentLanguage.value) {
      case 'en':
        setFrench();
        break;
      case 'fr':
        setSpanish();
        break;
      case 'es':
        setEnglish();
        break;
      default:
        setEnglish();
    }
  }
  
  // Get current language name
  String get currentLanguageName {
    switch (currentLanguage.value) {
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }
  
  // Get current flag emoji
  String get currentFlag {
    switch (currentLanguage.value) {
      case 'fr':
        return '';
      case 'es':
        return '';
      default:
        return '';
    }
  }
}