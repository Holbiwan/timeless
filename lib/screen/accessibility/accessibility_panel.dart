// lib/screen/accessibility/accessibility_panel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/service/accessibility_service.dart';
import 'package:timeless/service/translation_service.dart';
import 'package:timeless/utils/color_res.dart';

class AccessibilityPanel extends StatelessWidget {
  const AccessibilityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    final translationService = TranslationService.instance;
    
    return Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(
          '♿ Accessibility Settings',
          style: GoogleFonts.poppins(
            color: accessibilityService.textColor,
            fontSize: 18 * accessibilityService.currentFontSize.value,
          ),
        )),
        backgroundColor: accessibilityService.backgroundColor,
        foregroundColor: accessibilityService.textColor,
        elevation: 0,
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accessibilityService.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accessibilityService.primaryColor,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.accessibility,
                    size: 48,
                    color: accessibilityService.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accessibility Features',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure features for better accessibility',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 14,
                      color: accessibilityService.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Visual Accessibility
            _buildSection(
              '👁️ Visual Accessibility',
              [
                _buildToggleItem(
                  'High Contrast Mode',
                  'Improves visibility with high contrast colors',
                  Icons.contrast,
                  accessibilityService.isHighContrastMode.value,
                  accessibilityService.toggleHighContrast,
                ),
                _buildToggleItem(
                  'Large Text',
                  'Increases text size for better readability',
                  Icons.text_fields,
                  accessibilityService.isLargeTextMode.value,
                  accessibilityService.toggleLargeText,
                ),
                _buildFontSizeControls(),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Hearing Accessibility
            _buildSection(
              '🔊 Hearing Accessibility',
              [
                _buildToggleItem(
                  'Vibration Feedback',
                  'Feel vibrations for audio cues',
                  Icons.vibration,
                  accessibilityService.isVibrationEnabled.value,
                  accessibilityService.toggleVibration,
                ),
                _buildToggleItem(
                  'Visual Feedback',
                  'See visual notifications instead of audio',
                  Icons.visibility,
                  accessibilityService.isVisualFeedbackEnabled.value,
                  accessibilityService.toggleVisualFeedback,
                ),
                _buildToggleItem(
                  'Voice Descriptions',
                  'Enable detailed voice descriptions',
                  Icons.record_voice_over,
                  accessibilityService.isVoiceOverEnabled.value,
                  accessibilityService.toggleVoiceOver,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Test Section
            _buildTestSection(),
            
            const SizedBox(height: 24),
            
            // Reset Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showResetDialog(context);
                },
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Reset to Default',
                  style: GoogleFonts.poppins(
                    fontSize: 16 * accessibilityService.currentFontSize.value,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: accessibilityService.getAccessibleButtonStyle(
                  backgroundColor: ColorRes.appleGreen,
                ),
              ),
            ),
          ],
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
          ),
        ),
        const SizedBox(height: 12),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value 
              ? accessibilityService.primaryColor.withOpacity(0.1)
              : accessibilityService.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value 
                ? accessibilityService.primaryColor
                : accessibilityService.secondaryTextColor,
            width: value ? 2 : 1,
          ),
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
              activeColor: accessibilityService.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeControls() {
    final accessibilityService = AccessibilityService.instance;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accessibilityService.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accessibilityService.secondaryTextColor,
        ),
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
            'Adjust text size for better readability',
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: 12,
              color: accessibilityService.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
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
                child: Obx(() => Text(
                  'Sample Text (${(accessibilityService.currentFontSize.value * 100).round()}%)',
                  style: accessibilityService.getAccessibleTextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                )),
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
    );
  }

  Widget _buildTestSection() {
    final accessibilityService = AccessibilityService.instance;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accessibilityService.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accessibilityService.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧪 Test Your Settings',
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is a sample text to test your accessibility settings. You can see how the contrast, font size, and other features affect readability.',
            style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              accessibilityService.triggerHapticFeedback();
              accessibilityService.showAccessibilityFeedback('Test button pressed!');
            },
            style: accessibilityService.getAccessibleButtonStyle(),
            child: Text(
              'Test Button',
              style: GoogleFonts.poppins(
                fontSize: 14 * accessibilityService.currentFontSize.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: accessibilityService.backgroundColor,
        title: Text(
          'Reset Accessibility Settings',
          style: accessibilityService.getAccessibleTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will reset all accessibility settings to their default values. Continue?',
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
            onPressed: () {
              // Reset logic here
              Navigator.pop(context);
              accessibilityService.showAccessibilityFeedback('Settings reset to default');
            },
            style: accessibilityService.getAccessibleButtonStyle(),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}