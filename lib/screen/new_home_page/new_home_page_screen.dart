import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/controllers/candidate_controller.dart';
import 'package:timeless/models/application_model.dart';
import 'package:timeless/screen/profile/my_applications_screen.dart'; // For ApplicationCard reuse if possible, or we rebuild it
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/utils/color_res.dart';

class HomePageNewScreenU extends StatelessWidget {
  const HomePageNewScreenU({super.key});

  @override
  Widget build(BuildContext context) {
    final candidateController = Get.put(CandidateController());
    final UnifiedTranslationService translationService =
        Get.find<UnifiedTranslationService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => candidateController.refreshAll(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Greeting + Profile Pic
                _buildHeader(candidateController, translationService),

                const SizedBox(height: 24),

                // Search Bar (Visual only, leads to search tab)
                _buildSearchBar(translationService),

                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsSection(candidateController, translationService),

                const SizedBox(height: 24),

                // Recent Applications Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translationService.getText('recent_applications'),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorRes.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const MyApplicationsScreen());
                      },
                      child: Text(
                        translationService.getText('view_all'),
                        style: GoogleFonts.inter(
                          color: ColorRes.darkGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Recent Applications List
                Obx(() {
                  if (candidateController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (candidateController.applications.isEmpty) {
                    return _buildEmptyState(translationService);
                  }

                  final recentApps =
                      candidateController.applications.take(3).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentApps.length,
                    itemBuilder: (context, index) {
                      final app = recentApps[index];
                      return _buildCompactApplicationCard(
                          app, translationService);
                    },
                  );
                }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CandidateController controller,
      UnifiedTranslationService translationService) {
    return Obx(() {
      final profile = controller.candidateProfile;
      final name =
          profile?.fullName ?? translationService.getText('greeting_candidate');
      final photoUrl = profile?.photoURL;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translationService.getText('greeting_hello'),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: ColorRes.textSecondary,
                ),
              ),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ColorRes.black,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                ? NetworkImage(photoUrl)
                : const AssetImage('assets/images/userImage.png')
                    as ImageProvider,
            backgroundColor: ColorRes.containerColor,
          ),
        ],
      );
    });
  }

  Widget _buildSearchBar(UnifiedTranslationService translationService) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/search_job');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: ColorRes.textTertiary),
            const SizedBox(width: 12),
            Text(
              translationService.getText('search_job_placeholder'),
              style: GoogleFonts.inter(
                color: ColorRes.textTertiary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(CandidateController controller,
      UnifiedTranslationService translationService) {
    return Obx(() {
      final stats = controller.stats;
      final total = stats['totalApplications'] ?? 0;
      final pending = stats['pendingApplications'] ?? 0;
      final accepted = stats['acceptedApplications'] ?? 0;

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: translationService.getText('applications_total'),
              count: total.toString(),
              color: ColorRes.darkGold,
              icon: Icons.assignment,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: translationService.getText('applications_pending'),
              count: pending.toString(),
              color: ColorRes.orange,
              icon: Icons.hourglass_empty,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: translationService.getText('applications_accepted'),
              count: accepted.toString(),
              color: ColorRes.successColor,
              icon: Icons.check_circle,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactApplicationCard(
      ApplicationModel app, UnifiedTranslationService translationService) {
    // Determine status color locally or via helper
    Color statusColor;
    switch (app.status) {
      case ApplicationStatus.pending:
        statusColor = ColorRes.orange;
        break;
      case ApplicationStatus.viewed:
        statusColor = ColorRes.royalBlue;
        break;
      case ApplicationStatus.rejected:
        statusColor = ColorRes.errorColor;
        break;
      case ApplicationStatus.accepted:
      case ApplicationStatus.hired:
        statusColor = ColorRes.successColor;
        break;
      default:
        statusColor = ColorRes.textTertiary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            height: 48,
            width: 48,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.work_outline, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translationService
                      .getText('application_sent'), // Ideally Job Title
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ColorRes.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${translationService.getText('applied_on')} ${_formatDate(app.appliedAt)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorRes.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Status Chip
          _buildStatusChip(app.status, translationService),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
      ApplicationStatus status, UnifiedTranslationService translationService) {
    Color color;
    String label;

    switch (status) {
      case ApplicationStatus.pending:
        color = ColorRes.orange;
        label = translationService.getText('applications_pending');
        break;
      case ApplicationStatus.viewed:
        color = ColorRes.royalBlue;
        label =
            translationService.getText('viewed'); // Need to add 'viewed' key
        break;
      case ApplicationStatus.rejected:
        color = ColorRes.errorColor;
        label = translationService
            .getText('rejected'); // Need to add 'rejected' key
        break;
      case ApplicationStatus.accepted:
      case ApplicationStatus.hired:
        color = ColorRes.successColor;
        label = translationService.getText('applications_accepted');
        break;
      default:
        color = ColorRes.textTertiary;
        label = translationService.getText('other'); // Need to add 'other' key
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState(UnifiedTranslationService translationService) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.folder_open, size: 48, color: ColorRes.textTertiary),
            const SizedBox(height: 12),
            Text(
              translationService.getText('no_applications_yet'),
              style: GoogleFonts.inter(color: ColorRes.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
