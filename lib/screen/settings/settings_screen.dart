// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/looking_for_screen/looking_for_screen.dart';
import 'package:timeless/screen/profile/profile_controller.dart';
import 'package:timeless/screen/accessibility/accessibility_panel.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/google_auth_service.dart';
import 'package:timeless/services/auth_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/app_theme.dart';

class SettingsScreenU extends StatelessWidget {
  const SettingsScreenU({super.key});
  
  ProfileController get profileController => Get.put(ProfileController());
  AuthService get authService => Get.put(AuthService());

  @override
  Widget build(BuildContext context) {
    DashBoardController controller = Get.put(DashBoardController());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header moderne avec gradient
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000647).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Get.offAllNamed('/dashboard');
                      }
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        // ignore: deprecated_member_use
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Settings",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Account
                    _buildModernSectionHeader(
                      "Account",
                      "Manage your personal information and security",
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.person_outline,
                            title: "Edit profile",
                            subtitle: "Update your personal information",
                            color: const Color(0xFF0D47A1),
                            onTap: () => _showEditProfile(context),
                          ),
                          _buildDivider(),
                          _buildSettingsItem(
                            icon: Icons.lock_outline,
                            title: "Change password",
                            subtitle: "Update your password securely",
                            color: const Color(0xFF2196F3),
                            onTap: () => _showChangePassword(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section Accessibility
                    _buildModernSectionHeader(
                      "Accessibility & Preferences",
                      "Customize your app experience",
                      Icons.accessibility_new,
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.accessibility_new,
                            title: "Accessibility Settings",
                            subtitle: "Visual, audio & navigation preferences",
                            color: const Color(0xFF2196F3),
                            onTap: () => Get.to(() => const AccessibilityPanel()),
                          ),
                          _buildDivider(),
                          _buildSettingsItem(
                            icon: Icons.notifications_outlined,
                            title: "Notifications",
                            subtitle: "Manage your notification preferences",
                            color: const Color(0xFFFF9800),
                            onTap: () => _showNotificationSettings(context),
                          ),
                          _buildDivider(),
                          _buildSettingsItem(
                            icon: Icons.language_outlined,
                            title: "Language & Region",
                            subtitle: "App language and regional settings",
                            color: const Color(0xFF2196F3),
                            onTap: () => _showLanguageSettings(context),
                          ),
                          _buildDivider(),
                          _buildSettingsItem(
                            icon: Icons.dark_mode_outlined,
                            title: "Appearance",
                            subtitle: "Theme and display preferences",
                            color: const Color(0xFF607D8B),
                            onTap: () => _showAppearanceSettings(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section Support
                    _buildModernSectionHeader(
                      "Support & Information",
                      "Get help and learn more about the app",
                      Icons.help_outline,
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.help_outline,
                            title: "Help & Support",
                            subtitle: "Get assistance and find answers",
                            color: const Color(0xFF2196F3),
                            onTap: () => _showHelpSupport(context),
                          ),
                          _buildDivider(),
                          _buildSettingsItem(
                            icon: Icons.info_outline,
                            title: "About Timeless",
                            subtitle: "Version info and legal information",
                            color: const Color(0xFF607D8B),
                            onTap: () => _showAboutApp(context),
                          ),
                          _buildDivider(),
                          _buildSettingsItem(
                            icon: Icons.star_outline,
                            title: "Rate App",
                            subtitle: "Share your feedback with us",
                            color: const Color(0xFFFF8C00),
                            onTap: () => _showRateApp(context),
                          ),
                          _buildDivider(),
                          _buildSettingsItem(
                            icon: Icons.logout,
                            title: "Sign out",
                            subtitle: "Sign out of your account safely",
                            color: const Color(0xFF0D47A1),
                            onTap: () => _showLogoutConfirmation(context, controller),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section Danger Zone
                    _buildSectionHeader(
                      "Danger Zone",
                      "Irreversible account actions",
                      Icons.warning_outlined,
                      isWarning: true,
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        // ignore: deprecated_member_use
                        border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: const Color(0xFFFF8C00).withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.delete_outline,
                            title: "Delete account",
                            subtitle: "Permanently delete your account and all data",
                            color: const Color(0xFFFF8C00),
                            onTap: () => _showDeleteAccount(context),
                            isDangerous: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  settingModalBottomSheet(context) async {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            height: 265,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
              ),
              border: Border.all(color: AppTheme.buttonBorderColor, width: 2.0),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(
                  Icons.logout,
                  color: ColorRes.starColor,
                  size: 48,
                ),
                const SizedBox(height: 20),
                Text(
                  "Are you sure want to logout?",
                  style: appTextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      // ignore: deprecated_member_use
                      color: ColorRes.black.withOpacity(0.8)),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 50,
                          width: 160,
                          decoration: BoxDecoration(
                              color: ColorRes.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border:
                                  Border.all(color: ColorRes.containerColor)),
                          child: Center(
                              child: Text(
                            "Cancel",
                            style: appTextStyle(
                              color: ColorRes.containerColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        final GoogleSignIn googleSignIn = GoogleSignIn();
                        if (await googleSignIn.isSignedIn()) {
                          await googleSignIn.signOut();
                        }
                        PreferencesService.clear();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LookingForScreen(),
                            ),
                            (route) => false);
                      },
                      child: Container(
                        height: 50,
                        width: 160,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                            ColorRes.gradientColor,
                            ColorRes.containerColor,
                          ]),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            "Yes, Logout",
                            style: appTextStyle(
                              color: ColorRes.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  void _showLogoutConfirmation(BuildContext context, DashBoardController dashController) async {
    final profileCtrl = profileController;
    
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF0D47A1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.logout_rounded, color: const Color(0xFF0D47A1), size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: appTextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: ColorRes.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to log out?',
              style: appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF0D47A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                // ignore: deprecated_member_use
                border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: const Color(0xFF0D47A1), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will need to sign back in to access your account',
                      style: appTextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            Obx(() => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF000647),
                    child: Text(
                      profileCtrl.getInitials(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileCtrl.fullName.value.isEmpty ? 'User' : profileCtrl.fullName.value,
                          style: appTextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          profileCtrl.email.value,
                          style: appTextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Cancel',
              style: appTextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Logout',
                  style: appTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performLogout(dashController);
    }
  }
  
  Future<void> _performLogout(DashBoardController dashController) async {
    try {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF000647)),
              const SizedBox(height: 16),
              Text(
                'Signing out...',
                style: appTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we sign you out safely',
                style: appTextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
      
      dashController.currentTab = 0;
      dashController.update(["bottom_bar"]);

      await AuthService.signOut();
      
      profileController.clearProfileData();
      
      await _clearAllPreferences();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      Get.back();
      
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline, color: Colors.green[600], size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Logout Successful!',
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for using Timeless.\nSee you soon!',
                style: appTextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF000647).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', height: 20),
                    const SizedBox(width: 8),
                    Text(
                      'TIMELESS',
                      style: appTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000647),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000647),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: Text(
                'Continue to Welcome Screen',
                style: appTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        "Logout Error",
        "An error occurred during logout: $e",
        backgroundColor: const Color(0xFFFF8C00),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _clearAllPreferences() async {
    final keysToRemove = [
      PrefKeys.password,
      PrefKeys.rememberMe,
      PrefKeys.registerToken,
      PrefKeys.userId,
      PrefKeys.country,
      PrefKeys.email,
      PrefKeys.totalPost,
      PrefKeys.phoneNumber,
      PrefKeys.city,
      PrefKeys.state,
      PrefKeys.fullName,
      PrefKeys.rol,
    ];

    for (String key in keysToRemove) {
      PreferencesService.setValue(key, "");
    }
  }

  void _showEditProfile(BuildContext context) {
    final controller = profileController;
    
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.edit, color: const Color(0xFF000647), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "Edit profile",
                    style: appTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorRes.black,
                    ),
                  ),
                ],
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF000647)),
                      title: Text("Edit name", style: appTextStyle(fontSize: 15, color: ColorRes.black)),
                      subtitle: Obx(() => Text(
                        controller.fullName.value.isEmpty ? 'No name set' : controller.fullName.value,
                        style: appTextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.back();
                        _showEditNameDialog(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    
                    ListTile(
                      leading: const Icon(Icons.email, color: Color(0xFF000647)),
                      title: Text("Edit email", style: appTextStyle(fontSize: 15, color: ColorRes.black)),
                      subtitle: Obx(() => Text(
                        controller.email.value.isEmpty ? 'No email set' : controller.email.value,
                        style: appTextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.back();
                        _showEditEmailDialog(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    
                    ListTile(
                      leading: const Icon(Icons.phone, color: Color(0xFF000647)),
                      title: Text("Edit phone", style: appTextStyle(fontSize: 15, color: ColorRes.black)),
                      subtitle: Obx(() => Text(
                        controller.phoneNumber.value.isEmpty ? 'No phone set' : controller.phoneNumber.value,
                        style: appTextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.back();
                        _showEditPhoneDialog(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showChangePassword(BuildContext context) {
    final controller = profileController;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 80),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.lock_reset, color: const Color(0xFF000647), size: 24),
                const SizedBox(width: 8),
                Text(
                  "Change password",
                  style: appTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF0D47A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                // ignore: deprecated_member_use
                border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.email_outlined, color: const Color(0xFF2196F3), size: 32),
                  const SizedBox(height: 12),
                  Text(
                    "Password Reset Email",
                    style: appTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF000647),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    "We'll send instructions to:\n${controller.email.value}",
                    textAlign: TextAlign.center,
                    style: appTextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Text(
                      "Cancel",
                      style: appTextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _sendPasswordResetEmail();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Text(
                      "Send Instructions",
                      style: appTextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    final controller = profileController;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: const Color(0xFFFF8C00), size: 28),
            const SizedBox(width: 8),
            Text(
              'Delete Account',
              style: appTextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: const Color(0xFFFF8C00),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFFFF8C00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                // ignore: deprecated_member_use
                border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: const Color(0xFFFF8C00), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action is irreversible!',
                      style: appTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF8C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The following data will be permanently deleted:',
              style: appTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildDeleteItem('• Your profile information'),
            _buildDeleteItem('• Job applications history'),
            _buildDeleteItem('• Saved jobs and preferences'),
            _buildDeleteItem('• All account data and settings'),
            const SizedBox(height: 12),
            Obx(() => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Account: ${controller.email.value}',
                style: appTextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: appTextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _confirmDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              'Continue to Delete',
              style: appTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: appTextStyle(
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = profileController;
    final TextEditingController nameController = TextEditingController();
    nameController.text = controller.fullName.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.person, color: const Color(0xFF000647), size: 24),
            const SizedBox(width: 8),
            Text("Edit name", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Text(
              "This will update your name across the entire application",
              style: appTextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: appTextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != controller.fullName.value) {
                try {
                  controller.isLoading.value = true;
                  
                  controller.fullNameController.text = newName;
                  
                  await controller.onTapSubmit();
                  
                  Get.back();
                  
                  Get.snackbar(
                    "Success",
                    "Name updated successfully across the app!",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update name: $e",
                    backgroundColor: const Color(0xFFFF8C00),
                    colorText: Colors.white,
                  );
                } finally {
                  controller.isLoading.value = false;
                }
              } else if (newName.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Name cannot be empty",
                  backgroundColor: const Color(0xFFFF8C00),
                  colorText: Colors.white,
                );
              } else {
                Get.back(); // Pas de changement, fermer le dialogue
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: controller.isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Save", style: appTextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ],
      ),
    );
  }

  void _showEditEmailDialog(BuildContext context) {
    final controller = profileController;
    final TextEditingController emailController = TextEditingController();
    emailController.text = controller.email.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.email, color: const Color(0xFF000647), size: 24),
            const SizedBox(width: 8),
            Text("Edit email", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email address",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Text(
              "This will update your email across the entire application",
              style: appTextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: appTextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : () async {
              final newEmail = emailController.text.trim();
              if (newEmail.isNotEmpty && newEmail.contains('@') && newEmail != controller.email.value) {
                try {
                  controller.isLoading.value = true;
                  
                  controller.emailController.text = newEmail;
                  
                  await controller.onTapSubmit();
                  
                  Get.back();
                  
                  Get.snackbar(
                    "Success",
                    "Email updated successfully across the app!",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update email: $e",
                    backgroundColor: const Color(0xFFFF8C00),
                    colorText: Colors.white,
                  );
                } finally {
                  controller.isLoading.value = false;
                }
              } else if (newEmail.isEmpty || !newEmail.contains('@')) {
                Get.snackbar(
                  "Error",
                  "Please enter a valid email address",
                  backgroundColor: const Color(0xFFFF8C00),
                  colorText: Colors.white,
                );
              } else {
                Get.back(); // Pas de changement, fermer le dialogue
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: controller.isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Save", style: appTextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ],
      ),
    );
  }
  
  void _showEditPhoneDialog(BuildContext context) {
    final controller = profileController;
    final TextEditingController phoneController = TextEditingController();
    phoneController.text = controller.phoneNumber.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.phone, color: const Color(0xFF000647), size: 24),
            const SizedBox(width: 8),
            Text("Edit phone", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "Phone number",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Text(
              "This will update your phone number across the entire application",
              style: appTextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: appTextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : () async {
              final newPhone = phoneController.text.trim();
              if (newPhone != controller.phoneNumber.value) {
                try {
                  controller.isLoading.value = true;
                  
                  controller.phoneController.text = newPhone;
                  
                  await controller.onTapSubmit();
                  
                  Get.back();
                  
                  Get.snackbar(
                    "Success",
                    "Phone number updated successfully across the app!",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update phone number: $e",
                    backgroundColor: const Color(0xFFFF8C00),
                    colorText: Colors.white,
                  );
                } finally {
                  controller.isLoading.value = false;
                }
              } else {
                Get.back(); // Pas de changement, fermer le dialogue
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: controller.isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Save", style: appTextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ],
      ),
    );
  }
  

  void _sendPasswordResetEmail() async {
    final controller = profileController;
    final email = controller.email.value;
    
    if (email.isNotEmpty) {
      try {
        final success = await AuthService.resetPassword(email);
        
        if (success) {
          Get.dialog(
            AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mark_email_read, color: Colors.green[600], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "Email Sent!",
                    style: appTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "A password reset link has been sent to:",
                    style: appTextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      email,
                      style: appTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000647),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Please check your inbox and follow the instructions to reset your password.",
                    style: appTextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000647),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Got it!",
                    style: appTextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } catch (error) {
        Get.snackbar(
          "Error",
          "Failed to send password reset email: $error",
          backgroundColor: const Color(0xFFFF8C00),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } else {
      Get.snackbar(
        "Error",
        "No email address found in your profile",
        backgroundColor: const Color(0xFFFF8C00),
        colorText: Colors.white,
      );
    }
  }

  void _confirmDeleteAccount() async {
    final controller = profileController;
    final TextEditingController confirmController = TextEditingController();
    final RxBool canDelete = false.obs;
    
    confirmController.addListener(() {
      canDelete.value = confirmController.text.trim().toUpperCase() == 'DELETE';
    });
    
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.dangerous, color: const Color(0xFFFF8C00), size: 28),
            const SizedBox(width: 8),
            Text(
              'Final Confirmation',
              style: appTextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFFFF8C00),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFFFF8C00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                // ignore: deprecated_member_use
                border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.5), width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded, color: const Color(0xFFFF8C00), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'LAST WARNING',
                    style: appTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF8C00),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This action cannot be undone!',
                    style: appTextStyle(
                      fontSize: 12,
                      color: const Color(0xFFFF8C00),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You are about to permanently delete:',
              style: appTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account: ${controller.email.value}', style: appTextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('Name: ${controller.fullName.value}', style: appTextStyle(fontSize: 12)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Text(
              'Type "DELETE" to confirm (case sensitive):',
              style: appTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFFFF8C00), width: 2),
                ),
                hintText: "Type DELETE here",
                hintStyle: appTextStyle(color: Colors.grey[500]),
              ),
              style: appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF8C00),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: appTextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: canDelete.value ? () {
              Get.back(result: true);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canDelete.value ? const Color(0xFFFF8C00) : Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete Forever',
              style: appTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          )),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _performAccountDeletion();
    }
  }
  
  // Fonction pour effectuer la suppression du compte
  Future<void> _performAccountDeletion() async {
    final controller = profileController;
    
    try {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF000647)),
              const SizedBox(height: 16),
              Text(
                'Deleting account...',
                style: appTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we remove your data',
                style: appTextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
      
      await controller.clearProfileData();
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
      
      await GoogleAuthService.signOut();
      
      await _clearAllPreferences();
      
      Get.back();
      
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green[600], size: 48),
              const SizedBox(height: 16),
              Text(
                'Account Deleted',
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your account has been permanently deleted. Thank you for using Timeless.',
                style: appTextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000647),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continue',
                style: appTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        "Deletion Error",
        "Failed to delete account: $e\n\nPlease contact support for assistance.",
        backgroundColor: const Color(0xFFFF8C00),
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    }
  }

  // Widget moderne pour les en-têtes de section avec fond noir
  Widget _buildModernSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF000647),
            const Color(0xFF000000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF000647).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les en-têtes de section
  Widget _buildSectionHeader(String title, String subtitle, IconData icon, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWarning
              // ignore: deprecated_member_use
              ? [const Color(0xFFFF8C00).withOpacity(0.1), const Color(0xFFFF8C00).withOpacity(0.2)]
              // ignore: deprecated_member_use
              : [const Color(0xFF0D47A1).withOpacity(0.1), const Color(0xFF0D47A1).withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // ignore: deprecated_member_use
          color: isWarning ? const Color(0xFFFF8C00).withOpacity(0.3) : const Color(0xFF0D47A1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: isWarning ? const Color(0xFFFF8C00).withOpacity(0.3) : const Color(0xFF0D47A1).withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isWarning ? const Color(0xFFFF8C00) : const Color(0xFF000647),
              size: 20,
            ),
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
                    color: isWarning ? const Color(0xFFFF8C00) : const Color(0xFF000647),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isWarning ? const Color(0xFFFF8C00) : const Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget moderne pour les éléments de settings
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDangerous = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // ignore: deprecated_member_use
              color.withOpacity(0.15),
              // ignore: deprecated_member_use
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDangerous ? color : const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFF6B7280),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }

  // Widget pour les dividers
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
        thickness: 0.5,
      ),
    );
  }

  // Nouvelles méthodes pour les fonctionnalités ajoutées
  void _showNotificationSettings(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 80),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_outlined, color: const Color(0xFFFF9800), size: 24),
                const SizedBox(width: 8),
                Text(
                  "Notification Settings",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildNotificationToggle("Job Alerts", "New job opportunities matching your profile", true),
            _buildNotificationToggle("Application Updates", "Status changes for your applications", true),
            _buildNotificationToggle("Messages", "New messages from employers", true),
            _buildNotificationToggle("Marketing", "Product updates and promotional content", false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000647),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Save Changes",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(String title, String subtitle, bool initialValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
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
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: (value) {},
            // ignore: deprecated_member_use
            activeColor: const Color(0xFF000647),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 80),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language_outlined, color: const Color(0xFF000647), size: 20),
                const SizedBox(width: 8),
                Text(
                  "Language & Region",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLanguageOption("English", "English (US)", true),
            _buildLanguageOption("Français", "French", false),
            _buildLanguageOption("Español", "Spanish", false),
            _buildLanguageOption("العربية", "Arabic", false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Apply Language",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String subtitle, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: isSelected ? const Color(0xFF9C27B0).withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.language,
            color: isSelected ? const Color(0xFF9C27B0) : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          language,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF9C27B0) : const Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF9C27B0)) : null,
        onTap: () {},
      ),
    );
  }

  void _showAppearanceSettings(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 80),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dark_mode_outlined, color: const Color(0xFF607D8B), size: 24),
                const SizedBox(width: 8),
                Text(
                  "Appearance Settings",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Theme Preference",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            _buildThemeOption("Light", "Clean and bright interface", Icons.light_mode, true),
            _buildThemeOption("Dark", "Easy on the eyes in low light", Icons.dark_mode, false),
            _buildThemeOption("System", "Follow device settings", Icons.settings_system_daydream, false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF607D8B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Apply Theme",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String title, String subtitle, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: isSelected ? const Color(0xFF607D8B).withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF607D8B) : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF607D8B) : const Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF607D8B)) : null,
        onTap: () {},
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 80),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: const Color(0xFF2196F3), size: 24),
                const SizedBox(width: 8),
                Text(
                  "Help & Support",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHelpOption("Frequently Asked Questions", Icons.quiz_outlined),
            _buildHelpOption("Contact Support", Icons.support_agent),
            _buildHelpOption("Report a Bug", Icons.bug_report_outlined),
            _buildHelpOption("Feature Request", Icons.lightbulb_outline),
            _buildHelpOption("Privacy Policy", Icons.privacy_tip_outlined),
            _buildHelpOption("Terms of Service", Icons.description_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Icon(icon, color: const Color(0xFF2196F3)),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
    );
  }

  void _showAboutApp(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF000647), const Color(0xFF0D47A1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'About Timeless',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF000647).withOpacity(0.1), const Color(0xFF0D47A1).withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.work, size: 32, color: Color(0xFF000647)),
                    const SizedBox(height: 8),
                    Text(
                      'Timeless',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000647),
                      ),
                    ),
                    Text(
                      'Version 1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connect talent with opportunity. Timeless makes job searching and hiring simple, efficient, and effective.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildAboutItem('Developed by', 'Timeless Team'),
            _buildAboutItem('Build', '1.0.0 (100)'),
            _buildAboutItem('Platform', 'Flutter'),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '© 2024 Timeless. All rights reserved.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

    void _showRateApp(BuildContext context) {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star, color: Color(0xFFFFC107), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Rate Timeless',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Love using Timeless?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your feedback helps us improve and reach more job seekers!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(Icons.star, color: Color(0xFFFFC107), size: 24),
                )),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Maybe Later',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Thank You!',
                  'Redirecting to App Store...',
                  backgroundColor: const Color(0xFFFFC107),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Rate Now',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
