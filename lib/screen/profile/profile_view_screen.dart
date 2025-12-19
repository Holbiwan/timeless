import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/screen/manager_section/Profile/edit_profile/edit_profile_screen.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/screen/profile/profile_controller.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000647),
      appBar: AppBar(
        title: Text(
          Get.find<UnifiedTranslationService>().getText('my_profile'),
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
                await controller.refreshProfile();
                setState(() {});
              },
            ),
          ),
        ],
      ),
      body: Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(),
                const SizedBox(height: 4),
                
                // Personal Information Section
                _buildSection(
                  title: 'Informations Personnelles',
                  children: [
                    _buildInfoRow('Nom Complet', controller.displayName),
                    _buildInfoRow('Email', controller.displayEmail),
                    _buildInfoRow('Téléphone', controller.displayPhone),
                    _buildInfoRow('Date de Naissance', controller.displayDateOfBirth),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Location Section  
                _buildSection(
                  title: 'Localisation',
                  children: [
                    _buildInfoRow('Ville', controller.displayCity),
                    _buildInfoRow('Pays', controller.displayCountry),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Professional Information
                _buildSection(
                  title: 'Informations Professionnelles',
                  children: [
                    _buildInfoRow('Profession Actuelle', controller.displayOccupation),
                    _buildInfoRow('Poste', controller.displayJobPosition),
                    _buildInfoRow('Niveau d\'expérience', controller.displayExperience),
                    _buildInfoRow('Biographie', controller.displayBio, isMultiline: true),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Skills Section
                _buildSection(
                  title: 'Skills',
                  children: [
                    _buildInfoRow('Skills', controller.displaySkills, isMultiline: true),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Salary Expectations Section  
                _buildSection(
                  title: 'Salary Expectations',
                  children: [
                    _buildInfoRow('Salary Range Min', controller.displaySalaryMin),
                    _buildInfoRow('Salary Range Max', controller.displaySalaryMax),
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
                            await controller.refreshProfile();
                      setState(() {});
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(Get.find<UnifiedTranslationService>().getText('edit_profile')),
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
                // Job Preferences button removed
              ],
            ),
            
            const SizedBox(height: 3),
            
            // Clear Profile Data Button (Debug/Development only)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearProfileData,
                icon: const Icon(Icons.clear_all, size: 16),
                label: Text(Get.find<UnifiedTranslationService>().getText('clear_profile_data')),
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
      )),
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
          Obx(() => Text(
            controller.displayName,
            style: appTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )),
          const SizedBox(height: 4),
          Obx(() => Text(
            controller.displayOccupation,
            style: appTextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          )),
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
              value.isNotEmpty ? value : 'Non spécifié',
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
    return Obx(() {
      if (controller.hasProfileImage()) {
        // Afficher la photo de profil depuis Firebase
        return CircleAvatar(
          radius: 34,
          backgroundImage: NetworkImage(controller.profileImageUrl.value),
          backgroundColor: Colors.transparent,
        );
      } else {
        // Afficher les initiales si pas de photo
        return CircleAvatar(
          radius: 34,
          backgroundColor: Colors.black,
          child: Text(
            controller.getInitials(),
            style: appTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        );
      }
    });
  }

  
  void _clearProfileData() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFF000647), width: 2.0),
        ),
        title: const Text(
          'Clear Profile Data',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          'This will clear all your profile data from Firebase. Are you sure?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xFF000647), width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Color(0xFF000647), width: 2.0),
                  ),
                  content: const Row(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF000647)),
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Clearing data...',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                barrierDismissible: false,
              );
              
              // Clear Firebase data via controller
              await controller.clearProfileData();
              
              Get.back(); // Close loading dialog
              
              AppTheme.showStandardSnackBar(
                title: 'Profile Cleared',
                message: 'All profile data has been cleared from Firebase.',
                isSuccess: true,
              );
              
              // Refresh profile
              await controller.refreshProfile();
              setState(() {});
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Color(0xFF000647), width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}