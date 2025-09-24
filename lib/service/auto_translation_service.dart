// lib/service/auto_translation_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:translator/translator.dart';
import 'package:timeless/service/translation_service.dart';

class AutoTranslationService extends GetxController {
  static AutoTranslationService get instance => Get.find();
  
  final GoogleTranslator _translator = GoogleTranslator();
  var isAutoTranslating = false.obs;
  
  // Cache to avoid repeated calls
  final Map<String, String> _translationCache = {};
  
  /// Traduit automatiquement un texte
  Future<String> translateText(String text, {String? targetLanguage}) async {
    if (text.isEmpty) return text;
    
    final targetLang = targetLanguage ?? TranslationService.instance.currentLanguage.value;
    final cacheKey = '${text}_$targetLang';
    
    // Check cache
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }
    
    try {
      isAutoTranslating.value = true;
      
      // Traduire avec Google Translate
      final translation = await _translator.translate(
        text,
        to: targetLang,
        from: 'auto', // Automatic source language detection
      );
      
      // Mettre en cache
      _translationCache[cacheKey] = translation.text;
      
      return translation.text;
    } catch (e) {
      print('Erreur traduction: $e');
      return text; // Retourner le texte original en cas d'erreur
    } finally {
      isAutoTranslating.value = false;
    }
  }
  
  /// Traduit automatiquement tous les textes d'un Map
  Future<Map<String, String>> translateMap(Map<String, String> texts) async {
    final Map<String, String> translatedTexts = {};
    
    for (final entry in texts.entries) {
      translatedTexts[entry.key] = await translateText(entry.value);
    }
    
    return translatedTexts;
  }
  
  /// Widget for real-time automatic translation
  Widget autoTranslateText(String text, {TextStyle? style}) {
    return Obx(() {
      if (TranslationService.instance.currentLanguage.value == 'en') {
        // If already in English, display directly
        return Text(text, style: style);
      }
      
      return FutureBuilder<String>(
        future: translateText(text),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                SizedBox(width: 8),
                Text(text, style: style?.copyWith(color: Colors.grey)),
              ],
            );
          }
          
          return Text(
            snapshot.data ?? text,
            style: style,
          );
        },
      );
    });
  }
  
  /// Automatically translates Firebase data
  Future<Map<String, dynamic>> translateFirebaseData(Map<String, dynamic> data) async {
    final translatedData = Map<String, dynamic>.from(data);
    
    // Common text fields to translate
    final fieldsToTranslate = [
      'Position', 'CompanyName', 'description', 'location', 
      'category', 'fullName', 'Occupation'
    ];
    
    for (final field in fieldsToTranslate) {
      if (data.containsKey(field) && data[field] is String) {
        translatedData['${field}_translated'] = await translateText(data[field]);
      }
    }
    
    // Traduire les listes (comme RequirementsList)
    if (data.containsKey('RequirementsList') && data['RequirementsList'] is List) {
      final requirements = data['RequirementsList'] as List;
      final translatedRequirements = <String>[];
      
      for (final req in requirements) {
        if (req is String) {
          translatedRequirements.add(await translateText(req));
        }
      }
      
      translatedData['RequirementsList_translated'] = translatedRequirements;
    }
    
    return translatedData;
  }
  
  /// Efface le cache de traduction
  void clearCache() {
    _translationCache.clear();
  }
  
  /// Pre-translates most common texts for performance
  Future<void> preloadCommonTranslations() async {
    final commonTexts = [
      'Apply Now', 'Job Details', 'Requirements', 'Description',
      'Company', 'Location', 'Salary', 'Type', 'Category',
      'Full Time', 'Part Time', 'Contract', 'Remote',
    ];
    
    for (final text in commonTexts) {
      await translateText(text, targetLanguage: 'fr');
      await translateText(text, targetLanguage: 'en');
    }
  }
}