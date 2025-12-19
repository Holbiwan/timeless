// Logout menu and actions
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/services/preferences_service.dart';

class LogoutMenu extends StatelessWidget {
  const LogoutMenu({super.key});

  // Handle user logout with confirmation
  static Future<void> handleLogout() async {
    try {
      // Ask user to confirm logout
      final shouldLogout = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Logout',
            style: appTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorRes.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: appTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorRes.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Cancel',
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorRes.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // Show loading while logging out
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        // Clear local data
        await PreferencesService.clear();

        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Close loader
        Get.back();

        // Go back to login screen
        Get.offAllNamed(AppRes.firstScreen);

        // Show success message
        Get.snackbar(
          'Logged Out',
          'You have been successfully logged out',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorRes.appleGreen,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      // Close loader if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Unable to logout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Build popup menu button
  static Widget buildMenuButton() {
    return PopupMenuButton<String>(
      icon: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: ColorRes.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF000647),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000647).withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.more_vert,
          color: Colors.black,
          size: 18,
        ),
      ),
      onSelected: (String value) async {
        switch (value) {
          case 'home':
            Get.offAllNamed(AppRes.dashBoardScreen);
            break;
          case 'profile':
            // Profile navigation (if needed)
            if (Get.routing.route?.settings.name != '/profile') {
              // TODO: Add profile navigation
            }
            break;
          case 'logout':
            await handleLogout();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'home',
          child: Row(
            children: [
              const Icon(Icons.home, size: 18, color: ColorRes.royalBlue),
              const SizedBox(width: 12),
              Text(
                'Go to Home',
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorRes.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, size: 18, color: ColorRes.brightYellow),
              const SizedBox(width: 12),
              Text(
                'Profile',
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorRes.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 18, color: Colors.red),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMenuButton();
  }
}
