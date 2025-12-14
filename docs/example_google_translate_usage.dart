// example_google_translate_usage.dart
// Exemple d'utilisation du service de traduction Google

// ignore_for_file: unused_import

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/common/widgets/modern_language_selector.dart';

// Fonction pour tester rapidement le service
void testTranslationService() async {
  final service = Get.find<UnifiedTranslationService>();

  print('=== Test Google Translation Service - Version Améliorée ===');

  // Test 0: Service availability
  print('\nTest 0: Checking service availability...');
  final isAvailable = await service.isTranslationServiceAvailable();
  print('Service disponible: $isAvailable');

  if (!isAvailable) {
    print(
        '⚠️  Service non disponible. Vérifiez votre connexion et votre clé API.');
    return;
  }

  // Test 1: Translate to French
  print('\nTest 1: English to French');
  service.setFrench();
  final frenchTranslation =
      await service.translateDynamicText('Hello, how are you today?');
  print('Original: Hello, how are you today?');
  print('French: $frenchTranslation');

  // Test 2: Translate to Spanish
  print('\nTest 2: English to Spanish');
  service.setSpanish();
  final spanishTranslation =
      await service.translateDynamicText('Hello, how are you today?');
  print('Original: Hello, how are you today?');
  print('Spanish: $spanishTranslation');

  // Test 3: Language detection
  print('\nTest 3: Language Detection');
  final detected1 =
      await service.detectTextLanguage('Bonjour, comment allez-vous?');
  final detected2 = await service.detectTextLanguage('Hola, ¿cómo estás?');
  final detected3 = await service.detectTextLanguage('Hello, how are you?');
  final detected4 = await service.detectTextLanguage('مرحبا، كيف حالك؟');
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
    final translated = await service.translateDynamicText('Welcome to our app!');
    final langName = service.getLanguageName(langCode);
    final flag = service.getLanguageFlag(langCode);
    print('$flag $langName ($langCode): $translated');
  }

  // Test 6: Error handling (texte vide)
  print('\nTest 6: Error Handling');
  final emptyResult = await service.translateDynamicText('');
  print('Traduction de texte vide: "$emptyResult"');

  final nullDetection = await service.detectTextLanguage('');
  print('Détection de langue sur texte vide: $nullDetection');

  // Test 7: Current state
  print('\nTest 7: Current State');
  print(
      'Langue actuelle: ${service.currentLanguageName} ${service.currentFlag}');
  print(
      'Auto-traduction: ${service.isAutoTranslateEnabled.value ? "Activée" : "Désactivée"}');
  print(
      'En cours de traduction: ${service.isTranslating.value ? "Oui" : "Non"}');

  print('\n=== Tests completed successfully! ===');
}

/*
EXEMPLE D'UTILISATION DANS VOS ÉCRANS :

1. Dans un widget d'affichage de texte :
   
   class JobDescriptionWidget extends StatelessWidget {
     final String description;
     
     const JobDescriptionWidget({Key? key, required this.description}) : super(key: key);

     @override
     Widget build(BuildContext context) {
       final translationService = Get.find<UnifiedTranslationService>();
       
       return FutureBuilder<String>(
         future: translationService.autoTranslateIfEnabled(description),
         builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
             return const CircularProgressIndicator();
           }
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

3. Pour traduire du contenu dynamique à la demande :
   
   class JobTitleWidget extends StatefulWidget {
     final String jobTitle;
     const JobTitleWidget({Key? key, required this.jobTitle}) : super(key: key);
     @override
     _JobTitleWidgetState createState() => _JobTitleWidgetState();
   }
   
   class _JobTitleWidgetState extends State<JobTitleWidget> {
     String? displayedTitle;
     
     @override
     void initState() {
       super.initState();
       displayedTitle = widget.jobTitle;
     }

     void translateJobTitle() async {
       final service = Get.find<UnifiedTranslationService>();
       final translated = await service.translateDynamicText(widget.jobTitle);
       setState(() {
         displayedTitle = translated;
       });
     }

     @override
     Widget build(BuildContext context) {
       return Row(
         children: [
           Text(displayedTitle ?? ''),
           IconButton(
             icon: Icon(Icons.translate),
             onPressed: translateJobTitle,
           ),
         ],
       );
     }
   }

4. Dans un Drawer ou un menu de paramètres :
   
   ListTile(
     leading: Icon(Icons.language),
     title: Text('App Language'),
     trailing: ModernLanguageSelector(isCompact: false), // Version non compacte
     onTap: () {
       // Ouvre un dialogue ou un écran pour la sélection de la langue
     },
   )

5. Pour les notifications push (côté client) :
   
   void showTranslatedNotification(String messageKey, Map<String, dynamic> data) async {
     final service = Get.find<UnifiedTranslationService>();
     // Traduit un message à partir d'une clé, si nécessaire
     final title = service.getText('notification_title'); 
     final body = await service.autoTranslateIfEnabled(data['body']);
     
     // Logique pour afficher la notification...
     print('Displaying Notification: $title - $body');
   }
*/
