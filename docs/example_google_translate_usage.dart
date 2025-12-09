// example_google_translate_usage.dart
// Exemple d'utilisation du service de traduction Google

import 'package:get/get.dart';
import 'package:timeless/services/comprehensive_translation_service.dart';

// Fonction pour tester rapidement le service
void testTranslationService() async {
  final ComprehensiveTranslationService service = Get.find<ComprehensiveTranslationService>();
  
  print('=== Test Google Translation Service - Version Améliorée ===');
  
  // Test 0: Service availability
  print('\nTest 0: Checking service availability...');
  final isAvailable = await service.isTranslationServiceAvailable();
  print('Service disponible: $isAvailable');
  
  if (!isAvailable) {
    print('⚠️  Service non disponible. Vérifiez votre connexion et votre clé API.');
    return;
  }
  
  // Test 1: Translate to French
  print('\nTest 1: English to French');
  service.setFrench();
  final frenchTranslation = await service.translateText('Hello, how are you today?');
  print('Original: Hello, how are you today?');
  print('French: $frenchTranslation');
  
  // Test 2: Translate to Spanish
  print('\nTest 2: English to Spanish');
  service.setSpanish();
  final spanishTranslation = await service.translateText('Hello, how are you today?');
  print('Original: Hello, how are you today?');
  print('Spanish: $spanishTranslation');
  
  // Test 3: Language detection
  print('\nTest 3: Language Detection');
  final detected1 = await service.detectLanguage('Bonjour, comment allez-vous?');
  final detected2 = await service.detectLanguage('Hola, ¿cómo estás?');
  final detected3 = await service.detectLanguage('Hello, how are you?');
  final detected4 = await service.detectLanguage('مرحبا، كيف حالك؟');
  print('French text detected as: $detected1');
  print('Spanish text detected as: $detected2');
  print('English text detected as: $detected3');
  print('Arabic text detected as: $detected4');
  
  // Test 4: Auto-translate feature
  print('\nTest 4: Auto-translate');
  service.isAutoTranslateEnabled.value = true;
  service.setFrench();
  final autoTranslated = await service.autoTranslateIfEnabled('Good morning!');
  print('Auto-translated "Good morning!" to French: $autoTranslated');
  
  // Test 5: Multiple languages
  print('\nTest 5: Multiple Languages');
  for (String langCode in ['de', 'it', 'pt', 'ja', 'ko']) {
    service.setLanguage(langCode);
    final translated = await service.translateText('Welcome to our app!');
    final langName = service.getLanguageName(langCode);
    final flag = service.getLanguageFlag(langCode);
    print('$flag $langName ($langCode): $translated');
  }
  
  // Test 6: Error handling (texte vide)
  print('\nTest 6: Error Handling');
  final emptyResult = await service.translateText('');
  print('Traduction de texte vide: "$emptyResult"');
  
  final nullDetection = await service.detectLanguage('');
  print('Détection de langue sur texte vide: $nullDetection');
  
  // Test 7: Current state
  print('\nTest 7: Current State');
  print('Langue actuelle: ${service.currentLanguageName} ${service.currentFlag}');
  print('Auto-traduction: ${service.isAutoTranslateEnabled.value ? "Activée" : "Désactivée"}');
  print('En cours de traduction: ${service.isTranslating.value ? "Oui" : "Non"}');
  
  print('\n=== Tests completed successfully! ===');
}

/*
EXEMPLE D'UTILISATION DANS UOS ÉCRANS :

1. Dans un widget d'affichage de texte :
   
   class JobDescriptionWidget extends StatelessWidget {
     final String description;
     
     Widget build(BuildContext context) {
       final translationService = Get.find<ComprehensiveTranslationService>();
       
       return FutureBuilder<String>(
         future: translationService.autoTranslateIfEnabled(description),
         builder: (context, snapshot) {
           return Text(snapshot.data ?? description);
         },
       );
     }
   }

2. Dans l'AppBar d'un écran :
   
   AppBar(
     title: Text('My Jobs'),
     actions: [
       ModernLanguageSelector(isCompact: true),
     ],
   )

3. Pour traduire du contenu dynamique :
   
   void translateJobTitle() async {
     final service = Get.find<ComprehensiveTranslationService>();
     final translated = await service.translateText(jobTitle);
     setState(() {
       displayedTitle = translated;
     });
   }

4. Dans un drawer ou menu :
   
   ListTile(
     leading: Icon(Icons.translate),
     title: Text('Language Settings'),
     trailing: ModernLanguageSelector(isCompact: true),
   )

5. Pour les notifications push traduites :
   
   void showTranslatedNotification(String message) async {
     final service = Get.find<ComprehensiveTranslationService>();
     final translated = await service.autoTranslateIfEnabled(message);
     // Afficher la notification avec le texte traduit
   }
*/