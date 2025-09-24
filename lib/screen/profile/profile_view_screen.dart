import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/screen/profile/edit_profile_user/edit_profile_user_screen.dart';
import 'package:timeless/screen/profile/job_preferences_screen.dart';
import 'dart:convert';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: ColorRes.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Get.to(() => EditProfileUserScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 30),
            
            // Personal Information Section
            _buildSection(
              title: '👤 Personal Information',
              children: [
                _buildInfoRow('Full Name', PrefService.getString(PrefKeys.fullName)),
                _buildInfoRow('Email', PrefService.getString(PrefKeys.email)),
                _buildInfoRow('Phone', PrefService.getString(PrefKeys.phoneNumber)),
                _buildInfoRow('Date of Birth', PrefService.getString(PrefKeys.dateOfBirth)),
              ],
            ),
            
            const SizedBox(height: 25),
            
            // Location Section  
            _buildSection(
              title: '📍 Location',
              children: [
                _buildInfoRow('City', PrefService.getString(PrefKeys.city)),
                _buildInfoRow('State', PrefService.getString(PrefKeys.state)),
                _buildInfoRow('Country', PrefService.getString(PrefKeys.country)),
              ],
            ),
            
            const SizedBox(height: 25),
            
            // Professional Information
            _buildSection(
              title: '💼 Professional Information',
              children: [
                _buildInfoRow('Current Occupation', PrefService.getString(PrefKeys.occupation)),
                _buildInfoRow('Job Position', PrefService.getString(PrefKeys.jobPosition)),
                _buildInfoRow('Bio', PrefService.getString(PrefKeys.bio), isMultiline: true),
              ],
            ),
            
            const SizedBox(height: 25),
            
            // Matching Preferences (Future enhancement)
            _buildSection(
              title: '🎯 Job Matching Preferences',
              children: [
                _buildInfoRow('Experience Level', _getExperienceLevel()),
                _buildInfoRow('Preferred Salary Range', _getSalaryRange()),
                _buildInfoRow('Job Types', _getJobTypes()),
                _buildInfoRow('Skills', _getSkills()),
                const SizedBox(height: 10),
                _buildEmptyState(),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => EditProfileUserScreen()),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorRes.containerColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                    icon: const Icon(Icons.psychology_outlined, size: 18),
                    label: const Text('Job Preferences'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // Clear Profile Data Button (Debug/Development only)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearProfileData,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear Profile Data (Reset)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: ColorRes.containerColor.withOpacity(0.2),
            child: Text(
              _getInitials(),
              style: appTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorRes.containerColor,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            PrefService.getString(PrefKeys.fullName).isNotEmpty 
                ? PrefService.getString(PrefKeys.fullName)
                : 'Your Name',
            style: appTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorRes.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            PrefService.getString(PrefKeys.occupation).isNotEmpty
                ? PrefService.getString(PrefKeys.occupation)
                : 'Add your profession',
            style: appTextStyle(
              fontSize: 14,
              color: ColorRes.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorRes.black,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: appTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ColorRes.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: appTextStyle(
                fontSize: 13,
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorRes.containerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorRes.containerColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 40,
            color: ColorRes.containerColor,
          ),
          const SizedBox(height: 10),
          Text(
            'Complete your profile for better job matching!',
            textAlign: TextAlign.center,
            style: appTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorRes.containerColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Add your preferences to help our algorithm find the perfect jobs for you.',
            textAlign: TextAlign.center,
            style: appTextStyle(
              fontSize: 12,
              color: ColorRes.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    final fullName = PrefService.getString(PrefKeys.fullName);
    if (fullName.isEmpty) return 'U';
    
    final names = fullName.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  // Real data methods
  String _getExperienceLevel() {
    final level = PrefService.getString(PrefKeys.experienceLevel);
    return level.isNotEmpty ? level : 'Not set - helps match job level';
  }
  
  String _getSalaryRange() {
    final minSalary = PrefService.getString(PrefKeys.salaryRangeMin);
    final maxSalary = PrefService.getString(PrefKeys.salaryRangeMax);
    if (minSalary.isNotEmpty && maxSalary.isNotEmpty) {
      return '\$$minSalary - \$$maxSalary';
    }
    return 'Not set - helps filter by budget';
  }
  
  String _getJobTypes() {
    final jobTypesJson = PrefService.getString(PrefKeys.jobTypes);
    if (jobTypesJson.isNotEmpty) {
      try {
        final List<String> jobTypes = List<String>.from(jsonDecode(jobTypesJson));
        return jobTypes.isNotEmpty ? jobTypes.join(', ') : 'Not set - remote, on-site, hybrid';
      } catch (e) {
        return 'Not set - remote, on-site, hybrid';
      }
    }
    return 'Not set - remote, on-site, hybrid';
  }
  
  String _getSkills() {
    final skillsJson = PrefService.getString(PrefKeys.skillsList);
    if (skillsJson.isNotEmpty) {
      try {
        final List<String> skills = List<String>.from(jsonDecode(skillsJson));
        if (skills.isNotEmpty) {
          // Show first 5 skills, add "..." if more
          if (skills.length <= 5) {
            return skills.join(', ');
          } else {
            return '${skills.take(5).join(', ')}, +${skills.length - 5} more';
          }
        }
      } catch (e) {
        return 'Not set - your technical skills';
      }
    }
    return 'Not set - your technical skills';
  }
  
  void _clearProfileData() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Profile Data'),
        content: const Text('This will clear all your profile and preference data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              
              // Show loading
              Get.dialog(
                const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Clearing data...'),
                    ],
                  ),
                ),
                barrierDismissible: false,
              );
              
              // Clear all profile related preferences
              await Future.wait([
                PrefService.setValue(PrefKeys.fullName, ''),
                PrefService.setValue(PrefKeys.email, ''),
                PrefService.setValue(PrefKeys.phoneNumber, ''),
                PrefService.setValue(PrefKeys.dateOfBirth, ''),
                PrefService.setValue(PrefKeys.city, ''),
                PrefService.setValue(PrefKeys.state, ''),
                PrefService.setValue(PrefKeys.country, ''),
                PrefService.setValue(PrefKeys.occupation, ''),
                PrefService.setValue(PrefKeys.jobPosition, ''),
                PrefService.setValue(PrefKeys.bio, ''),
                PrefService.setValue(PrefKeys.address, ''),
                PrefService.setValue(PrefKeys.profileImageUrl, ''),
                // Clear preferences
                PrefService.setValue(PrefKeys.experienceLevel, ''),
                PrefService.setValue(PrefKeys.skillsList, ''),
                PrefService.setValue(PrefKeys.salaryRangeMin, ''),
                PrefService.setValue(PrefKeys.salaryRangeMax, ''),
                PrefService.setValue(PrefKeys.jobTypes, ''),
                PrefService.setValue(PrefKeys.industryPreferences, ''),
                PrefService.setValue(PrefKeys.companyTypes, ''),
                PrefService.setValue(PrefKeys.maxCommuteDistance, ''),
                PrefService.setValue(PrefKeys.workLocationPreference, ''),
              ]);
              
              Get.back(); // Close loading dialog
              
              Get.snackbar(
                '✅ Profile Cleared',
                'All profile and preference data has been cleared. You can now enter your own information.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
              
              // Force rebuild
              setState(() {});
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}