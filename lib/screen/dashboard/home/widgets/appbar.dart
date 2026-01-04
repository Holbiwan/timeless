import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/services/auth_service.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/screen/settings/settings_screen.dart';
import 'package:timeless/screen/accessibility/accessibility_panel.dart';
import 'package:timeless/screen/profile/profile_controller.dart';

Widget homeAppBar({VoidCallback? onRefresh}) {
  final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
  final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
  final ProfileController profileController = Get.put(ProfileController());
  
  return Obx(() {
    // Force observation of observable variables
    profileController.profileImageUrl.value; // Observe this value
    
    return Container(
    margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.black,
          Colors.black.withOpacity(0.9),
          const Color(0xFF000647),
        ],
        stops: const [0.0, 0.6, 1.0],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF000647).withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header row avec actions
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              accessibilityService.buildAccessibleWidget(
              semanticLabel: 'Back to login',
              onTap: () {
                accessibilityService.triggerHapticFeedback();
                Get.offAllNamed('/');
              },
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black, // Black icon
                  size: 20,
                ),
              ),
            ),
            
            const Spacer(),
            
            // User Menu Button
            accessibilityService.buildAccessibleWidget(
              semanticLabel: 'User menu',
              onTap: () {
                accessibilityService.triggerHapticFeedback();
                _showUserMenu();
              },
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.black, // Black icon
                  size: 20,
                ),
              ),
            ),
            ],
          ),
        ),
        
        const SizedBox(height: 2),
        
        // Profile section
        Column(
          children: [
            // Profile Image avec fonctionnalité upload
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    accessibilityService.triggerHapticFeedback();
                    profileController.onTapGallery1();
                  },
                  child: Obx(() => Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.9),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: const Color(0xFF000647).withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 15,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(43),
                        child: profileController.profileImageUrl.value.isNotEmpty
                          ? Image.network(
                              profileController.profileImageUrl.value,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF000647).withOpacity(0.1),
                                child: const Icon(
                                  Icons.person, 
                                  size: 54, 
                                  color: Color(0xFF000647),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF000647).withOpacity(0.1),
                              child: const Icon(
                                Icons.person, 
                                size: 48, 
                                color: Color(0xFF000647),
                              ),
                            ),
                      ),
                    ),
                  )),
                ),
                // Camera icon pour upload
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      accessibilityService.triggerHapticFeedback();
                      _showPhotoUploadOptions(profileController);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF000647),
                            const Color(0xFF000647).withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ],
            ),
              
            const SizedBox(height: 6),
            
            // Welcome message avec gradient
            StreamBuilder(
              stream: AuthService.instance.getCurrentUserDataStream(),
              builder: (context, snapshot) {
                String displayName = 'candidate';
                
                if (snapshot.hasData && snapshot.data != null) {
                  displayName = snapshot.data!.fullName;
                } else {
                  final cachedName = PreferencesService.getString(PrefKeys.fullName);
                  if (cachedName.isNotEmpty) {
                    displayName = cachedName;
                  }
                }
                
                return Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '${translationService.getText('welcome')} ',
                        style: accessibilityService.getAccessibleTextStyle(
                          fontSize: 17,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: displayName,
                            style: accessibilityService.getAccessibleTextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        accessibilityService.triggerHapticFeedback();
                        if (onRefresh != null) onRefresh();
                        Get.snackbar(
                          'Refreshing',
                          'Updating dashboard data...',
                          backgroundColor: Colors.white,
                          colorText: const Color(0xFF000647),
                          duration: const Duration(seconds: 1),
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(10),
                          borderRadius: 10,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Refresh',
                              style: accessibilityService.getAccessibleTextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    ),
  );});
}

extension on Object? {
  String get fullName {
    if (this == null) return '';
    try {
      final dynamic obj = this;
      final name = obj.fullName;
      return name != null ? name.toString() : '';
    } catch (e) {
      return '';
    }
  }
}

void _showPhotoUploadOptions(ProfileController profileController) {
  final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
  
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 80),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
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
            'Upload Profile Photo',
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF000647),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you want to upload your photo',
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Options
          _buildPhotoOption(
            Icons.camera_alt,
            'Take Photo',
            'Use your camera to take a new photo',
            () {
              Get.back();
              profileController.onTapImage();
            },
          ),
          const SizedBox(height: 16),
          _buildPhotoOption(
            Icons.photo_library,
            'Choose from Gallery',
            'Select an existing photo from your gallery',
            () {
              Get.back();
              profileController.onTapGallery1();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

Widget _buildPhotoOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
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
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF000647).withOpacity(0.1), width: 1),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF000647),
                  const Color(0xFF000647).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: accessibilityService.getAccessibleTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000647),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: accessibilityService.getAccessibleTextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: const Color(0xFF000647).withOpacity(0.3),
            size: 16,
          ),
        ],
      ),
    ),
  );
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
              fontSize: 12,
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