import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeless/common/widgets/universal_app_bar.dart';
import 'package:timeless/models/application_model.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/controllers/employer_applications_controller.dart';
import 'package:timeless/utils/color_res.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final ApplicationModel application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmployerApplicationsController>();
    final job = controller.getJobForApplication(application);

    return TimelessScaffold(
      title: 'Application Details',
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, controller),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'email',
              child: Row(
                children: [
                  Icon(Icons.email, size: 20, color: ColorRes.darkGold),
                  const SizedBox(width: 8),
                  Text('Contact by Email'),
                ],
              ),
            ),
            if (application.candidatePhone?.isNotEmpty ?? false)
              PopupMenuItem(
                value: 'phone',
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 20, color: ColorRes.darkGold),
                    const SizedBox(width: 8),
                    Text('Call'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'download_cv',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20, color: ColorRes.darkGold),
                  const SizedBox(width: 8),
                  Text('Download CV'),
                ],
              ),
            ),
          ],
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate Info Card
            _buildCandidateInfoCard(),
            
            const SizedBox(height: 16),
            
            // Job Info Card
            if (job != null) _buildJobInfoCard(job),
            
            const SizedBox(height: 16),
            
            // Application Details
            _buildApplicationDetailsCard(),
            
            const SizedBox(height: 16),
            
            // CV Section
            _buildCvSection(),
            
            const SizedBox(height: 16),
            
            // Cover Letter
            if (application.coverLetter?.isNotEmpty ?? false)
              _buildCoverLetterCard(),
            
            const SizedBox(height: 20),
            
            // Status Actions
            _buildStatusActions(controller),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ColorRes.darkGold,
                  child: Text(
                    application.candidateName.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.candidateName,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Candidate',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: ColorRes.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Contact Information
            _buildContactRow(Icons.email, 'Email', application.candidateEmail),
            if (application.candidatePhone?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              _buildContactRow(Icons.phone, 'Phone', application.candidatePhone!),
            ],
            
            const SizedBox(height: 16),
            
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(application.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(application.status).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(application.status),
                    size: 16,
                    color: _getStatusColor(application.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusLabel(application.status),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(application.status),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorRes.darkGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: ColorRes.darkGold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ColorRes.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorRes.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobInfoCard(JobOfferModel job) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work, color: ColorRes.darkGold, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Applied Position',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              job.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              job.companyName,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: ColorRes.darkGold,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildJobInfoChip(Icons.location_on, job.location),
                const SizedBox(width: 12),
                _buildJobInfoChip(Icons.schedule, job.jobTypeDisplay),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorRes.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ColorRes.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: ColorRes.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: ColorRes.darkGold, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Application Details',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Application Date',
              DateFormat('EEEE, MMMM dd, yyyy at HH:mm', 'en_US').format(application.appliedAt),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Application ID',
              application.id,
            ),
            if (application.candidateProfile != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                'Candidate Profile',
                'Information Available',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: ColorRes.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorRes.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCvSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: ColorRes.darkGold, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Curriculum Vitae',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorRes.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorRes.successColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: ColorRes.successColor, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CV of ${application.candidateName}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorRes.black,
                          ),
                        ),
                        Text(
                          'PDF file available',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: ColorRes.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _downloadCv(),
                    icon: Icon(Icons.download, size: 16),
                    label: Text(
                      'Download',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorRes.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverLetterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.message, color: ColorRes.darkGold, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Cover Letter',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorRes.lightGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                application.coverLetter!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: ColorRes.black,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusActions(EmployerApplicationsController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Actions',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _buildStatusActionButtons(controller),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusActionButtons(EmployerApplicationsController controller) {
    List<Widget> buttons = [];
    
    if (application.status == ApplicationStatus.pending) {
      buttons.addAll([
        _buildActionButton(
          'Mark as Viewed',
          Icons.visibility,
          Colors.blue,
          () => controller.updateApplicationStatus(application.id, ApplicationStatus.viewed),
        ),
        _buildActionButton(
          'Shortlist',
          Icons.star,
          Colors.purple,
          () => controller.updateApplicationStatus(application.id, ApplicationStatus.shortlisted),
        ),
      ]);
    }
    
    if (application.status == ApplicationStatus.viewed || 
        application.status == ApplicationStatus.shortlisted) {
      buttons.addAll([
        _buildActionButton(
          'Schedule Interview',
          Icons.event,
          Colors.teal,
          () => controller.updateApplicationStatus(application.id, ApplicationStatus.interview),
        ),
        if (application.status == ApplicationStatus.viewed)
          _buildActionButton(
            'Shortlist',
            Icons.star,
            Colors.purple,
            () => controller.updateApplicationStatus(application.id, ApplicationStatus.shortlisted),
          ),
      ]);
    }
    
    if (application.status == ApplicationStatus.interview) {
      buttons.addAll([
        _buildActionButton(
          'Hire',
          Icons.check_circle,
          Colors.green,
          () => controller.updateApplicationStatus(application.id, ApplicationStatus.hired),
        ),
      ]);
    }
    
    // Reject button (always available except if already rejected or hired)
    if (application.status != ApplicationStatus.rejected && 
        application.status != ApplicationStatus.hired) {
      buttons.add(
        _buildActionButton(
          'Reject',
          Icons.close,
          ColorRes.royalBlue,
          () => _showRejectConfirmation(controller),
        ),
      );
    }
    
    return buttons;
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showRejectConfirmation(EmployerApplicationsController controller) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Reject Application',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to reject this application? This action is final.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateApplicationStatus(application.id, ApplicationStatus.rejected);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorRes.royalBlue,
              foregroundColor: Colors.white,
            ),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, EmployerApplicationsController controller) {
    switch (action) {
      case 'email':
        _sendEmail();
        break;
      case 'phone':
        _makePhoneCall();
        break;
      case 'download_cv':
        _downloadCv();
        break;
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: application.candidateEmail,
      queryParameters: {
        'subject': 'Your Application - ${Get.find<EmployerApplicationsController>().getJobForApplication(application)?.title ?? "Position"}',
      },
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to open email application',
        backgroundColor: ColorRes.royalBlue,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _makePhoneCall() async {
    if (application.candidatePhone?.isEmpty ?? true) return;
    
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: application.candidatePhone!,
    );

    try {
      await launchUrl(phoneUri);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to make phone call',
        backgroundColor: ColorRes.royalBlue,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadCv() async {
    try {
      // TODO: Implement CV download functionality
      Get.snackbar(
        'Download',
        'Download functionality in development',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to download CV',
        backgroundColor: ColorRes.royalBlue,
        colorText: Colors.white,
      );
    }
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.viewed:
        return Colors.blue;
      case ApplicationStatus.shortlisted:
        return Colors.purple;
      case ApplicationStatus.interview:
        return Colors.teal;
      case ApplicationStatus.rejected:
        return ColorRes.royalBlue;
      case ApplicationStatus.hired:
        return Colors.green;
      case ApplicationStatus.withdrawn:
        return Colors.grey;
      case ApplicationStatus.accepted:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Icons.hourglass_empty;
      case ApplicationStatus.viewed:
        return Icons.visibility;
      case ApplicationStatus.shortlisted:
        return Icons.star;
      case ApplicationStatus.interview:
        return Icons.event;
      case ApplicationStatus.rejected:
        return Icons.close;
      case ApplicationStatus.hired:
        return Icons.check_circle;
      case ApplicationStatus.withdrawn:
        return Icons.cancel;
      case ApplicationStatus.accepted:
        return Icons.thumb_up;
    }
  }

  String _getStatusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.viewed:
        return 'Viewed';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
      case ApplicationStatus.accepted:
        return 'Accepted';
    }
  }
}