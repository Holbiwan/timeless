import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/services/unified_translation_service.dart';

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
          translationService.getText('accessibility_settings'),
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

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accessibilityService.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black,
                  width: accessibilityService.isHighContrastMode.value ? 3 : 2,
                ),
                boxShadow: accessibilityService.isHighContrastMode.value ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.accessibility,
                    size: 48,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    translationService.getText('accessibility_features'),
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    translationService.getText('accessibility_description'),
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 14,
                      color: accessibilityService.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              translationService.getText('visual_accessibility'),
              [
                _buildToggleItem(
                  translationService.getText('high_contrast_mode'),
                  translationService.getText('high_contrast_description'),
                  Icons.contrast,
                  accessibilityService.isHighContrastMode.value,
                  accessibilityService.toggleHighContrast,
                ),
                _buildToggleItem(
                  translationService.getText('dark_mode'),
                  translationService.getText('dark_mode_description'),
                  Icons.dark_mode,
                  accessibilityService.isDarkMode.value,
                  accessibilityService.toggleDarkMode,
                ),
                _buildToggleItem(
                  translationService.getText('large_text'),
                  translationService.getText('large_text_description'),
                  Icons.text_fields,
                  accessibilityService.isLargeTextMode.value,
                  accessibilityService.toggleLargeText,
                ),
                _buildFontSizeControls(),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildSection(
              translationService.getText('hearing_accessibility'),
              [
                _buildToggleItem(
                  translationService.getText('vibration_feedback'),
                  translationService.getText('vibration_feedback_description'),
                  Icons.vibration,
                  accessibilityService.isVibrationEnabled.value,
                  accessibilityService.toggleVibration,
                ),
                _buildToggleItem(
                  translationService.getText('visual_feedback'),
                  translationService.getText('visual_feedback_description'),
                  Icons.visibility,
                  accessibilityService.isVisualFeedbackEnabled.value,
                  accessibilityService.toggleVisualFeedback,
                ),
                _buildToggleItem(
                  translationService.getText('voice_descriptions'),
                  translationService.getText('voice_descriptions_description'),
                  Icons.record_voice_over,
                  accessibilityService.isVoiceOverEnabled.value,
                  accessibilityService.toggleVoiceOver,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildTestSection(),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showResetDialog(context);
                },
                icon: const Icon(Icons.refresh),
                label: Obx(() => Text(
                  translationService.getText('reset_to_default'),
                  style: GoogleFonts.poppins(
                    fontSize: 16 * accessibilityService.currentFontSize.value,
                    fontWeight: FontWeight.w600,
                  ),
                )),
                style: accessibilityService.getAccessibleButtonStyle(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
              ? accessibilityService.primaryColor.withOpacity(
                  accessibilityService.isHighContrastMode.value ? 0.3 : 0.1)
              : accessibilityService.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value 
                ? accessibilityService.primaryColor
                : accessibilityService.borderColor,
            width: value
                ? (accessibilityService.isHighContrastMode.value ? 3 : 2)
                : 1,
          ),
          boxShadow: accessibilityService.isHighContrastMode.value ? [] : [
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
    final translationService = UnifiedTranslationService.instance;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accessibilityService.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accessibilityService.borderColor,
          width: accessibilityService.isHighContrastMode.value ? 2 : 1,
        ),
        boxShadow: accessibilityService.isHighContrastMode.value ? [] : [
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
          Obx(() => Text(
            translationService.getText('font_size_control'),
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          )),
          const SizedBox(height: 8),
          Obx(() => Text(
            translationService.getText('font_size_description'),
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: 12,
              color: accessibilityService.secondaryTextColor,
            ),
          )),
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
    final translationService = UnifiedTranslationService.instance;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accessibilityService.primaryColor.withOpacity(
          accessibilityService.isHighContrastMode.value ? 0.2 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accessibilityService.primaryColor.withOpacity(
            accessibilityService.isHighContrastMode.value ? 1.0 : 0.3),
          width: accessibilityService.isHighContrastMode.value ? 2 : 1,
        ),
        boxShadow: accessibilityService.isHighContrastMode.value ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
            translationService.getText('test_settings'),
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
          const SizedBox(height: 12),
          Obx(() => Text(
            translationService.getText('test_settings_description'),
            style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
          )),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              accessibilityService.triggerHapticFeedback();
              accessibilityService.showAccessibilityFeedback('Test button pressed!');
            },
            style: accessibilityService.getAccessibleButtonStyle(
              backgroundColor: const Color(0xFF000647),
            ),
            child: Obx(() => Text(
              translationService.getText('test_button'),
              style: GoogleFonts.poppins(
                fontSize: 14 * accessibilityService.currentFontSize.value,
                color: Colors.white,
              ),
            )),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    final translationService = UnifiedTranslationService.instance;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: accessibilityService.cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: accessibilityService.borderColor,
            width: accessibilityService.isHighContrastMode.value ? 2 : 1,
          ),
        ),
        title: Obx(() => Text(
          translationService.getText('reset_dialog_title'),
          style: accessibilityService.getAccessibleTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )),
        content: Obx(() => Text(
          translationService.getText('reset_dialog_message'),
          style: accessibilityService.getAccessibleTextStyle(fontSize: 14),
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Obx(() => Text(
              translationService.getText('cancel'),
              style: TextStyle(color: accessibilityService.primaryColor),
            )),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              accessibilityService.showAccessibilityFeedback(
                'Settings reset to default',
              );
            },
            style: accessibilityService.getAccessibleButtonStyle(),
            child: Obx(() => Text(translationService.getText('reset'))),
          ),
        ],
      ),
    );
  }
}
