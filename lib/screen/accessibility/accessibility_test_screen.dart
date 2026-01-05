import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/services/accessibility_service.dart';

class AccessibilityTestScreen extends StatelessWidget {
  const AccessibilityTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;

    return Obx(() => Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      appBar: AppBar(
        title: const Text('Accessibility Test'),
        backgroundColor: accessibilityService.primaryColor,
        foregroundColor: Colors.white,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test des couleurs
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accessibilityService.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accessibilityService.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color Test',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accessibilityService.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Primary text: This should be readable',
                    style: accessibilityService.getAccessibleTextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Secondary text: This is smaller text',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 14,
                      color: accessibilityService.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test des boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Test notification avec feedback d'accessibilité
                      accessibilityService.showAccessibilityFeedback(
                        'Colors and theme should adapt to your settings!'
                      );
                      
                      // Aussi test avec Get.snackbar direct
                      Get.snackbar(
                        'Test Success',
                        'This notification uses accessibility colors',
                        backgroundColor: accessibilityService.successColor,
                        colorText: Colors.white,
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        duration: const Duration(seconds: 3),
                      );
                    },
                    style: accessibilityService.getAccessibleButtonStyle(
                      backgroundColor: accessibilityService.successColor,
                    ),
                    child: const Text('Test Notification'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Test haptic feedback
                      accessibilityService.triggerHapticFeedback();
                      
                      // Notification d'erreur pour test
                      Get.snackbar(
                        'Vibration Test',
                        accessibilityService.isVibrationEnabled.value 
                            ? 'Did you feel vibration?' 
                            : 'Vibration is disabled in settings',
                        backgroundColor: accessibilityService.errorColor,
                        colorText: Colors.white,
                        icon: Icon(Icons.vibration, color: Colors.white),
                        duration: const Duration(seconds: 3),
                      );
                    },
                    style: accessibilityService.getAccessibleButtonStyle(
                      backgroundColor: accessibilityService.errorColor,
                    ),
                    child: const Text('Test Haptic'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick toggle buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      accessibilityService.toggleDarkMode();
                    },
                    icon: Icon(accessibilityService.isDarkMode.value ? Icons.light_mode : Icons.dark_mode),
                    label: Text(accessibilityService.isDarkMode.value ? 'Light Mode' : 'Dark Mode'),
                    style: accessibilityService.getAccessibleButtonStyle(
                      backgroundColor: accessibilityService.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      accessibilityService.toggleLargeText();
                    },
                    icon: const Icon(Icons.text_fields),
                    label: Text(accessibilityService.isLargeTextMode.value ? 'Normal Text' : 'Large Text'),
                    style: accessibilityService.getAccessibleButtonStyle(
                      backgroundColor: accessibilityService.warningColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Test des tailles de texte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accessibilityService.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accessibilityService.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size Test',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accessibilityService.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Small text (12px): ${(12 * accessibilityService.currentFontSize.value).round()}px actual',
                    style: accessibilityService.getAccessibleTextStyle(fontSize: 12),
                  ),
                  Text(
                    'Normal text (14px): ${(14 * accessibilityService.currentFontSize.value).round()}px actual',
                    style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
                  ),
                  Text(
                    'Large text (16px): ${(16 * accessibilityService.currentFontSize.value).round()}px actual',
                    style: accessibilityService.getAccessibleTextStyle(fontSize: 16),
                  ),
                  Text(
                    'Title text (18px): ${(18 * accessibilityService.currentFontSize.value).round()}px actual',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test des modes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accessibilityService.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accessibilityService.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Settings',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accessibilityService.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🌙 Dark Mode: ${accessibilityService.isDarkMode.value ? "ON" : "OFF"}',
                    style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
                  ),
                  Text(
                    '🔤 Large Text: ${accessibilityService.isLargeTextMode.value ? "ON" : "OFF"}',
                    style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
                  ),
                  Text(
                    '📏 Font Scale: ${accessibilityService.currentFontSize.value.toStringAsFixed(1)}x',
                    style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
                  ),
                  Text(
                    '📳 Vibration: ${accessibilityService.isVibrationEnabled.value ? "ON" : "OFF"}',
                    style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Text(
              'Test Instructions:',
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: accessibilityService.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '🔔 Test Notification: Shows a success notification with accessibility colors\n\n'
              '📳 Test Haptic: Triggers vibration (if enabled) + shows error notification\n\n'
              '🌙 Dark/Light Mode: Instant toggle to see theme change in real-time\n\n'
              '🔤 Large/Normal Text: Instant toggle to see font size change\n\n'
              '📱 Navigate to other screens to verify global changes',
              style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.back(),
        backgroundColor: accessibilityService.primaryColor,
        foregroundColor: Colors.white,
        label: const Text('Back'),
        icon: const Icon(Icons.arrow_back),
      ),
    ));
  }
}