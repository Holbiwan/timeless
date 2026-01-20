import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:intl/intl.dart';
import 'package:timeless/utils/debug_applications.dart';
import 'package:timeless/services/interview_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeless/utils/fix_applications_employer_id.dart';

class EnhancedApplicationsScreen extends StatefulWidget {
  const EnhancedApplicationsScreen({super.key});

  @override
  State<EnhancedApplicationsScreen> createState() => _EnhancedApplicationsScreenState();
}

class _EnhancedApplicationsScreenState extends State<EnhancedApplicationsScreen> {
  // Use FirebaseAuth ID as the source of truth to match the dashboard and job posts
  late final String actualEmployerId;

  // Brand Colors
  final Color _primaryBlue = const Color(0xFF000647);
  final Color _accentOrange = const Color(0xFFE67E22);
  final Color _successGreen = const Color(0xFF27AE60);
  final Color _dangerRed = const Color(0xFFE74C3C);
  final Color _warningOrange = const Color(0xFFF39C12);

  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Use the same logic as employer dashboard to get the employer ID
    final uid = FirebaseAuth.instance.currentUser?.uid ?? PreferencesService.getString(PrefKeys.userId);
    actualEmployerId = uid;

    // Debug: Print employer ID
    print('🔍 EnhancedApplicationsScreen - Looking for applications with employerId: $actualEmployerId');

    // Fix applications with unknown_employer (one-time fix)
    FixApplicationsEmployerId.fixAll();

    // Run comprehensive debug check
    DebugApplications.checkApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            _buildHeader(),

            // Filter Tabs
            _buildFilterTabs(),

