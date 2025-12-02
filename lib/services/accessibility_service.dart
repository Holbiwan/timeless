// lib/service/accessibility_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeless/utils/app_theme.dart';

class AccessibilityService extends GetxController {
  static AccessibilityService get instance => Get.find();
  
  // Options d'accessibilité
  var isHighContrastMode = false.obs;
  var isDarkMode = false.obs;
  var isLargeTextMode = false.obs;
  var isVibrationEnabled = true.obs;
  var isVisualFeedbackEnabled = true.obs;
  var isVoiceOverEnabled = false.obs;
  var currentFontSize = 1.0.obs; // Facteur de taille de police
  
  @override
  void onInit() {
    super.onInit();
    _loadAccessibilitySettings();
  }
  
  Future<void> _loadAccessibilitySettings() async {
    final prefs = await SharedPreferences.getInstance();
    isHighContrastMode.value = prefs.getBool('high_contrast') ?? false;
    isDarkMode.value = prefs.getBool('dark_mode') ?? false;
    isLargeTextMode.value = prefs.getBool('large_text') ?? false;
    isVibrationEnabled.value = prefs.getBool('vibration') ?? true;
    isVisualFeedbackEnabled.value = prefs.getBool('visual_feedback') ?? true;
    isVoiceOverEnabled.value = prefs.getBool('voice_over') ?? false;
    currentFontSize.value = prefs.getDouble('font_size') ?? 1.0;
  }
  
