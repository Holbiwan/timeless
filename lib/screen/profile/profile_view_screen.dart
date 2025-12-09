import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/screen/manager_section/Profile/edit_profile/edit_profile_screen.dart';
import 'package:timeless/screen/profile/job_preferences_screen.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/translation_service.dart';
import 'package:timeless/utils/app_res.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000647),
      appBar: AppBar(
        title: Text(
          Get.find<TranslationService>().getText('my_profile'),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF000647), width: 2.0),
          ),
          child: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Get.offAllNamed(AppRes.dashBoardScreen);
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF000647), width: 2.0),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black),
              onPressed: () async {
                await Get.to(() => EditProfileScreen());
                // Rafraîchir la page après retour de l'édition
                setState(() {});
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 4),
            
            // Personal Information Section
            _buildSection(
              title: ' ${Get.find<TranslationService>().getText('personal_information')}',
              children: [
                _buildInfoRow(Get.find<TranslationService>().getText('full_name'), PreferencesService.getString(PrefKeys.fullName)),
                _buildInfoRow(Get.find<TranslationService>().getText('email'), PreferencesService.getString(PrefKeys.email)),
                _buildInfoRow(Get.find<TranslationService>().getText('phone'), PreferencesService.getString(PrefKeys.phoneNumber)),
                _buildInfoRow(Get.find<TranslationService>().getText('date_of_birth'), PreferencesService.getString(PrefKeys.dateOfBirth)),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Location Section  
            _buildSection(
              title: Get.find<TranslationService>().getText('location'),
              children: [
                _buildInfoRow(Get.find<TranslationService>().getText('city'), PreferencesService.getString(PrefKeys.city)),
                _buildInfoRow(Get.find<TranslationService>().getText('country'), PreferencesService.getString(PrefKeys.country)),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Professional Information
            _buildSection(
              title: Get.find<TranslationService>().getText('professional_information'),
              children: [
                _buildInfoRow(Get.find<TranslationService>().getText('current_occupation'), PreferencesService.getString(PrefKeys.occupation)),
                _buildInfoRow(Get.find<TranslationService>().getText('job_position'), PreferencesService.getString(PrefKeys.jobPosition)),
                _buildInfoRow(Get.find<TranslationService>().getText('experience_level'), PreferencesService.getString(PrefKeys.experienceLevel)),
                _buildInfoRow(Get.find<TranslationService>().getText('bio'), PreferencesService.getString(PrefKeys.bio), isMultiline: true),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Skills Section
            _buildSection(
              title: Get.find<TranslationService>().getText('skills'),
              children: [
                _buildInfoRow(Get.find<TranslationService>().getText('skills'), PreferencesService.getString(PrefKeys.skillsList), isMultiline: true),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Salary Expectations Section  
            _buildSection(
              title: Get.find<TranslationService>().getText('salary_expectations'),
              children: [
                _buildInfoRow(Get.find<TranslationService>().getText('salary_range_min'), PreferencesService.getString(PrefKeys.salaryRangeMin)),
                _buildInfoRow(Get.find<TranslationService>().getText('salary_range_max'), PreferencesService.getString(PrefKeys.salaryRangeMax)),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Get.to(() => EditProfileScreen());
                      // Rafraîchir la page après retour de l'édition  
                      setState(() {});
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(Get.find<TranslationService>().getText('edit_profile')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFF000647), width: 2.0),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => const JobPreferencesScreen()),
                    icon: const Icon(Icons.psychology_outlined, size: 16),
                    label: Text(Get.find<TranslationService>().getText('job_preferences')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFF000647), width: 2.0),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 3),
            
            // Clear Profile Data Button (Debug/Development only)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearProfileData,
                icon: const Icon(Icons.clear_all, size: 16),
                label: Text(Get.find<TranslationService>().getText('clear_profile_data')),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Color(0xFF000647), width: 2.0),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 37,
            backgroundColor: Colors.white,
            child: _buildProfileImage(),
          ),
          const SizedBox(height: 12),
          Text(
            PreferencesService.getString(PrefKeys.fullName).isNotEmpty 
                ? PreferencesService.getString(PrefKeys.fullName)
                : Get.find<TranslationService>().getText('your_name'),
            style: appTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            PreferencesService.getString(PrefKeys.occupation).isNotEmpty
                ? PreferencesService.getString(PrefKeys.occupation)
                : '',
            style: appTextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: appTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColorRes.black,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: appTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ColorRes.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : Get.find<TranslationService>().getText('not_specified'),
              style: appTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: value.isNotEmpty ? ColorRes.black : ColorRes.grey,
              ),
              maxLines: isMultiline ? null : 2,
              overflow: isMultiline ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileImage() {
    final String imagePath = PreferencesService.getString('profile_image_path');
    
    if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      // Afficher la photo de profil
      return CircleAvatar(
        radius: 34,
        backgroundImage: FileImage(File(imagePath)),
        backgroundColor: Colors.transparent,
      );
    } else {
      // Afficher les initiales si pas de photo
      return CircleAvatar(
        radius: 34,
        backgroundColor: Colors.black,
        child: Text(
          _getInitials(),
          style: appTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      );
    }
  }

  String _getInitials() {
    final fullName = PreferencesService.getString(PrefKeys.fullName);
    if (fullName.isEmpty) return 'U';
    
    final names = fullName.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  
  void _clearProfileData() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(color: AppTheme.buttonBorderColor, width: 2.0),
        ),
        title: Text(
          'Clear Profile Data',
          style: TextStyle(color: Colors.black),
        ),
        content: Text(
          'This will clear all your profile and preference data. Are you sure?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: BorderSide(color: AppTheme.buttonBorderColor, width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
              ),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              
              // Show loading
              Get.dialog(
                AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    side: BorderSide(color: AppTheme.buttonBorderColor, width: 2.0),
                  ),
                  content: Row(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.buttonBorderColor),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Clearing data...',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                barrierDismissible: false,
              );
              
              // Clear all profile related preferences
              await Future.wait([
                PreferencesService.setValue(PrefKeys.fullName, ''),
                PreferencesService.setValue(PrefKeys.email, ''),
                PreferencesService.setValue(PrefKeys.phoneNumber, ''),
                PreferencesService.setValue(PrefKeys.dateOfBirth, ''),
                PreferencesService.setValue(PrefKeys.city, ''),
                PreferencesService.setValue(PrefKeys.state, ''),
                PreferencesService.setValue(PrefKeys.country, ''),
                PreferencesService.setValue(PrefKeys.occupation, ''),
                PreferencesService.setValue(PrefKeys.jobPosition, ''),
                PreferencesService.setValue(PrefKeys.bio, ''),
                PreferencesService.setValue(PrefKeys.address, ''),
                PreferencesService.setValue(PrefKeys.profileImageUrl, ''),
                // Clear preferences
                PreferencesService.setValue(PrefKeys.experienceLevel, ''),
                PreferencesService.setValue(PrefKeys.skillsList, ''),
                PreferencesService.setValue(PrefKeys.salaryRangeMin, ''),
                PreferencesService.setValue(PrefKeys.salaryRangeMax, ''),
                PreferencesService.setValue(PrefKeys.jobTypes, ''),
                PreferencesService.setValue(PrefKeys.industryPreferences, ''),
                PreferencesService.setValue(PrefKeys.companyTypes, ''),
                PreferencesService.setValue(PrefKeys.maxCommuteDistance, ''),
                PreferencesService.setValue(PrefKeys.workLocationPreference, ''),
              ]);
              
              Get.back(); // Close loading dialog
              
              AppTheme.showStandardSnackBar(
                title: '✅ Profile Cleared',
                message: 'All profile and preference data has been cleared. You can now enter your own information.',
                isSuccess: true,
              );
              
              // Force rebuild
              setState(() {});
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: BorderSide(color: AppTheme.buttonBorderColor, width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
              ),
            ),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}