import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_screen.dart';
import 'package:intl/intl.dart';

class EnhancedCandidateApplicationsScreen extends StatefulWidget {
  const EnhancedCandidateApplicationsScreen({super.key});

  @override
  State<EnhancedCandidateApplicationsScreen> createState() => _EnhancedCandidateApplicationsScreenState();
}

class _EnhancedCandidateApplicationsScreenState extends State<EnhancedCandidateApplicationsScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final AccessibilityService accessibilityService = AccessibilityService.instance;

  // Brand Colors
  final Color _primaryBlue = const Color(0xFF000647);
  final Color _accentOrange = const Color(0xFFE67E22);
  final Color _successGreen = const Color(0xFF27AE60);
  final Color _dangerRed = const Color(0xFFE74C3C);

  // Filter states
  String selectedStatusFilter = 'all';
  String selectedSortOrder = 'newest';
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            _buildHeader(),

            // Filter Controls
            if (currentUserId.isNotEmpty) _buildFilterControls(),

            // Applications Content
            Expanded(
              child: currentUserId.isEmpty
                  ? _buildNotLoggedInState()
                  : _buildApplicationsContent(),
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
        padding: const EdgeInsets.all(16.0),
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
                tooltip: 'Back',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'My Applications',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your job applications in real-time',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _showResetDialog,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.delete_sweep_outlined,
                  color: _primaryBlue,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Applications',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: _primaryBlue,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all your applications? This will reset all counters to zero and cannot be undone.',
          style: GoogleFonts.inter(color: Colors.grey[700]),
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
            onPressed: () {
              Get.back();
              _deleteAllApplications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete All',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllApplications() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final snapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('candidateId', isEqualTo: currentUserId)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      Get.snackbar(
        'Success',
        'All applications have been deleted',
        backgroundColor: _successGreen,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete applications: $e',
        backgroundColor: _dangerRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status and Sort Filters
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'Status',
                  selectedStatusFilter,
                  [
                    {'value': 'all', 'label': 'All Status'},
                    {'value': 'pending', 'label': 'Pending'},
                    {'value': 'accepted', 'label': 'Accepted'},
                    {'value': 'rejected', 'label': 'Rejected'},
                    {'value': 'interview', 'label': 'Interview'},
                  ],
                  (value) => setState(() => selectedStatusFilter = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownFilter(
                  'Sort By',
                  selectedSortOrder,
                  [
                    {'value': 'newest', 'label': 'Newest First'},
                    {'value': 'oldest', 'label': 'Oldest First'},
                    {'value': 'status', 'label': 'By Status'},
                    {'value': 'company', 'label': 'By Company'},
                  ],
                  (value) => setState(() => selectedSortOrder = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Location Filter
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Filter by Location',
              hintText: 'e.g., Nice, Paris, Remote...',
              prefixIcon: Icon(Icons.location_on, color: _primaryBlue),
              suffixIcon: _locationController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: () {
                        _locationController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primaryBlue),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String currentValue,
    List<Map<String, String>> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryBlue),
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option['value'],
          child: Text(
            option['label']!,
            style: GoogleFonts.inter(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: _primaryBlue.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.login_outlined,
                size: 64,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Login Required',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please log in to view your job applications and track their status.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: Text(
                'Go Back',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredApplicationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final allApplications = snapshot.data?.docs ?? [];
        final filteredApplications = _filterApplications(allApplications);

        if (filteredApplications.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Stats Header
            _buildStatsHeader(filteredApplications),
            
            // Applications List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredApplications.length,
                itemBuilder: (context, index) {
                  final application = filteredApplications[index];
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

  Stream<QuerySnapshot> _getFilteredApplicationsStream() {
    // Simple query to avoid index requirements - filtering and sorting done client-side
    return FirebaseFirestore.instance
        .collection('applications')
        .where('candidateId', isEqualTo: currentUserId)
        .snapshots();
  }

  List<QueryDocumentSnapshot> _filterApplications(List<QueryDocumentSnapshot> applications) {
    var filtered = applications.toList(); // Create a copy

    // Apply status filter
    if (selectedStatusFilter != 'all') {
      filtered = filtered.where((app) {
        final data = app.data() as Map<String, dynamic>;
        return data['status'] == selectedStatusFilter;
      }).toList();
    }

    // Apply location filter
    final locationFilter = _locationController.text.toLowerCase().trim();
    if (locationFilter.isNotEmpty) {
      filtered = filtered.where((app) {
        final data = app.data() as Map<String, dynamic>;
        final jobLocation = (data['jobLocation'] ?? '').toString().toLowerCase();
        return jobLocation.contains(locationFilter);
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      if (selectedSortOrder == 'status') {
        final aStatus = aData['status'] ?? '';
        final bStatus = bData['status'] ?? '';
        return aStatus.compareTo(bStatus);
      } else if (selectedSortOrder == 'company') {
        final aCompany = aData['companyName'] ?? '';
        final bCompany = bData['companyName'] ?? '';
        return aCompany.compareTo(bCompany);
      } else {
        // Default to date sorting (newest or oldest)
        final aTimestamp = aData['appliedAt'] as Timestamp?;
        final bTimestamp = bData['appliedAt'] as Timestamp?;
        
        if (aTimestamp == null && bTimestamp == null) return 0;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;

        if (selectedSortOrder == 'oldest') {
          return aTimestamp.compareTo(bTimestamp);
        } else {
          return bTimestamp.compareTo(aTimestamp); // Newest first
        }
      }
    });

    return filtered;
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
      padding: const EdgeInsets.all(8), // Aggressively reduced padding
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Application Statistics',
                style: GoogleFonts.inter(
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.w700,
                  color: _primaryBlue,
                ),
              ),
              if (_locationController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Filtered by: ${_locationController.text}',
                    style: GoogleFonts.inter(
                      fontSize: 10, // Reduced font size
                      fontWeight: FontWeight.w500,
                      color: _accentOrange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10), // Reduced spacing
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total', total.toString(), Icons.assignment_outlined, _primaryBlue),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Expanded(
                child: _buildStatCard('Pending', pending.toString(), Icons.schedule, _accentOrange),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Expanded(
                child: _buildStatCard('Accepted', accepted.toString(), Icons.check_circle_outline, _successGreen),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Expanded(
                child: _buildStatCard('Rejected', rejected.toString(), Icons.cancel_outlined, _dangerRed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4), // Aggressively reduced padding
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
          Icon(icon, color: color, size: 18), // Reduced icon size
          const SizedBox(height: 4), // Reduced spacing
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14, // Reduced font size
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 9, // Reduced font size
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

    if (selectedStatusFilter != 'all') {
      message = 'No ${selectedStatusFilter.capitalize} Applications';
      subtitle = 'No applications found with ${selectedStatusFilter} status';
    } else if (_locationController.text.isNotEmpty) {
      message = 'No Applications Found';
      subtitle = 'No applications found in "${_locationController.text}"';
    } else {
      message = 'No Applications Yet';
      subtitle = 'You haven\'t applied to any jobs yet. Start exploring!';
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
                Icons.work_off_outlined,
                size: 64,
                color: _accentOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            if (_locationController.text.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _locationController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear, color: Colors.white),
                label: Text(
                  'Clear Filter',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final appliedAt = application['appliedAt']?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy at HH:mm').format(appliedAt);
    final status = application['status'] ?? 'pending';
    final jobId = application['jobId'];
    
    return FutureBuilder<DocumentSnapshot>(
      future: jobId != null ? FirebaseFirestore.instance.collection('allPost').doc(jobId).get() : null,
      builder: (context, snapshot) {
        // Default values from application document (fallback)
        String jobTitle = application['jobTitle'] ?? application['Position'] ?? application['title'] ?? 'Unknown Position';
        String companyName = application['companyName'] ?? application['CompanyName'] ?? application['company'] ?? 'Unknown Company';
        String location = application['jobLocation'] ?? application['location'] ?? application['city'] ?? 'Location not specified';

        // Override with real job data if available
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final jobData = snapshot.data!.data() as Map<String, dynamic>;
          jobTitle = jobData['Position'] ?? jobData['title'] ?? jobTitle;
          companyName = jobData['CompanyName'] ?? jobData['company'] ?? companyName;
          location = jobData['location'] ?? jobData['city'] ?? location;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with job title and status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobTitle,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Application details
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Applied on $formattedDate',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // Employer messages (if any)
                if (application['employerMessages'] != null && 
                    (application['employerMessages'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildEmployerMessages(application['employerMessages']),
                ],

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'View Job',
                        Icons.visibility_outlined,
                        _primaryBlue,
                        () => _viewJobDetails(application['jobId']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (status == 'pending') ...[
                      Expanded(
                        child: _buildActionButton(
                          'Withdraw',
                          Icons.cancel_outlined,
                          _dangerRed,
                          () => _withdrawApplication(application['id']),
                        ),
                      ),
                    ],
                    if (status == 'interview' || status == 'accepted') ...[
                      Expanded(
                        child: _buildActionButton(
                          'Respond',
                          Icons.reply_outlined,
                          _successGreen,
                          () => _respondToEmployer(application),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployerMessages(List<dynamic> messages) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message_outlined, color: _primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Messages from Employer',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...messages.map((message) => _buildMessageItem(message)),
        ],
      ),
    );
  }

  Widget _buildMessageItem(dynamic message) {
    final msgData = message as Map<String, dynamic>;
    final timestamp = msgData['timestamp']?.toDate() ?? DateTime.now();
    final formattedTime = DateFormat('MMM dd, HH:mm').format(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msgData['message'] ?? 'No message content',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _primaryBlue,
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

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
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
        return _accentOrange;
      case 'accepted':
      case 'interview':
        return _successGreen;
      case 'rejected':
        return _dangerRed;
      case 'viewed':
        return Colors.blue;
      default:
        return _accentOrange;
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
      case 'viewed':
        return Icons.visibility;
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
      case 'viewed':
        return 'Viewed';
      case 'interview':
        return 'Interview';
      default:
        return 'Pending';
    }
  }

  Future<void> _viewJobDetails(String? jobId) async {
    if (jobId == null || jobId.isEmpty) {
      Get.snackbar(
        'Error',
        'Job details not available',
        backgroundColor: _dangerRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final jobDoc = await FirebaseFirestore.instance
          .collection('allPost')
          .doc(jobId)
          .get();

      if (jobDoc.exists && jobDoc.data() != null) {
        Get.to(
          () => JobDetailScreen(),
          arguments: {'saved': jobDoc},
        );
      } else {
        Get.snackbar(
          'Error',
          'Job not found',
          backgroundColor: _dangerRed,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load job details: $e',
        backgroundColor: _dangerRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _withdrawApplication(String? applicationId) async {
    if (applicationId == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Withdraw Application',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: _primaryBlue,
          ),
        ),
        content: Text(
          'Are you sure you want to withdraw this application? This action cannot be undone.',
          style: GoogleFonts.inter(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Withdraw',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('applications')
            .doc(applicationId)
            .update({'status': 'withdrawn'});

        Get.snackbar(
          'Success',
          'Application withdrawn successfully',
          backgroundColor: _successGreen,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to withdraw application: $e',
          backgroundColor: _dangerRed,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _respondToEmployer(Map<String, dynamic> application) async {
    final messageController = TextEditingController();
    
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Respond to Employer',
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
              'Send a message to ${application['companyName']}',
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
                await _sendMessageToEmployer(
                  application['id'],
                  application['employerId'],
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

  Future<void> _sendMessageToEmployer(String applicationId, String employerId, String message) async {
    try {
      final messageData = {
        'from': 'candidate',
        'fromId': currentUserId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add to application messages
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({
        'candidateMessages': FieldValue.arrayUnion([messageData]),
      });

      Get.snackbar(
        'Success',
        'Message sent to employer',
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
}