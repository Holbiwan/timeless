// Main candidate dashboard that provides navigation between core app features
// Handles authenticated vs guest modes and integrates accessibility theming

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/dashboard/home/home_screen.dart';
import 'package:timeless/screen/dashboard/widget.dart';
import 'package:timeless/screen/new_home_page/new_home_page_screen.dart';

import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/pref_keys.dart';

class DashBoardScreen extends StatelessWidget {
  DashBoardScreen({super.key});

  final DashBoardController controller = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    final String token = PreferencesService.getString(PrefKeys.userId);
    final accessibilityService = AccessibilityService.instance;

    return WillPopScope(
      onWillPop: () async {
        alertU(context); // Show exit confirmation dialog
        return true;
      },
      child: Obx(() => Scaffold(
        backgroundColor: accessibilityService.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: GetBuilder<DashBoardController>(
          id: "bottom_bar",
          builder: (c) {
            // Show appropriate home screen based on authentication status
            return token.isEmpty
                ? const HomePageNewScreenU() // Guest/unauthenticated experience
                : const HomeScreen(); // Full authenticated candidate dashboard
          },
        ),
        bottomNavigationBar: GetBuilder<DashBoardController>(
          id: "bottom_bar",
          builder: (c) {
            return Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.black, // Dark theme for bottom navigation
              ),
              child: BottomNavigationBar(
                currentIndex: c.currentTab,
                onTap: c.onBottomBarChange,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white,
                showUnselectedLabels: true,
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(AssetRes.home,
                        height: 18, width: 18, color: Colors.white),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.work, color: Colors.white, size: 18),
                    label: "Jobs",
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 18),
                    label: "Menu",
                  ),
                ],
              ),
            );
          },
        ),
      )),
    );
  }
}
