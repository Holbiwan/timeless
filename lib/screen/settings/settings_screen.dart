import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/looking_for_screen/looking_for_screen.dart';
import 'package:timeless/screen/profile/profile_controller.dart';
import 'package:timeless/screen/settings/widgets/settings_menu_item.dart';
import 'package:timeless/screen/settings/widgets/settings_divider.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/google_auth_service.dart';
import 'package:timeless/services/auth_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
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
            // Header moderne
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
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
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1F2937),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Settings",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
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
                    Text(
                      "Account",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Profile settings card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                            subtitle: "Update your password",
                            color: const Color(0xFF2196F3),
                            onTap: () => _showChangePassword(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      "Danger Zone",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dangerous actions card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red[100]!, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.delete_outline,
                            title: "Delete account",
                            subtitle: "Permanently delete your account",
                            color: Colors.red[600]!,
                            onTap: () => _showDeleteAccount(context),
                            isDangerous: true,
                          ),
                          _buildDivider(),
                          _buildSettingsItem(
                            icon: Icons.logout,
                            title: "Sign out",
                            subtitle: "Sign out of your account",
                            color: const Color(0xFF0D47A1),
                            onTap: () => _showLogoutConfirmation(context, controller),
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
                color: Colors.blue[100],
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
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
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

      await authService.signOut();
      
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
        backgroundColor: Colors.red,
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
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!),
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
                      color: Colors.blue[800],
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
            Icon(Icons.warning_amber_rounded, color: Colors.red[600], size: 28),
            const SizedBox(width: 8),
            Text(
              'Delete Account',
              style: appTextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.red[600],
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
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action is irreversible!',
                      style: appTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
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
              backgroundColor: Colors.red[600],
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
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } finally {
                  controller.isLoading.value = false;
                }
              } else if (newName.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Name cannot be empty",
                  backgroundColor: Colors.red,
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
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } finally {
                  controller.isLoading.value = false;
                }
              } else if (newEmail.isEmpty || !newEmail.contains('@')) {
                Get.snackbar(
                  "Error",
                  "Please enter a valid email address",
                  backgroundColor: Colors.red,
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
                    backgroundColor: Colors.red,
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
        final success = await authService.resetPassword(email);
        
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
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } else {
      Get.snackbar(
        "Error",
        "No email address found in your profile",
        backgroundColor: Colors.red,
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
            Icon(Icons.dangerous, color: Colors.red[700], size: 28),
            const SizedBox(width: 8),
            Text(
              'Final Confirmation',
              style: appTextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.red[700],
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
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!, width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'LAST WARNING',
                    style: appTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This action cannot be undone!',
                    style: appTextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
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
                  borderSide: BorderSide(color: Colors.red[600]!, width: 2),
                ),
                hintText: "Type DELETE here",
                hintStyle: appTextStyle(color: Colors.grey[500]),
              ),
              style: appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
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
              backgroundColor: canDelete.value ? Colors.red[700] : Colors.grey[400],
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
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    }
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
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
          fontSize: 14,
          color: const Color(0xFF6B7280),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
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
      ),
    );
  }
}
