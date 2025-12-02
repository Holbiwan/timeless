// lib/common/widgets/accessibility_fab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/screen/accessibility/accessibility_panel.dart';

class AccessibilityFAB extends StatelessWidget {
  const AccessibilityFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;
    
    return Obx(() => Positioned(
      right: 16,
      bottom: 80, // Au-dessus de la barre de navigation
      child: accessibilityService.buildAccessibleWidget(
        semanticLabel: 'Open accessibility settings',
        onTap: () {
          Get.to(() => const AccessibilityPanel());
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: accessibilityService.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: accessibilityService.isHighContrastMode.value
                ? Border.all(color: Colors.white, width: 3)
                : null,
          ),
          child: Icon(
            Icons.accessibility,
            color: accessibilityService.isHighContrastMode.value 
                ? Colors.black 
                : Colors.white,
            size: 28,
          ),
        ),
      ),
    ));
  }
}