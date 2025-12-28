import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/screen/accessibility/accessibility_test_screen.dart';

class AccessibilityPanel extends StatelessWidget {
  const AccessibilityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    final translationService = UnifiedTranslationService.instance;
    
    return Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(
          'Accessibility Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * accessibilityService.currentFontSize.value,
            fontWeight: FontWeight.w600,
          ),
        )),
        backgroundColor: accessibilityService.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Obx(() => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            Center(
              child: Icon(
                Icons.accessibility,
                size: 24,
                color: accessibilityService.primaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildSection(
              'Visual Accessibility',
              [
                _buildToggleItem(
                  'Dark Mode',
                  'Dark theme to reduce eye strain',
                  Icons.dark_mode,
                  accessibilityService.isDarkMode.value,
                  accessibilityService.toggleDarkMode,
                ),
                _buildToggleItem(
                  'Large Text',
                  'Larger text size for better readability',
                  Icons.text_fields,
                  accessibilityService.isLargeTextMode.value,
                  accessibilityService.toggleLargeText,
                ),
                _buildFontSizeControls(),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildSection(
              'Audio Accessibility',
              [
                _buildToggleItem(
                  'Vibration Feedback',
                  'Haptic feedback for actions and notifications',
                  Icons.vibration,
                  accessibilityService.isVibrationEnabled.value,
                  accessibilityService.toggleVibration,
                ),
                _buildToggleItem(
                  'Visual Feedback',
                  'Visual notifications and confirmations',
                  Icons.visibility,
                  accessibilityService.isVisualFeedbackEnabled.value,
                  accessibilityService.toggleVisualFeedback,
                ),
                _buildToggleItem(
                  'Voice Descriptions',
                  'Enhanced screen reader support',
                  Icons.record_voice_over,
                  accessibilityService.isVoiceOverEnabled.value,
                  accessibilityService.toggleVoiceOver,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const AccessibilityTestScreen());
                    },
                    icon: const Icon(Icons.science, size: 16),
                    label: Text(
                      'Test Changes',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accessibilityService.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showResetDialog(context);
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(
                      'Reset to Default',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 80),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final accessibilityService = AccessibilityService.instance;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: accessibilityService.getAccessibleTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: accessibilityService.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildToggleItem(
    String title,
    String description,
    IconData icon,
    bool value,
    VoidCallback onChanged,
  ) {
    final accessibilityService = AccessibilityService.instance;
    
    return accessibilityService.buildAccessibleWidget(
      semanticLabel: '$title. $description. ${value ? 'Enabled' : 'Disabled'}',
      onTap: onChanged,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value 
              ? accessibilityService.primaryColor.withOpacity(0.1)
              : accessibilityService.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value 
                ? accessibilityService.primaryColor
                : accessibilityService.borderColor,
            width: value ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: value
                  ? accessibilityService.primaryColor
                  : accessibilityService.secondaryTextColor,
              size: 24 * accessibilityService.currentFontSize.value,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 12,
                      color: accessibilityService.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: (_) => onChanged(),
              activeThumbColor: accessibilityService.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeControls() {
    final accessibilityService = AccessibilityService.instance;
    
    return Obx(() => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accessibilityService.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accessibilityService.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Font Size Control',
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adjust text size throughout the app',
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: 12,
              color: accessibilityService.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: accessibilityService.decreaseFontSize,
                icon: Icon(
                  Icons.text_decrease,
                  color: accessibilityService.primaryColor,
                ),
                tooltip: 'Decrease font size',
              ),
              Expanded(
                child: Text(
                  'Sample Text (${(accessibilityService.currentFontSize.value * 100).round()}%)',
                  style: accessibilityService.getAccessibleTextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: accessibilityService.increaseFontSize,
                icon: Icon(
                  Icons.text_increase,
                  color: accessibilityService.primaryColor,
                ),
                tooltip: 'Increase font size',
              ),
            ],
          ),
        ],
      ),
    ));
  }


  void _showResetDialog(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    final translationService = UnifiedTranslationService.instance;
    
    showDialog(
      context: context,
      builder: (context) => Obx(() => AlertDialog(
        backgroundColor: accessibilityService.cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: accessibilityService.borderColor,
            width: 1,
          ),
        ),
        title: Text(
          'Reset Settings',
          style: accessibilityService.getAccessibleTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Reset all accessibility settings to default values?',
          style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: accessibilityService.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await accessibilityService.resetToDefault();
              accessibilityService.showAccessibilityFeedback(
                'Settings reset to default',
              );
            },
            style: accessibilityService.getAccessibleButtonStyle(),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      )),
    );
  }
}
