import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/screen/job_application/job_application_controller.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_screen.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UserApplicationsScreen extends StatefulWidget {
  const UserApplicationsScreen({super.key});

  @override
  State<UserApplicationsScreen> createState() => _UserApplicationsScreenState();
}

class _UserApplicationsScreenState extends State<UserApplicationsScreen> {
  final JobApplicationController applicationController =
      Get.put(JobApplicationController());
  final UnifiedTranslationService translationService =
      Get.find<UnifiedTranslationService>();
  final AccessibilityService accessibilityService =
      Get.find<AccessibilityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Applications',
          style: accessibilityService.getAccessibleTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF000647),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (!authSnapshot.hasData || authSnapshot.data == null) {
            return _buildNotAuthenticatedWidget();
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: applicationController.getUserApplicationsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur: ${snapshot.error}',
                    style: accessibilityService.getAccessibleTextStyle(
                      color: Colors.red,
                    ),
                  ),
                );
              }

              final applications = snapshot.data ?? [];

              if (applications.isEmpty) {
                return _buildEmptyStateWidget();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final application = applications[index];
                  return _buildApplicationCard(application);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotAuthenticatedWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Login Required',
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000647),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to see your applications',
              textAlign: TextAlign.center,
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to authentication screen
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000647),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Applications',
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000647),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t sent any applications yet. Explore job offers and apply!',
              textAlign: TextAlign.center,
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.search),
              label: const Text('View Jobs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000647),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final appliedAt = application['appliedAt']?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(appliedAt);

    final status = application['status'] ?? 'pending';
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Accepted';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        statusIcon = Icons.cancel;
        break;
      case 'under_review':
        statusColor = Colors.orange;
        statusText = 'Under Review';
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Pending';
        statusIcon = Icons.schedule;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job title and company
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['jobTitle'] ?? 'Unknown Position',
                        style: accessibilityService.getAccessibleTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF000647),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application['company'] ?? 'Unknown Company',
                        style: accessibilityService.getAccessibleTextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          statusText,
                          style: accessibilityService.getAccessibleTextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Location and application date
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    application['location'] ?? 'Unknown Location',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Applied on $formattedDate',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Cover letter preview (if exists)
            if (application['coverLetter'] != null &&
                application['coverLetter'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cover Letter:',
                      style: accessibilityService.getAccessibleTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application['coverLetter'].toString().length > 100
                          ? '${application['coverLetter'].toString().substring(0, 100)}...'
                          : application['coverLetter'].toString(),
                      style: accessibilityService.getAccessibleTextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Actions
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (application['cvUrl'] != null) ...[
                  TextButton.icon(
                    onPressed: () async {
                      await _viewCV(application['cvUrl']);
                    },
                    icon: const Icon(Icons.description, size: 16),
                    label: const Text('View CV'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF000647),
                    ),
                  ),
                ],
                TextButton.icon(
                  onPressed: () async {
                    await _viewJobDetails(application['jobId']);
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Job'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF000647),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await _deleteApplication(application['id'],
                        application['jobTitle'] ?? 'this application');
                  },
                  icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF000647)),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent, // Ensure button background doesn't interfere
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // View CV functionality
  Future<void> _viewCV(String? cvUrl) async {
    if (cvUrl == null || cvUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'CV not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final Uri url = Uri.parse(cvUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Cannot open CV',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open CV: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // View job details functionality
  Future<void> _viewJobDetails(String? jobId) async {
    if (jobId == null || jobId.isEmpty) {
      Get.snackbar(
        'Error',
        'Job details not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Get job details from Firestore
      final jobDoc = await FirebaseFirestore.instance
          .collection('allPost')
          .doc(jobId)
          .get();

      if (jobDoc.exists && jobDoc.data() != null) {
        final rawData = jobDoc.data()!;

        // Debug: Print the raw data to see what fields are available
        print('=== DEBUG: Raw job data from Firestore ===');
        print('Keys available: ${rawData.keys.toList()}');
        print('Position: ${rawData['Position']}');
        print('CompanyName: ${rawData['CompanyName']}');
        print('location: ${rawData['location']}');
        print('salary: ${rawData['salary']}');
        print('type: ${rawData['type']}');
        print('jobType: ${rawData['jobType']}');
        print('RequirementsList: ${rawData['RequirementsList']}');
        print('requirements: ${rawData['requirements']}');
        print('=====================================');

        // Create a safe job data map with null-safe values matching JobDetailScreen expectations
        final List<dynamic> requirements =
            rawData['requirements'] ?? rawData['RequirementsList'] ?? [];
        final List<dynamic> responsibilities = rawData['responsibilities'] ??
            rawData['ResponsibilitiesList'] ??
            [];

        // Ensure requirements and responsibilities are proper lists with string values
        final List<String> safeRequirements = requirements
            .map((item) => item?.toString() ?? 'No requirement specified')
            .toList();
        final List<String> safeResponsibilities = responsibilities
            .map((item) => item?.toString() ?? 'No responsibility specified')
            .toList();

        // Add default items if lists are empty to prevent .length errors
        if (safeRequirements.isEmpty) {
          safeRequirements.add('Requirements not specified');
        }
        if (safeResponsibilities.isEmpty) {
          safeResponsibilities.add('Responsibilities not specified');
        }

        final Map<String, dynamic> jobData = {
          'id': jobDoc.id,
          'Position': rawData['Position']?.toString() ?? 'Unknown Position',
          'CompanyName':
              rawData['CompanyName']?.toString() ?? 'Unknown Company',
          'Description':
              rawData['Description']?.toString() ?? 'No description available',
          'location': rawData['location']?.toString() ?? 'Unknown Location',
          'salary': rawData['salary']?.toString() ?? '0',
          'type': rawData['jobType']?.toString() ??
              rawData['type']?.toString() ??
              'CDI', // Map jobType to type
          'category': rawData['category']?.toString() ?? 'General',
          'jobType': rawData['jobType']?.toString() ?? 'CDI',
          'isRemote': rawData['isRemote'] ?? false,
          'isFromVerifiedEmployer': rawData['isFromVerifiedEmployer'] ?? true,
          'isActive': rawData['isActive'] ?? true,
          'createdAt': rawData['createdAt'],
          'updatedAt': rawData['updatedAt'],
          'apeCode': rawData['apeCode']?.toString() ?? '',
          'siretCode': rawData['siretCode']?.toString() ?? '',
          'companyAddress': rawData['companyAddress']?.toString() ?? '',
          'postalCode': rawData['postalCode']?.toString() ?? '',
          'city': rawData['city']?.toString() ?? '',
          'country': rawData['country']?.toString() ?? 'France',
          'companyEmail': rawData['companyEmail']?.toString() ?? '',
          'responsibilities': safeResponsibilities,
          'requirements': safeRequirements,
          'RequirementsList':
              safeRequirements, // Ensure this exists for JobDetailScreen
          'ResponsibilitiesList': safeResponsibilities,
          'applicationsCount': rawData['applicationsCount'] ?? 0,
          'BookMarkUserList': rawData['BookMarkUserList'] ?? [],
          // Additional fields that might be expected
          'EmployerId': rawData['EmployerId']?.toString() ?? 'unknown',
          'keywords': rawData['keywords'] ?? [],
        };

        // Final validation before navigation
        print('=== DEBUG: Final jobData for navigation ===');
        print('Position: ${jobData['Position']}');
        print('CompanyName: ${jobData['CompanyName']}');
        print('location: ${jobData['location']}');
        print('salary: ${jobData['salary']}');
        print('type: ${jobData['type']}');
        print(
            'RequirementsList length: ${jobData['RequirementsList']?.length}');
        print('RequirementsList: ${jobData['RequirementsList']}');
        print('==========================================');

        // Navigate to job detail screen
        Get.to(
          () => JobDetailScreen(),
          arguments: {
            'saved': jobData,
          },
        );
      } else {
        Get.snackbar(
          'Error',
          'Job not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error loading job details: $e');
      Get.snackbar(
        'Error',
        'Failed to load job details',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Delete application functionality
  Future<void> _deleteApplication(
      String? applicationId, String jobTitle) async {
    if (applicationId == null || applicationId.isEmpty) {
      Get.snackbar(
        'Error',
        'Cannot delete application',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show confirmation dialog
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Application'),
        content: Text(
            'Are you sure you want to delete your application for "$jobTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete from applications collection
        await FirebaseFirestore.instance
            .collection('applications')
            .doc(applicationId)
            .delete();

        // Show success message
        Get.snackbar(
          'Success',
          'Application deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Optionally, you might also want to clean up the Applicants collection
        // This depends on your data structure and business logic
        await _cleanupApplicantsCollection(applicationId);
      } catch (e) {
        print('Error deleting application: $e');
        Get.snackbar(
          'Error',
          'Failed to delete application',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Helper method to clean up Applicants collection if needed
  Future<void> _cleanupApplicantsCollection(String applicationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Query for the user's applicant document
      final applicantsQuery = await FirebaseFirestore.instance
          .collection('Applicants')
          .where('candidateId', isEqualTo: user.uid)
          .get();

      for (var applicantDoc in applicantsQuery.docs) {
        // Query for userDetails with the specific applicationId
        final userDetailsQuery = await applicantDoc.reference
            .collection('userDetails')
            .where('applicationId', isEqualTo: applicationId)
            .get();

        // Delete matching userDetails documents
        for (var userDetailDoc in userDetailsQuery.docs) {
          await userDetailDoc.reference.delete();
        }

        // Check if the applicant document has any remaining userDetails
        final remainingDetails = await applicantDoc.reference
            .collection('userDetails')
            .limit(1)
            .get();

        // If no userDetails remain, delete the parent applicant document
        if (remainingDetails.docs.isEmpty) {
          await applicantDoc.reference.delete();
        }
      }
    } catch (e) {
      print('Error cleaning up Applicants collection: $e');
      // Don't show error to user as this is a background cleanup
    }
  }
}