  Future<void> _saveAccessibilitySettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', isHighContrastMode.value);
    await prefs.setBool('dark_mode', isDarkMode.value);
    await prefs.setBool('large_text', isLargeTextMode.value);
    await prefs.setBool('vibration', isVibrationEnabled.value);
    await prefs.setBool('visual_feedback', isVisualFeedbackEnabled.value);
    await prefs.setBool('voice_over', isVoiceOverEnabled.value);
    await prefs.setDouble('font_size', currentFontSize.value);
  }
  
  void toggleHighContrast() {
    isHighContrastMode.value = !isHighContrastMode.value;
    _saveAccessibilitySettings();
    showAccessibilityFeedback('High Contrast ${isHighContrastMode.value ? 'Enabled' : 'Disabled'}');
  }
  
  void toggleLargeText() {
    isLargeTextMode.value = !isLargeTextMode.value;
    currentFontSize.value = isLargeTextMode.value ? 1.4 : 1.0;
    _saveAccessibilitySettings();
    showAccessibilityFeedback('Large Text ${isLargeTextMode.value ? 'Enabled' : 'Disabled'}');
  }
  
  void toggleVibration() {
    isVibrationEnabled.value = !isVibrationEnabled.value;
    _saveAccessibilitySettings();
    if (isVibrationEnabled.value) {
      HapticFeedback.mediumImpact();
    }
    showAccessibilityFeedback('Vibration ${isVibrationEnabled.value ? 'Enabled' : 'Disabled'}');
  }
  
  void toggleVisualFeedback() {
    isVisualFeedbackEnabled.value = !isVisualFeedbackEnabled.value;
    _saveAccessibilitySettings();
    showAccessibilityFeedback('Visual Feedback ${isVisualFeedbackEnabled.value ? 'Enabled' : 'Disabled'}');
  }
  
  void toggleVoiceOver() {
    isVoiceOverEnabled.value = !isVoiceOverEnabled.value;
    _saveAccessibilitySettings();
    showAccessibilityFeedback('Voice Descriptions ${isVoiceOverEnabled.value ? 'Enabled' : 'Disabled'}');
  }
  
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    _saveAccessibilitySettings();
    showAccessibilityFeedback('Dark Mode ${isDarkMode.value ? 'Enabled' : 'Disabled'}');
  }
  
  void increaseFontSize() {
    if (currentFontSize.value < 2.0) {
      currentFontSize.value += 0.2;
      _saveAccessibilitySettings();
      showAccessibilityFeedback('Font Size Increased');
    }
  }
  
  void decreaseFontSize() {
    if (currentFontSize.value > 0.8) {
      currentFontSize.value -= 0.2;
      _saveAccessibilitySettings();
      showAccessibilityFeedback('Font Size Decreased');
    }
  }
  
  void showAccessibilityFeedback(String message) {
    if (isVibrationEnabled.value) {
      HapticFeedback.lightImpact();
    }
    
    if (isVisualFeedbackEnabled.value) {
      AppTheme.showStandardSnackBar(
        title: '♿ Accessibility',
        message: message,
      );
    }
  }
  
  // Getters pour les styles accessibles
  Color get primaryColor {
    if (isHighContrastMode.value) return Colors.black;
    if (isDarkMode.value) return Colors.white;
    return const Color(0xFF000647); // Couleur bleu foncé de l'app
  }
  
  Color get backgroundColor {
    if (isHighContrastMode.value) return Colors.white;
    if (isDarkMode.value) return const Color(0xFF121212);
    return Colors.white;
  }
  
  Color get textColor {
    if (isHighContrastMode.value) return Colors.black;
    if (isDarkMode.value) return const Color(0xFFE0E0E0);
    return Colors.black;
  }
  
  Color get secondaryTextColor {
    if (isHighContrastMode.value) return Colors.grey.shade800;
    if (isDarkMode.value) return const Color(0xFFBDBDBD);
    return Colors.grey.shade600;
  }
  
  Color get successColor => isHighContrastMode.value ? Colors.black : (isDarkMode.value ? Colors.white : const Color(0xFF000647));
  Color get warningColor => isHighContrastMode.value ? Colors.black : (isDarkMode.value ? Colors.white : const Color(0xFF000647));
  Color get errorColor => isHighContrastMode.value ? Colors.black : (isDarkMode.value ? Colors.white : const Color(0xFF000647));
  
  Color get cardBackgroundColor {
    if (isHighContrastMode.value) return Colors.white;
    if (isDarkMode.value) return const Color(0xFF1E1E1E);
    return Colors.grey.shade50;
  }
  
  Color get borderColor {
    if (isHighContrastMode.value) return Colors.black;
    if (isDarkMode.value) return Colors.grey.shade700;
    return Colors.grey.shade300;
  }
  
  Color get feedbackBackgroundColor {
    if (isHighContrastMode.value) return Colors.white;
    if (isDarkMode.value) return primaryColor;
    return const Color(0xFF000647);
  }
  
  Color get feedbackTextColor {
    if (isHighContrastMode.value) return Colors.black;
    return Colors.white;
  }
  
  TextStyle getAccessibleTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: (fontSize ?? 14) * currentFontSize.value,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? textColor,
      decoration: isHighContrastMode.value ? TextDecoration.underline : null,
    );
  }
  
  ButtonStyle getAccessibleButtonStyle({Color? backgroundColor}) {
    final bgColor = backgroundColor ?? primaryColor;
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: _getContrastingTextColor(bgColor),
      elevation: isHighContrastMode.value ? 8 : 2,
      side: isHighContrastMode.value ? BorderSide(color: textColor, width: 2) : null,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * currentFontSize.value,
        vertical: 12 * currentFontSize.value,
      ),
      textStyle: TextStyle(
        fontSize: 16 * currentFontSize.value,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Color _getContrastingTextColor(Color backgroundColor) {
    if (isHighContrastMode.value) return Colors.black;
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  void triggerHapticFeedback([HapticFeedback? type]) {
    if (isVibrationEnabled.value) {
      switch (type) {
        case null:
          HapticFeedback.lightImpact();
          break;
        default:
          HapticFeedback.lightImpact();
      }
    }
  }
  
  // Support pour les lecteurs d'écran
  String getSemanticLabel(String text) {
    if (isVoiceOverEnabled.value) {
      return '$text. Accessibility mode enabled.';
    }
    return text;
  }
  
  Widget buildAccessibleWidget({
    required Widget child,
    required String semanticLabel,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: getSemanticLabel(semanticLabel),
      button: onTap != null,
      child: InkWell(
        onTap: onTap != null ? () {
          triggerHapticFeedback();
          onTap();
        } : null,
        child: child,
      ),
    );
  }
}