import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:timeless/config/api_config.dart';

class GoogleTranslationService {
  // Configuration sécurisée depuis le fichier de config
  static const String _baseUrl = ApiConfig.googleTranslationBaseUrl;
  static const String _apiKey = ApiConfig.googleTranslationApiKey;

  // Traduit un texte vers une langue cible
  // [text] : Texte à traduire
  // [targetLanguage] : Code de langue cible (ex: 'fr', 'en', 'es')
  // [sourceLanguage] : Code de langue source (optionnel, auto-détection si null)
  static Future<String?> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      final body = {
        'q': text,
        'target': targetLanguage,
        'format': 'text',
      };

      if (sourceLanguage != null) {
        body['source'] = sourceLanguage;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final translatedText =
            jsonData['data']['translations'][0]['translatedText'];
        return translatedText;
      } else {
        if (kDebugMode) {
          print(
              'Erreur de traduction: ${response.statusCode} - ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la traduction: $e');
      }
      return null;
    }
  }

  // Détecte la langue d'un texte
  static Future<String?> detectLanguage(String text) async {
    try {
      const detectUrl =
          'https://translation.googleapis.com/language/translate/v2/detect';
      final url = Uri.parse('$detectUrl?key=$_apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'q': text},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final detectedLanguage =
            jsonData['data']['detections'][0][0]['language'];
        return detectedLanguage;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la détection de langue: $e');
      }
      return null;
    }
  }

  // Liste des langues supportées
  static Future<List<Language>?> getSupportedLanguages() async {
    try {
      const languagesUrl =
          'https://translation.googleapis.com/language/translate/v2/languages';
      final url = Uri.parse('$languagesUrl?key=$_apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final languages = (jsonData['data']['languages'] as List)
            .map((lang) => Language.fromJson(lang))
            .toList();
        return languages;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des langues: $e');
      }
      return null;
    }
  }
}

// Modèle pour représenter une langue
class Language {
  final String language;
  final String? name;

  Language({required this.language, this.name});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      language: json['language'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'name': name,
    };
  }
}
