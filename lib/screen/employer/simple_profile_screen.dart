import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/screen/employer/edit_profile_screen.dart';
import 'package:timeless/screen/employer/change_password_screen.dart';
import 'package:timeless/screen/employer/notifications_screen.dart';

class SimpleProfileScreen extends StatefulWidget {
  const SimpleProfileScreen({super.key});

  @override
  State<SimpleProfileScreen> createState() => _SimpleProfileScreenState();
}

class _SimpleProfileScreenState extends State<SimpleProfileScreen> {
  final String employerId = PreferencesService.getString(PrefKeys.employerId);
  final String currentUserId = PreferencesService.getString(PrefKeys.userId);
  
  Map<String, dynamic>? employerData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployerData();
  }

  Future<void> _loadEmployerData() async {
    try {
      final String actualEmployerId = employerId.isNotEmpty ? employerId : currentUserId;
      final doc = await FirebaseFirestore.instance
          .collection('employers')
          .doc(actualEmployerId)
          .get();
      
      if (doc.exists) {
        setState(() {
          employerData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000647),
        title: Text(
          'Profile Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF000647), Color(0xFF1A1A2E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.business,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          employerData?['companyName'] ?? 'Your Company',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          employerData?['email'] ?? 'No email',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Company Information',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 0, 6, 71),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard([
                    _buildInfoRow('Company Name', employerData?['companyName'] ?? 'Not specified'),
                    _buildInfoRow('Address', employerData?['address'] ?? 'Not specified'),
                    _buildInfoRow('Postal Code', employerData?['postalCode'] ?? 'Not specified'),
                    _buildInfoRow('Country', employerData?['country'] ?? 'Not specified'),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'Legal Information',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 0, 6, 71),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard([
                    _buildInfoRow('SIRET Code', employerData?['siretCode'] ?? 'Not specified'),
                    _buildInfoRow('APE Code', employerData?['apeCode'] ?? 'Not specified'),
                    _buildInfoRow('User Type', employerData?['userType'] ?? 'employer'),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Account Actions',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 0, 6, 71),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _buildActionTile(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          subtitle: 'Update company information',
                          onTap: () {
                            if (employerData != null) {
                              Get.to(() => EditProfileScreen(employerData: employerData!))?.then((_) {
                                _loadEmployerData();
                              });
                            }
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          icon: Icons.security,
                          title: 'Change Password',
                          subtitle: 'Update your account password',
                          onTap: () {
                            Get.to(() => const ChangePasswordScreen());
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          onTap: () {
                            Get.to(() => const NotificationsScreen());
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          icon: Icons.logout,
                          title: 'Logout',
                          subtitle: 'Sign out of your account',
                          onTap: _logout,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF000647),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                PreferencesService.setValue(PrefKeys.isLogin, false);
                PreferencesService.remove(PrefKeys.userId);
                PreferencesService.remove(PrefKeys.employerId);
                PreferencesService.remove(PrefKeys.companyName);
                
                Get.offAllNamed(AppRes.firstScreen);
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to logout: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}