import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/screen/settings/settings_screen.dart';
import 'package:timeless/screen/accessibility/accessibility_panel.dart';

class DashBoardController extends GetxController{
  int currentTab = 0;
  void onBottomBarChange(int index) {
    debugPrint("onBottomBarChange called with index: $index");

    if (index == 0) {
      currentTab = 0;
      debugPrint("Home tab selected - currentTab set to 0");

      if (Get.currentRoute != '/dashboard') {
        Get.offAllNamed('/dashboard');
        debugPrint("Navigating to dashboard");
      }
    } else if (index == 1) {
      currentTab = 1;
      debugPrint("Jobs tab selected");
      Get.toNamed(AppRes.jobRecommendationScreen);
    } else if (index == 2) {
      debugPrint("Menu tab selected");
      _showUserMenu();
      currentTab = 0; // Reset to home tab
    }

    debugPrint("Final currentTab: $currentTab");
    update(['bottom_bar']);
  }

  void _showUserMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 80),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Menu',
              style: Get.find<AccessibilityService>().getAccessibleTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000647),
              ),
            ),
            const SizedBox(height: 20),

            // Menu items
            _buildMenuItem(Icons.settings_outlined, 'Settings', () {
              Get.back();
              Get.to(() => const SettingsScreenU());
            }),
            const SizedBox(height: 12),
            _buildMenuItem(Icons.accessibility, 'Accessibility', () {
              Get.back();
              Get.to(() => const AccessibilityPanel());
            }),
            const SizedBox(height: 12),
            _buildMenuItem(Icons.logout, 'Logout', () => Get.offAllNamed('/'), isDestructive: true),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

    return accessibilityService.buildAccessibleWidget(
      semanticLabel: title,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDestructive ? [
              Colors.red[50]!,
              Colors.white,
            ] : [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF000647).withOpacity(0.1),
            width: 1
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDestructive ? [
                    Colors.red,
                    Colors.red.withOpacity(0.8),
                  ] : [
                    const Color(0xFF000647),
                    const Color(0xFF000647).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : const Color(0xFF000647),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive
                ? Colors.red.withOpacity(0.3)
                : const Color(0xFF000647).withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}