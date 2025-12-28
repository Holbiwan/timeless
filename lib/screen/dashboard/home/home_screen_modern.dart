import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/dashboard/my_applications_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'dart:io';
import 'package:timeless/screen/dashboard/home/widgets/appbar.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/common/widgets/language_switcher.dart';

// ignore: must_be_immutable
class HomeScreenModern extends StatelessWidget {
  const HomeScreenModern({super.key});

  @override
  Widget build(BuildContext context) {
    final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

    return Obx(() => Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // AppBar modernisée
                homeAppBar(),
                
                // Contenu principal
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingRegular),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppTheme.spacingSmall),
                          
                          // --- SECTION: PHOTO DE PROFIL ---
                          _buildProfilePhotoSection(context, translationService, accessibilityService),
                          
                          const SizedBox(height: AppTheme.spacingLarge),

                          // --- SECTION: 

                          // Actions principales ---
                          _buildMainActions(translationService, accessibilityService),
                          
                          const SizedBox(height: AppTheme.spacingXXLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Floating Language Switcher
            const Positioned(
              top: 16,
              right: 16,
              child: LanguageSwitcher(isCompact: true),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildProfilePhotoSection(BuildContext context, UnifiedTranslationService translationService, AccessibilityService accessibilityService) {
    return StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<String?>(
          future: _getUserProfilePhoto(),
          builder: (context, snapshot) {
            final photoUrl = snapshot.data;
            
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withOpacity(0.1),
                    AppTheme.secondaryGold.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: AppTheme.shadowLight,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showPhotoOptions(context),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: AppTheme.primaryOrange.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(38),
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                              ),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingRegular),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photo de profil',
                          style: accessibilityService.getAccessibleTextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          photoUrl != null ? 'Appuyez pour modifier' : 'Appuyez pour ajouter une photo',
                          style: accessibilityService.getAccessibleTextStyle(
                            fontSize: AppTheme.fontSizeRegular,
                            color: accessibilityService.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.camera_alt,
                    color: AppTheme.primaryOrange,
                    size: 24,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      color: AppTheme.primaryOrange,
      size: 40,
    );
  }

  Future<String?> _getUserProfilePhoto() async {
    try {
      final userId = PreferencesService.getString(PrefKeys.userId);
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['profilePhotoUrl'];
      }
    } catch (e) {
      print('Error getting profile photo: $e');
    }
    return null;
  }

  Future<void> _showPhotoOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Photo de profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.photo_camera, color: AppTheme.primaryOrange),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.primaryOrange),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        await _uploadProfilePhoto(File(pickedFile.path));
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner l\'image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadProfilePhoto(File imageFile) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final userId = PreferencesService.getString(PrefKeys.userId);
      final storageRef = FirebaseStorage.instance.ref().child('profile_photos/$userId.jpg');
      
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePhotoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.back(); // Close loading dialog
      Get.snackbar(
        'Succès',
        'Photo de profil mise à jour!',
        backgroundColor: AppTheme.primaryOrange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Erreur',
        'Impossible de télécharger la photo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildMainActions(UnifiedTranslationService translationService, AccessibilityService accessibilityService) {
    return Column(
      children: [
        // Bouton principal "See Jobs" modernisé
        
        AppTheme.primaryButton(
          text: translationService.getText('see_jobs'),
          onPressed: () {
            accessibilityService.triggerHapticFeedback();
            Get.toNamed(AppRes.jobRecommendationScreen);
          },
          width: double.infinity,
        ),
        
        const SizedBox(height: AppTheme.spacingRegular),
        
        // Actions secondaires en grid
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.bookmark_outline,
                title: 'Saved Jobs',
                subtitle: 'View saved',
                onTap: () => accessibilityService.triggerHapticFeedback(),
                accessibilityService: accessibilityService,
              ),
            ),
            const SizedBox(width: AppTheme.spacingRegular),
            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics_outlined,
                title: 'Applications',
                subtitle: 'Track status',
                onTap: () {
                  accessibilityService.triggerHapticFeedback();
                  Get.to(() => const MyApplicationsScreen());
                },
                accessibilityService: accessibilityService,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AccessibilityService accessibilityService,
  }) {
    return accessibilityService.buildAccessibleWidget(
      semanticLabel: '$title. $subtitle',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: AppTheme.containerDecoration.copyWith(
          color: accessibilityService.cardBackgroundColor,
          border: Border.all(
            color: accessibilityService.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: accessibilityService.primaryColor,
              size: 28,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              title,
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: accessibilityService.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}