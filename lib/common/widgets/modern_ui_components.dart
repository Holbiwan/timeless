// lib/common/widgets/modern_ui_components.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/services/translation_service.dart';

// Composants UI
class ModernUIComponents {
  
  // Card moderne avec design unifié
  static Widget modernCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    Color? backgroundColor,
    bool showBorder = true,
    bool showShadow = true,
  }) {
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? accessibilityService.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
        border: showBorder ? Border.all(
          color: accessibilityService.borderColor,
          width: accessibilityService.isHighContrastMode.value ? 2 : 1,
        ) : null,
        boxShadow: showShadow && !accessibilityService.isHighContrastMode.value 
            ? AppTheme.shadowRegular 
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null ? () {
            accessibilityService.triggerHapticFeedback();
            onTap();
          } : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingMedium),
            child: child,
          ),
        ),
      ),
    );
  }

  // Bouton moderne avec gradient et accessibilité
  static Widget modernButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isPrimary = true,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
    
    return Container(
      width: width,
      margin: margin,
      child: accessibilityService.buildAccessibleWidget(
        semanticLabel: text,
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: isPrimary ? AppTheme.primaryGradient : null,
            color: isPrimary ? null : accessibilityService.backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
            border: isPrimary ? null : Border.all(
              color: accessibilityService.primaryColor,
              width: 2,
            ),
            boxShadow: AppTheme.shadowLight,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
              child: Container(
                alignment: Alignment.center,
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isPrimary ? AppTheme.white : accessibilityService.primaryColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              color: isPrimary 
                                  ? AppTheme.white 
                                  : accessibilityService.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingSmall),
                          ],
                          Text(
                            text,
                            style: accessibilityService.getAccessibleTextStyle(
                              fontSize: AppTheme.fontSizeMedium,
                              fontWeight: FontWeight.w600,
                              color: isPrimary 
                                  ? AppTheme.white 
                                  : accessibilityService.primaryColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Input field moderne et accessible
  static Widget modernTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    String? errorText,
    int maxLines = 1,
  }) {
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: accessibilityService.getAccessibleTextStyle(
            fontSize: AppTheme.fontSizeRegular,
            fontWeight: FontWeight.w500,
            color: accessibilityService.secondaryTextColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
            boxShadow: AppTheme.shadowLight,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            onChanged: onChanged,
            style: accessibilityService.getAccessibleTextStyle(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: accessibilityService.getAccessibleTextStyle(
                color: accessibilityService.secondaryTextColor,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: accessibilityService.secondaryTextColor)
                  : null,
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: Icon(suffixIcon, color: accessibilityService.secondaryTextColor),
                      onPressed: onSuffixTap,
                    )
                  : null,
              errorText: errorText,
              filled: true,
              fillColor: accessibilityService.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                borderSide: BorderSide(
                  color: accessibilityService.borderColor,
                  width: accessibilityService.isHighContrastMode.value ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                borderSide: BorderSide(
                  color: accessibilityService.borderColor,
                  width: accessibilityService.isHighContrastMode.value ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                borderSide: BorderSide(
                  color: accessibilityService.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                borderSide: const BorderSide(color: AppTheme.error, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AppTheme.spacingMedium),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppTheme.spacingSmall),
          AppTheme.errorMessage(errorText),
        ],
      ],
    );
  }

  // Section header moderne avec action optionnelle
  static Widget sectionHeader({
    required String title,
    String? subtitle,
    String? actionText,
    VoidCallback? onActionTap,
    IconData? icon,
  }) {
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: accessibilityService.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                icon,
                color: accessibilityService.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingRegular),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: accessibilityService.getAccessibleTextStyle(
                    fontSize: AppTheme.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: AppTheme.fontSizeRegular,
                      color: accessibilityService.secondaryTextColor,
                    ),
                  ),
              ],
            ),
          ),
          if (actionText != null && onActionTap != null)
            accessibilityService.buildAccessibleWidget(
              semanticLabel: actionText,
              onTap: onActionTap,
              child: Text(
                actionText,
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: accessibilityService.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Bottom sheet moderne
  static void showModernBottomSheet({
    required BuildContext context,
    required String title,
    required Widget content,
    bool isDismissible = true,
  }) {
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: accessibilityService.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusXLarge),
            topRight: Radius.circular(AppTheme.radiusXLarge),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: AppTheme.spacingMedium,
            left: AppTheme.spacingMedium,
            right: AppTheme.spacingMedium,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingMedium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: accessibilityService.secondaryTextColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              
              // Title
              Text(
                title,
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: AppTheme.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              
              // Content
              content,
            ],
          ),
        ),
      ),
    );
  }

  // Notification snackbar moderne
  static void showModernSnackbar({
    required String message,
    String? title,
    IconData? icon,
    Color? backgroundColor,
    Duration? duration,
  }) {
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
    
    Get.snackbar(
      title ?? 'Info',
      message,
      backgroundColor: backgroundColor ?? accessibilityService.primaryColor,
      colorText: AppTheme.white,
      duration: duration ?? const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppTheme.spacingMedium),
      borderRadius: AppTheme.radiusRegular,
      icon: icon != null
          ? Icon(icon, color: AppTheme.white)
          : null,
      shouldIconPulse: false,
      leftBarIndicatorColor: AppTheme.white.withOpacity(0.3),
    );
    
    // Feedback haptique
    accessibilityService.triggerHapticFeedback();
  }

  // Loading indicator moderne
  static Widget modernLoader({
    String? message,
    Color? color,
  }) {
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          color: accessibilityService.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          boxShadow: AppTheme.shadowMedium,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: color ?? accessibilityService.primaryColor,
              strokeWidth: 3,
            ),
            if (message != null) ...[
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                message,
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  color: accessibilityService.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}