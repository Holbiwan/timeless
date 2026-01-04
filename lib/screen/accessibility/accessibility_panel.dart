// ignore_for_file: unused_local_variable

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
      body: SafeArea(
        child: Column(
          children: [
            // Header moderne avec gradient
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF000647),
                    const Color(0xFF0D47A1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000647).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accessibility Settings',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Customize your app experience',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.accessibility_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Obx(() => SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

            
                    // Section Visual
                    _buildModernSection(
                      'Visual Accessibility',
                      'Customize visual appearance and readability',
                      Icons.visibility,
                      const Color(0xFF0D47A1),
                      [
                        _buildToggleItem(
                          'Dark Mode',
                          'Reduces eye strain in low-light environments',
                          Icons.dark_mode,
                          accessibilityService.isDarkMode.value,
                          accessibilityService.toggleDarkMode,
                        ),
                        _buildToggleItem(
                          'Large Text Mode',
                          'Increases text size throughout the app',
                          Icons.text_fields,
                          accessibilityService.isLargeTextMode.value,
                          accessibilityService.toggleLargeText,
                        ),
                        _buildFontSizeControls(),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Section Audio & Haptics
                    _buildModernSection(
                      'Audio & Haptics',
                      'Control feedback and interaction methods',
                      Icons.vibration,
                      const Color(0xFFFF8C00),
                      [
                        _buildToggleItem(
                          'Haptic Feedback',
                          'Vibration feedback for button presses and alerts',
                          Icons.vibration,
                          accessibilityService.isVibrationEnabled.value,
                          accessibilityService.toggleVibration,
                        ),
                        _buildToggleItem(
                          'Visual Feedback',
                          'Enhanced visual notifications and confirmations',
                          Icons.visibility,
                          accessibilityService.isVisualFeedbackEnabled.value,
                          accessibilityService.toggleVisualFeedback,
                        ),
                        _buildToggleItem(
                          'Voice Descriptions',
                          'Screen reader support and audio descriptions',
                          Icons.record_voice_over,
                          accessibilityService.isVoiceOverEnabled.value,
                          accessibilityService.toggleVoiceOver,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Section Navigation
                    _buildModernSection(
                      'Navigation & Interaction',
                      'Improve app navigation and usability',
                      Icons.touch_app,
                      const Color(0xFF000647),
                      [
                        _buildToggleItem(
                          'High Contrast',
                          'Increase contrast for better visibility',
                          Icons.contrast,
                          accessibilityService.isHighContrastMode.value,
                          accessibilityService.toggleHighContrast,
                        ),
                        _buildToggleItem(
                          'Reduce Motion',
                          'Minimize animations and transitions',
                          Icons.motion_photos_off,
                          accessibilityService.isReduceMotionEnabled.value,
                          accessibilityService.toggleReduceMotion,
                        ),
                        _buildToggleItem(
                          'One-Handed Mode',
                          'Optimize interface for single-hand use',
                          Icons.back_hand,
                          accessibilityService.isOneHandedModeEnabled.value,
                          accessibilityService.toggleOneHandedMode,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Boutons d'action modernisés
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[50]!, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Quick Actions',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  'Test Changes',
                                  Icons.science,
                                  const Color(0xFF0D47A1),
                                  () => Get.to(() => const AccessibilityTestScreen()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  'Reset Settings',
                                  Icons.refresh,
                                  const Color(0xFFFF7043),
                                  () => _showResetDialog(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            
                    const SizedBox(height: 20),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSection(String title, String subtitle, IconData icon, Color color, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
      ),
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
          gradient: LinearGradient(
            colors: value 
                ? [const Color(0xFF0D47A1).withOpacity(0.1), Colors.white]
                : [Colors.grey[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value 
                ? const Color(0xFF0D47A1)
                : Colors.grey[300]!,
            width: value ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (value ? const Color(0xFF0D47A1) : Colors.grey).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFF0D47A1)
                    : Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: value ? const Color(0xFF0D47A1).withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Switch(
                value: value,
                onChanged: (_) => onChanged(),
                activeColor: const Color(0xFF0D47A1),
                activeTrackColor: const Color(0xFF0D47A1).withOpacity(0.3),
                inactiveThumbColor: Colors.grey[600],
                inactiveTrackColor: Colors.grey[300],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0D47A1).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.format_size,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Font Size Control',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Adjust text size throughout the app',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    onPressed: accessibilityService.decreaseFontSize,
                    icon: const Icon(
                      Icons.text_decrease,
                      color: Color(0xFF0D47A1),
                    ),
                    tooltip: 'Decrease font size',
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Sample Text',
                        style: GoogleFonts.inter(
                          fontSize: 16 * accessibilityService.currentFontSize.value,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(accessibilityService.currentFontSize.value * 100).round()}%',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF0D47A1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    onPressed: accessibilityService.increaseFontSize,
                    icon: const Icon(
                      Icons.text_increase,
                      color: Color(0xFF0D47A1),
                    ),
                    tooltip: 'Increase font size',
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ),
              ],
            ),
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
            fontSize: 16,
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
              style: TextStyle(color: accessibilityService.primaryColor, fontSize: 16),
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
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      )),
    );
  }
}