            // Applications Content
            Expanded(
              child: _buildApplicationsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryBlue,
            _primaryBlue.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
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
                onPressed: () => Get.back(),
                tooltip: 'Back to Dashboard',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Applications Management',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review and manage candidate applications',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
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

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'all', 'label': 'All Applications', 'icon': Icons.all_inbox},
      {'key': 'pending', 'label': 'Pending', 'icon': Icons.schedule},
      {'key': 'accepted', 'label': 'Accepted', 'icon': Icons.check_circle},
      {'key': 'rejected', 'label': 'Rejected', 'icon': Icons.cancel},
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter['key'] as String),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _primaryBlue : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: _primaryBlue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      color: isSelected ? Colors.white : _primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      filter['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : _primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApplicationsContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getApplicationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print('❌ Error loading applications: ${snapshot.error}');
          return _buildErrorState(snapshot.error.toString());
        }

        var applications = snapshot.data?.docs ?? [];
        print('📥 Received ${applications.length} applications from Firebase');

        // Debug: Print each application's employerId
        for (var app in applications) {
          final data = app.data() as Map<String, dynamic>;
          print('   - Application from ${data['candidateName']} for employerId: ${data['employerId']}');
        }

        // Apply status filter client-side
        if (selectedFilter != 'all') {
          applications = applications.where((app) {
            final data = app.data() as Map<String, dynamic>;
            return data['status'] == selectedFilter;
          }).toList();
        }

        // Sort client-side
        applications.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTimestamp = aData['appliedAt'] as Timestamp?;
          final bTimestamp = bData['appliedAt'] as Timestamp?;
          
          if (aTimestamp == null && bTimestamp == null) return 0;
          if (aTimestamp == null) return 1;
          if (bTimestamp == null) return -1;
          
          return bTimestamp.compareTo(aTimestamp); // Most recent first
        });

        if (applications.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Stats Summary
            _buildStatsHeader(applications),
            
            // Applications List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final application = applications[index];
                  final data = application.data() as Map<String, dynamic>;
                  data['id'] = application.id;
                  return _buildApplicationCard(data);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot> _getApplicationsStream() {
    var query = FirebaseFirestore.instance
        .collection('applications')
        .where('employerId', isEqualTo: actualEmployerId);

    // Remove orderBy to avoid index issues, we'll sort client-side
    return query.snapshots();
  }

  Widget _buildStatsHeader(List<QueryDocumentSnapshot> applications) {
    final total = applications.length;
    final pending = applications.where((app) {
      final data = app.data() as Map<String, dynamic>;
      return data['status'] == 'pending';
    }).length;
    final accepted = applications.where((app) {
      final data = app.data() as Map<String, dynamic>;
      return data['status'] == 'accepted';
    }).length;
    final rejected = applications.where((app) {
      final data = app.data() as Map<String, dynamic>;
      return data['status'] == 'rejected';
    }).length;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20),
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
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total', total.toString(), Icons.assignment_outlined, _primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Pending', pending.toString(), Icons.schedule, _warningOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Accepted', accepted.toString(), Icons.check_circle, _successGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Rejected', rejected.toString(), Icons.cancel, _dangerRed),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData iconData;

    switch (selectedFilter) {
      case 'pending':
        message = 'No Pending Applications';
        subtitle = 'No candidates are waiting for your review';
        iconData = Icons.schedule;
        break;
      case 'accepted':
        message = 'No Accepted Applications';
        subtitle = 'You haven\'t accepted any candidates yet';
        iconData = Icons.check_circle_outline;
        break;
      case 'rejected':
        message = 'No Rejected Applications';
        subtitle = 'You haven\'t rejected any applications';
        iconData = Icons.cancel_outlined;
        break;
      default:
        message = 'No Applications Yet';
        subtitle = 'Applications will appear here once candidates apply';
        iconData = Icons.inbox_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: _accentOrange.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                iconData,
                size: 64,
                color: _accentOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: _dangerRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Applications',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _dangerRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final appliedAt = application['appliedAt']?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy at HH:mm').format(appliedAt);
    final status = application['status'] ?? 'pending';
    final candidateName = application['candidateName'] ?? application['fullName'] ?? 'Unknown Candidate';
    final jobTitle = application['jobTitle'] ?? 'Unknown Position';
    final candidateEmail = application['candidateEmail'] ?? application['email'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
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
        ],
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with candidate info and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: _primaryBlue.withOpacity(0.1),
                  radius: 22,
                  child: Text(
                    candidateName[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: _primaryBlue,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidateName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _primaryBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        jobTitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (candidateEmail.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                candidateEmail,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),

            const SizedBox(height: 10),

            // Application details
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Applied on $formattedDate',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Candidate messages (if any)
            if (application['candidateMessages'] != null &&
                (application['candidateMessages'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildCandidateMessages(application['candidateMessages']),
            ],

            const SizedBox(height: 12),

            // Action buttons
            _buildActionButtons(application, status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateMessages(List<dynamic> messages) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _successGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _successGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: _successGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Messages from Candidate',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...messages.map((message) => _buildMessageItem(message, true)),
        ],
      ),
    );
  }

  Widget _buildMessageItem(dynamic message, bool fromCandidate) {
    final msgData = message as Map<String, dynamic>;
    final timestamp = msgData['timestamp']?.toDate() ?? DateTime.now();
    final formattedTime = DateFormat('MMM dd, HH:mm').format(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fromCandidate ? Colors.white : _primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: fromCandidate ? _successGreen.withOpacity(0.2) : _primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msgData['message'] ?? 'No message content',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: fromCandidate ? _successGreen : _primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedTime,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> application, String status) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Details',
            Icons.visibility_outlined,
            _primaryBlue,
            () => _viewApplicationDetails(application),
          ),
        ),
        const SizedBox(width: 6),
        if (status == 'pending') ...[
          Expanded(
            child: _buildActionButton(
              'Accept',
              Icons.check_circle_outlined,
              _successGreen,
              () => _updateApplicationStatus(application, 'accepted'),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildActionButton(
              'Reject',
              Icons.cancel_outlined,
              _dangerRed,
              () => _updateApplicationStatus(application, 'rejected'),
            ),
          ),
        ],
        if (status != 'pending') ...[
          Expanded(
            child: _buildActionButton(
              'Message',
              Icons.message_outlined,
              _accentOrange,
              () => _messageCandidate(application),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _warningOrange;
      case 'accepted':
        return _successGreen;
      case 'rejected':
        return _dangerRed;
      case 'interview':
        return _primaryBlue;
      default:
        return _warningOrange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'interview':
        return Icons.calendar_today;
      default:
        return Icons.schedule;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'interview':
        return 'Interview';
      default:
        return 'Pending';
    }
  }

  Future<void> _updateApplicationStatus(Map<String, dynamic> application, String newStatus) async {
    try {
      final applicationId = application['id'];
      if (applicationId == null) {
        Get.snackbar(
          'Error',
          'Unable to update application status',
          backgroundColor: _dangerRed,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({
        'status': newStatus,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actualEmployerId,
      });

      // Send email to candidate if accepted
      if (newStatus.toLowerCase() == 'accepted') {
        await _sendAcceptanceEmail(application);
      }

      String message = '';
      Color bgColor = _successGreen;

      switch (newStatus.toLowerCase()) {
        case 'accepted':
          message = 'Candidate accepted successfully';
          bgColor = _successGreen;
          break;
        case 'rejected':
          message = 'Candidate rejected';
          bgColor = _dangerRed;
          break;
        default:
          message = 'Application status updated successfully';
      }

      Get.snackbar(
        'Status Updated',
        message,
        backgroundColor: bgColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update application status: $e',
        backgroundColor: _dangerRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _sendAcceptanceEmail(Map<String, dynamic> application) async {
    try {
      final candidateEmail = application['candidateEmail'];
      final candidateName = application['candidateName'] ?? 'Candidate';
      final jobTitle = application['jobTitle'] ?? 'Position';
      final companyName = application['companyName'] ?? PreferencesService.getString(PrefKeys.companyName);

      // Get employer phone from Firestore
      String employerPhone = '+33123456789'; // Default fallback
      try {
        final employerDoc = await FirebaseFirestore.instance
            .collection('employers')
            .doc(actualEmployerId)
            .get();
        if (employerDoc.exists) {
          final data = employerDoc.data();
          if (data != null && data['phone'] != null && (data['phone'] as String).isNotEmpty) {
            employerPhone = data['phone'];
          }
        }
      } catch (e) {
        print('⚠️ Could not fetch employer phone: $e');
      }

      final emailHTML = _generateAcceptanceEmail(
        candidateName: candidateName,
        jobTitle: jobTitle,
        companyName: companyName,
        contactEmail: 'contact@recrutement.com',
        contactPhone: employerPhone,
      );

      await FirebaseFirestore.instance.collection('mail').add({
        'to': [candidateEmail],
        'message': {
          'subject': '🎉 Congratulations! Your application has been accepted - $jobTitle',
          'html': emailHTML,
          'text': 'Congratulations! Your application for $jobTitle at $companyName has been accepted. Please contact us at contact@recrutement.com or $employerPhone.',
        }
      });

      print('✅ Acceptance email sent to $candidateEmail');
    } catch (e) {
      print('❌ Error sending acceptance email: $e');
    }
  }

  String _generateAcceptanceEmail({
    required String candidateName,
    required String jobTitle,
    required String companyName,
    required String contactEmail,
    required String contactPhone,
  }) {
    return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Accepted - $jobTitle</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #4caf50 0%, #45a049 100%); color: white; text-align: center; padding: 40px 20px; }
        .header h1 { margin: 0; font-size: 28px; fontWeight: 700; }
        .content { padding: 40px 30px; }
        .success-icon { font-size: 64px; margin-bottom: 16px; }
        .info-box { background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #4caf50; }
        .contact-box { background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0; }
        .contact-item { display: flex; align-items: center; margin: 12px 0; padding: 10px; background: white; border-radius: 8px; }
        .contact-icon { color: #0d47a1; margin-right: 12px; }
        .action-button { display: inline-block; background: #4caf50; color: white; padding: 14px 35px; text-decoration: none; border-radius: 8px; margin: 15px 5px; font-weight: 600; font-size: 16px; }
        .footer { background-color: #f8f9fa; text-align: center; padding: 20px; border-top: 1px solid #eee; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="success-icon">🎉</div>
            <h1>Congratulations!</h1>
            <p style="font-size: 18px; margin: 10px 0;">Your application has been accepted</p>
        </div>

        <div class="content">
            <h2>Dear $candidateName,</h2>

            <div class="info-box">
                <h3 style="margin-top: 0; color: #2e7d32;">✅ Your Application Status: ACCEPTED</h3>
                <p style="margin: 10px 0;"><strong>Position:</strong> $jobTitle</p>
                <p style="margin: 10px 0;"><strong>Company:</strong> $companyName</p>
            </div>

            <p style="font-size: 16px; line-height: 1.6;">
                We are pleased to inform you that your application for the <strong>$jobTitle</strong> position
                at <strong>$companyName</strong> has been accepted!
            </p>

            <p style="font-size: 16px; line-height: 1.6;">
                This is an exciting next step in your career journey. Our recruitment team is eager to discuss
                the next steps with you.
            </p>

            <div class="contact-box">
                <h3 style="margin-top: 0; color: #0d47a1;">📞 Please Contact Us</h3>
                <p style="margin-bottom: 15px;">Please reach out to us to schedule the next steps:</p>

                <div class="contact-item">
                    <span class="contact-icon">✉️</span>
                    <div>
                        <strong>Email:</strong><br>
                        <a href="mailto:$contactEmail" style="color: #0d47a1; text-decoration: none;">$contactEmail</a>
                    </div>
                </div>

                <div class="contact-item">
                    <span class="contact-icon">📱</span>
                    <div>
                        <strong>Phone:</strong><br>
                        <a href="tel:$contactPhone" style="color: #0d47a1; text-decoration: none;">$contactPhone</a>
                    </div>
                </div>
            </div>

            <div style="text-align: center; margin: 30px 0;">
                <a href="mailto:$contactEmail?subject=Next Steps - $jobTitle Application" class="action-button">
                    ✉️ Contact Recruitment Team
                </a>
            </div>

            <div style="background: #fff3cd; padding: 15px; border-radius: 8px; border-left: 4px solid #ffc107; margin: 20px 0;">
                <h4 style="margin-top: 0; color: #856404;">💡 Next Steps:</h4>
                <ul style="margin: 10px 0; padding-left: 20px; color: #555;">
                    <li>Contact us at the provided email or phone number</li>
                    <li>Prepare your questions about the position and company</li>
                    <li>Review the job description and requirements</li>
                    <li>Be ready to discuss your availability for interviews</li>
                </ul>
            </div>

            <p style="color: #666; margin-top: 25px;">
                We look forward to hearing from you soon and moving forward with your application!
            </p>

            <p style="margin-top: 20px;">
                Best regards,<br>
                <strong>$companyName Recruitment Team</strong>
            </p>
        </div>

        <div class="footer">
            <h3>🌟 Timeless Recruiting Platform</h3>
            <p>Connecting talent with opportunity</p>
            <p style="font-size: 12px; color: #999;">
                This is an automated notification email.
            </p>
        </div>
    </div>
</body>
</html>
    """;
  }

  void _viewApplicationDetails(Map<String, dynamic> application) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Application Details',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: _primaryBlue,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Candidate Name', application['candidateName'] ?? 'N/A'),
              _buildDetailRow('Email', application['candidateEmail'] ?? 'N/A'),
              _buildDetailRow('Phone', application['candidatePhone'] ?? 'N/A'),
              _buildDetailRow('Position', application['jobTitle'] ?? 'N/A'),
              _buildDetailRow('Status', (application['status'] ?? 'pending').toUpperCase()),
              const SizedBox(height: 16),
              if (application['coverLetter'] != null) ...[
                Text(
                  'Cover Letter:',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    application['coverLetter'] ?? 'No cover letter provided',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (application['cvUrl'] != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final cvUrl = application['cvUrl'];
                      if (cvUrl != null && (cvUrl as String).isNotEmpty) {
                        try {
                          final uri = Uri.parse(cvUrl);
                          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (!launched) {
                            Get.snackbar(
                              'Error',
                              'Could not open CV. Please check the link.',
                              backgroundColor: _dangerRed,
                              colorText: Colors.white,
                            );
                          }
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Invalid CV URL: $e',
                            backgroundColor: _dangerRed,
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('View CV (PDF)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          if (application['candidateEmail'] != null) ...[
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                _proposeInterview(application);
              },
              icon: const Icon(Icons.event, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff6b6b),
                foregroundColor: Colors.white,
              ),
              label: Text(
                'Propose Interview',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _messageCandidate(application);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Message',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _primaryBlue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _messageCandidate(Map<String, dynamic> application) async {
    final messageController = TextEditingController();
    
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Send Message to Candidate',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: _primaryBlue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a message to ${application['candidateName'] ?? 'this candidate'}',
              style: GoogleFonts.inter(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryBlue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.trim().isNotEmpty) {
                await _sendMessageToCandidate(
                  application['id'],
                  messageController.text.trim(),
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Send',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessageToCandidate(String applicationId, String message) async {
    try {
      final messageData = {
        'from': 'employer',
        'fromId': actualEmployerId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add to application messages
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({
        'employerMessages': FieldValue.arrayUnion([messageData]),
      });

      Get.snackbar(
        'Success',
        'Message sent to candidate',
        backgroundColor: _successGreen,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        backgroundColor: _dangerRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 🆕 Propose interview to candidate
  Future<void> _proposeInterview(Map<String, dynamic> application) async {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFff6b6b).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event,
                color: Color(0xFFff6b6b),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Propose Interview',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: _primaryBlue,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite ${application['candidateName'] ?? 'this candidate'} for an interview',
                style: GoogleFonts.inter(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Proposed Date
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Proposed Date',
                  hintText: 'e.g., Monday, January 20, 2026',
                  prefixIcon: Icon(Icons.calendar_today, color: _primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Proposed Time
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Proposed Time',
                  hintText: 'e.g., 10:00 AM',
                  prefixIcon: Icon(Icons.access_time, color: _primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Office, Zoom, Google Meet',
                  prefixIcon: Icon(Icons.location_on, color: _primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Notes
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'Any additional information for the candidate...',
                  prefixIcon: Icon(Icons.note, color: _primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (dateController.text.trim().isEmpty ||
                  timeController.text.trim().isEmpty) {
                Get.snackbar(
                  'Missing Information',
                  'Please provide at least a date and time for the interview',
                  backgroundColor: _warningOrange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();

              // Show loading
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              final success = await InterviewService.proposeInterview(
                candidateEmail: application['candidateEmail'],
                candidateName: application['candidateName'] ?? 'Candidate',
                jobTitle: application['jobTitle'] ?? 'Position',
                companyName: PreferencesService.getString(PrefKeys.companyName),
                employerName: PreferencesService.getString(PrefKeys.fullName),
                employerEmail: PreferencesService.getString(PrefKeys.email),
                proposedDate: dateController.text.trim(),
                proposedTime: timeController.text.trim(),
                location: locationController.text.trim().isEmpty
                    ? null
                    : locationController.text.trim(),
                additionalNotes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );

              // Add notification to candidate
              if (success) {
                await InterviewService.notifyCandidateInterview(
                  candidateId: application['candidateId'],
                  jobTitle: application['jobTitle'] ?? 'Position',
                  companyName: PreferencesService.getString(PrefKeys.companyName),
                  proposedDate: dateController.text.trim(),
                );
              }

              Get.back(); // Close loading

              if (success) {
                Get.snackbar(
                  'Interview Proposed! 🎉',
                  'The candidate will receive an email with interview details',
                  backgroundColor: _successGreen,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 4),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to send interview proposal. Please try again.',
                  backgroundColor: _dangerRed,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            icon: const Icon(Icons.send, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff6b6b),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            label: Text(
              'Send Invitation',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}