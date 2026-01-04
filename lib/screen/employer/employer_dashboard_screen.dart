import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/screen/employer/my_jobs_screen.dart';
import 'package:timeless/screen/employer/simple_applications_screen.dart';
import 'package:timeless/screen/employer/post_job_screen.dart';
import 'package:timeless/screen/employer/simple_profile_screen.dart';
import 'package:timeless/services/accessibility_service.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() =>
      _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  final String currentUserId = PreferencesService.getString(PrefKeys.userId);
  final String companyName = PreferencesService.getString(PrefKeys.companyName);
  final String employerId = PreferencesService.getString(PrefKeys.employerId);

  // Brand Colors
  final Color _primaryBlue = const Color(0xFF000647);
  final Color _accentOrange = const Color(0xFFE67E22);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;

    return Obx(() => Scaffold(
          backgroundColor: accessibilityService.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Fixed Header
                _buildFixedHeader(),

                // 2. Scrollable Content Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Stats Overview
                        _buildStatsOverview(),
                        const SizedBox(height: 20),

                        // Quick Actions Grid
                        Text(
                          'Quick Actions',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActionGrid(),
                        
                        const SizedBox(height: 24),

                        // Recent Applications Section
                        _buildSectionHeader('Recent Applications', () => Get.to(() => const SimpleApplicationsScreen())),
                        const SizedBox(height: 8),
                        _buildRecentApplications(),

                        const SizedBox(height: 24),

                        // Recent Job Posts Section
                        _buildSectionHeader('Recent Job Posts', () => Get.to(() => const MyJobsScreen())),
                        const SizedBox(height: 8),
                        _buildRecentJobPosts(),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildFixedHeader() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.black.withOpacity(0.9),
            _primaryBlue,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _BusinessPatternPainter(),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _accentOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _accentOrange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.business_center,
                      color: _accentOrange,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        onPressed: () {
                          // Clear employer session and return to login choice
                          PreferencesService.setBool(PrefKeys.isLogin, false);
                          PreferencesService.remove(PrefKeys.userId);
                          PreferencesService.remove(PrefKeys.employerId);
                          PreferencesService.remove(PrefKeys.companyName);
                          Get.offAllNamed(AppRes.firstScreen);
                        },
                        tooltip: 'Back to Login',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Employer Dashboard',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your recruitment efficiently',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                            onPressed: () {
                              setState(() {});
                              Get.snackbar(
                                'Refreshed',
                                'Dashboard data reloaded',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: _primaryBlue,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 1),
                                margin: const EdgeInsets.all(16),
                                borderRadius: 16,
                              );
                            },
                            tooltip: 'Refresh',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 16),
                            onPressed: _logout,
                            tooltip: 'Logout',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Active Jobs',
            stream: FirebaseFirestore.instance
                .collection('allPost')
                .where('EmployerId',
                    isEqualTo: employerId.isNotEmpty ? employerId : currentUserId)
                .where('isActive', isEqualTo: true)
                .snapshots(),
            icon: Icons.work_outline_rounded,
            accentColor: _primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Total Applications',
            stream: FirebaseFirestore.instance
                .collection('applications')
                .where('employerId',
                    isEqualTo: employerId.isNotEmpty ? employerId : currentUserId)
                .snapshots(),
            icon: Icons.people_alt_outlined,
            accentColor: _accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required Stream<QuerySnapshot> stream,
    required IconData icon,
    required Color accentColor,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: accentColor.withOpacity(0.15), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildActionCard(
          title: 'Post New Job',
          icon: Icons.add_circle_outline_rounded,
          color: _accentOrange,
          isPrimary: true,
          onTap: () => Get.to(() => const PostJobScreen()),
        ),
        _buildActionCard(
          title: 'Manage Jobs',
          icon: Icons.list_alt_rounded,
          color: _primaryBlue,
          onTap: () => Get.to(() => const MyJobsScreen()),
        ),
        _buildActionCard(
          title: 'Profile Settings',
          icon: Icons.settings_outlined,
          color: _primaryBlue,
          onTap: () => Get.to(() => const SimpleProfileScreen()),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isPrimary ? color.withOpacity(0.4) : Colors.black.withOpacity(0.08),
              blurRadius: isPrimary ? 20 : 16,
              offset: Offset(0, isPrimary ? 8 : 6),
              spreadRadius: isPrimary ? 4 : 2,
            ),
            if (!isPrimary)
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
          border: isPrimary 
              ? Border.all(color: Colors.white.withOpacity(0.2), width: 1.5)
              : Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: 28,
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13, // Reduced from 14
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : _primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _primaryBlue,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Row(
            children: [
              Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _accentOrange,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14, color: _accentOrange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentApplications() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('employerId',
              isEqualTo: employerId.isNotEmpty ? employerId : currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No applications yet');
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: _accentOrange.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: _accentOrange.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildApplicationItem(data);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRecentJobPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('allPost')
          .where('EmployerId',
              isEqualTo: employerId.isNotEmpty ? employerId : currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No job posts yet');
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: _accentOrange.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: _accentOrange.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildJobItem(data);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, color: _accentOrange.withOpacity(0.6), size: 40), // Orange icon
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(
              color: _accentOrange.withOpacity(0.7), // Orange text
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _accentOrange.withOpacity(0.1),
            radius: 24,
            child: Text(
              (data['candidateName'] ?? 'C')[0].toUpperCase(),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: _accentOrange,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['candidateName'] ?? 'Unknown Candidate',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: _primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['jobTitle'] ?? 'No Job Title',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildStatusTag(data['status'] ?? 'pending'),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _contactCandidate(data),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primaryBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.message_rounded, size: 12, color: _primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Contact',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobItem(Map<String, dynamic> data) {
    final bool isActive = data['isActive'] ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.business_center_rounded, color: _primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['Position'] ?? 'Untitled Position',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: _primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['location'] ?? 'Remote',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Active' : 'Closed',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = _accentOrange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  void _logout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: Get.back,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        PreferencesService.setValue(PrefKeys.isLogin, false as String);
                        PreferencesService.remove(PrefKeys.userId);
                        PreferencesService.remove(PrefKeys.employerId);
                        PreferencesService.remove(PrefKeys.companyName);
                        Get.offAllNamed(AppRes.firstScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _contactCandidate(Map<String, dynamic> candidateData) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.message_rounded, color: _primaryBlue, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Contact Candidate',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Send a contact proposal to ${candidateData['candidateName'] ?? 'this candidate'}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              
              // Contact options
              Column(
                children: [
                  _buildContactOption(
                    icon: Icons.email_rounded,
                    title: 'Send Email Invitation',
                    subtitle: 'Invite for an interview or discussion',
                    color: _accentOrange,
                    onTap: () => _sendEmailInvitation(candidateData),
                  ),
                  const SizedBox(height: 12),
                  _buildContactOption(
                    icon: Icons.phone_rounded,
                    title: 'Request Phone Contact',
                    subtitle: 'Ask for phone number to schedule a call',
                    color: _primaryBlue,
                    onTap: () => _requestPhoneContact(candidateData),
                  ),
                  const SizedBox(height: 12),
                  _buildContactOption(
                    icon: Icons.calendar_today_rounded,
                    title: 'Schedule Interview',
                    subtitle: 'Propose specific dates for meeting',
                    color: Colors.green,
                    onTap: () => _scheduleInterview(candidateData),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: Get.back,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  void _sendEmailInvitation(Map<String, dynamic> candidateData) {
    Get.back(); // Close dialog
    
    // Send a general email invitation
    _sendGeneralEmail(
      candidateEmail: candidateData['candidateEmail'] ?? '',
      candidateName: candidateData['candidateName'] ?? 'Candidate',
      subject: 'Invitation for Discussion from $companyName',
      message: '''
Dear ${candidateData['candidateName'] ?? 'Candidate'},

Thank you for your interest in opportunities at $companyName.

We would like to invite you for an initial discussion about potential opportunities that may be a good fit for your profile.

Please reply to this email to let us know your availability for a meeting or call.

Best regards,
$companyName Team
      ''',
    );
  }

  void _requestPhoneContact(Map<String, dynamic> candidateData) {
    Get.back(); // Close dialog
    
    // Send a phone contact request email
    _sendGeneralEmail(
      candidateEmail: candidateData['candidateEmail'] ?? '',
      candidateName: candidateData['candidateName'] ?? 'Candidate',
      subject: 'Phone Contact Request from $companyName',
      message: '''
Dear ${candidateData['candidateName'] ?? 'Candidate'},

We are interested in discussing opportunities with you at $companyName.

Could you please share your phone number so we can schedule a convenient time for a phone call?

You can reply to this email with your preferred contact number and times when you're available.

Best regards,
$companyName Team
      ''',
    );
  }

  void _scheduleInterview(Map<String, dynamic> candidateData) {
    Get.back(); // Close contact dialog first
    
    // Show interview scheduling dialog
    DateTime selectedDate = DateTime.now().add(Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay(hour: 14, minute: 0);
    final locationController = TextEditingController(text: companyName.isNotEmpty ? '$companyName Office' : 'Company Office');
    final messageController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.teal, size: 24),
            SizedBox(width: 8),
            Text(
              'Schedule Interview',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Candidate info
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue[700], size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Candidate: ${candidateData['candidateName'] ?? 'Unknown'}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Date selection
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.date_range, color: Colors.teal),
                    title: Text('Interview Date'),
                    subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 90)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),

                  // Time selection
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.access_time, color: Colors.teal),
                    title: Text('Interview Time'),
                    subtitle: Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),

                  SizedBox(height: 16),

                  // Location
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Interview Location',
                      prefixIcon: Icon(Icons.location_on, color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Additional message
                  TextFormField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Additional Message (Optional)',
                      prefixIcon: Icon(Icons.message, color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      hintText: 'Any additional details for the candidate...',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Create interview datetime
              final interviewDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              Get.back(); // Close dialog first

              // Send invitation
              await _sendInterviewInvitation(
                candidateData: candidateData,
                interviewDate: interviewDateTime,
                location: locationController.text.trim(),
                additionalMessage: messageController.text.trim().isNotEmpty 
                    ? messageController.text.trim() 
                    : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text('Send Invitation'),
          ),
        ],
      ),
    );
  }

  // Send a general email
  Future<void> _sendGeneralEmail({
    required String candidateEmail,
    required String candidateName,
    required String subject,
    required String message,
  }) async {
    try {
      final emailSent = await _sendSimpleEmail(
        to: candidateEmail,
        subject: subject,
        body: message,
      );

      if (emailSent) {
        Get.snackbar(
          '📧 Email Sent',
          'Email sent successfully to $candidateName',
          backgroundColor: _accentOrange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to send email');
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to send email: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Simple email sending (can be enhanced with real email service)
  Future<bool> _sendSimpleEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    try {
      // Simulate email sending
      await Future.delayed(const Duration(seconds: 1));
      
      print('Email sent to: $to');
      print('Subject: $subject');
      print('Body: $body');
      
      return true;
    } catch (e) {
      print('Failed to send email: $e');
      return false;
    }
  }

  // Send interview invitation
  Future<void> _sendInterviewInvitation({
    required Map<String, dynamic> candidateData,
    required DateTime interviewDate,
    required String location,
    String? additionalMessage,
  }) async {
    try {
      // Import EmailService at the top of this file if needed
      final emailSent = await _sendInterviewEmail(
        candidateEmail: candidateData['candidateEmail'] ?? '',
        candidateName: candidateData['candidateName'] ?? 'Candidate',
        interviewDate: interviewDate,
        location: location,
        additionalMessage: additionalMessage,
      );

      if (emailSent) {
        Get.snackbar(
          '✅ Interview Invitation Sent!',
          'The candidate ${candidateData['candidateName']} has been notified about the interview.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to send email invitation');
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to send interview invitation: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Simple email invitation (basic implementation)
  Future<bool> _sendInterviewEmail({
    required String candidateEmail,
    required String candidateName,
    required DateTime interviewDate,
    required String location,
    String? additionalMessage,
  }) async {
    try {
      // Format the date nicely
      final formattedDate = '${interviewDate.day}/${interviewDate.month}/${interviewDate.year}';
      final formattedTime = '${interviewDate.hour.toString().padLeft(2, '0')}:${interviewDate.minute.toString().padLeft(2, '0')}';
      
      // Create email subject and body
      final subject = 'Interview Invitation from $companyName';
      final body = '''
Dear $candidateName,

We are pleased to invite you for an interview at $companyName.

Interview Details:
• Date: $formattedDate
• Time: $formattedTime
• Location: $location

${additionalMessage != null ? '\nAdditional Information:\n$additionalMessage\n' : ''}

Please confirm your availability by replying to this email.

We look forward to meeting with you!

Best regards,
$companyName
      ''';

      // Here you could integrate with a real email service
      // For now, we'll simulate a successful send
      await Future.delayed(const Duration(seconds: 1));
      
      print('Email sent to: $candidateEmail');
      print('Subject: $subject');
      print('Body: $body');
      
      return true;
    } catch (e) {
      print('Failed to send email: $e');
      return false;
    }
  }
}

// Custom painter for business-themed background pattern
class _BusinessPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double spacing = 45.0;

    for (double x = 0; x <= size.width + spacing; x += spacing) {
      for (double y = 0; y <= size.height + spacing; y += spacing) {
        // Draw diamond pattern for business theme
        final path = Path();
        path.moveTo(x, y - 8);
        path.lineTo(x + 8, y);
        path.lineTo(x, y + 8);
        path.lineTo(x - 8, y);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}