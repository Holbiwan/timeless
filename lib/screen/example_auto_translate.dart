// lib/screen/example_auto_translate.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:timeless/service/auto_translation_service.dart';

class ExampleAutoTranslateScreen extends StatelessWidget {
  const ExampleAutoTranslateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialiser le service si pas déjà fait
    if (!Get.isRegistered<AutoTranslationService>()) {
      Get.put(AutoTranslationService());
    }
    
    final autoTranslateService = AutoTranslationService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('🌐 Auto Translation Demo', style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exemple 1: Traduction automatique simple
            Text(
              'Exemple de traduction automatique:',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Texte qui se traduit automatiquement
            autoTranslateService.autoTranslateText(
              'This is an automatic translation example',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            
            const SizedBox(height: 20),
            
            // Exemple 2: Bouton pour traduire un texte
            ElevatedButton(
              onPressed: () async {
                final translated = await autoTranslateService.translateText(
                  'Hello, how are you today?'
                );
                Get.snackbar(
                  'Translation Result',
                  translated,
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
              child: Text('Traduire: "Hello, how are you today?"'),
            ),
            
            const SizedBox(height: 20),
            
            // Exemple 3: Indicateur de traduction en cours
            Obx(() => autoTranslateService.isAutoTranslating.value
                ? const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Traduction en cours...'),
                    ],
                  )
                : const Text('Prêt pour traduction')
            ),
            
            const SizedBox(height: 20),
            
            // Exemple 4: Données Firebase traduites
            FutureBuilder<Map<String, dynamic>>(
              future: autoTranslateService.translateFirebaseData({
                'Position': 'Software Engineer',
                'CompanyName': 'Tech Company Inc.',
                'RequirementsList': ['React', 'Node.js', 'MongoDB'],
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Original: ${data['Position']}'),
                      Text('Traduit: ${data['Position_translated'] ?? 'En cours...'}'),
                    ],
                  );
                }
                
                return const Text('Erreur de traduction');
              },
            ),
          ],
        ),
      ),
    );
  }
}