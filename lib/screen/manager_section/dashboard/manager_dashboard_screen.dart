// Manager/Employer dashboard with bottom navigation for recruiting workflow
// Features job management, applications review, messaging, and profile sections

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:timeless/screen/employer/employer_profile_screen.dart';

import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen_controller.dart';
import 'package:timeless/screen/manager_section/dashboard/widget.dart';
import 'package:timeless/screen/employer/employer_applications_screen.dart';
import 'package:timeless/screen/manager_section/manager_home_screen/manager_home_screen.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/string.dart';

// Jamaica-inspired color palette for manager interface
const _kJBlack = Colors.black; // Background color
const _kJYellow = Color(0xFFFED100); // Active tab highlight
const _kJGreen = Color(0xFF1FA24A); // Inactive elements

class ManagerDashBoardScreen extends StatelessWidget {
  ManagerDashBoardScreen({super.key});

  final ManagerDashBoardScreenController controller =
      Get.put(ManagerDashBoardScreenController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        alert(context); // Confirm exit from manager dashboard
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black, // Consistent dark theme
        body: Obx(() {
          switch (controller.currentTab.value) {
            case 0:
              return ManagerHomeScreen(); // Job posting and management
            case 1:
              return const EmployerApplicationsScreen(); // Review candidates
            case 2:
              return const Center(
                  child: Text('Chat temporarily unavailable')); // Future messaging
            default:
              return const EmployerProfileScreen(); // Company profile management
          }
        }),
        bottomNavigationBar: Obx(
          () {
            int tab = controller.currentTab.value;

            Color iconColor(int index) =>
                tab == index ? _kJYellow : _kJGreen.withOpacity(0.85);

            TextStyle labelStyle(int index) => appTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: tab == index ? _kJYellow : _kJGreen.withOpacity(0.85),
                );

            return SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.zero, // pleine largeur
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: _kJBlack, // fond noir
                child: SalomonBottomBar(
                  margin: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  currentIndex: tab,
                  selectedItemColor: _kJYellow,
                  unselectedItemColor: _kJGreen.withOpacity(0.85),
                  onTap: controller.onBottomBarChange,
                  items: [
                    // Home
                    SalomonBottomBarItem(
                      selectedColor: _kJYellow,
                      icon: Image.asset(
                        AssetRes.home,
                        height: 18,
                        width: 18,
                        color: iconColor(0),
                      ),
                      title: Text(Strings.home, style: labelStyle(0)),
                    ),

                    // Applications
                    SalomonBottomBarItem(
                      selectedColor: _kJYellow,
                      icon: Image.asset(
                        AssetRes.applies,
                        height: 18,
                        width: 18,
                        color: iconColor(1),
                      ),
                      title: Text(Strings.applies, style: labelStyle(1)),
                    ),

                    // Inbox
                    SalomonBottomBarItem(
                      selectedColor: _kJYellow,
                      icon: Image.asset(
                        AssetRes.chat,
                        height: 18,
                        width: 18,
                        color: iconColor(2),
                      ),
                      title: Text(Strings.inbox, style: labelStyle(2)),
                    ),

                    // Profile
                    SalomonBottomBarItem(
                      selectedColor: _kJYellow,
                      icon: Image.asset(
                        AssetRes.profile1,
                        height: 18,
                        width: 18,
                        color: iconColor(3),
                      ),
                      title: Text(Strings.profile, style: labelStyle(3)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Screen'),
    );
  }
}
