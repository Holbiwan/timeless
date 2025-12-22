import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/application_test_helper.dart';
import 'package:timeless/services/email_service.dart';

class ReceivedApplicationsScreen extends StatelessWidget {
  const ReceivedApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String companyName = PreferencesService.getString(PrefKeys.companyName);
    
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Apply')
              .where('companyName', isEqualTo: companyName)
              .snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Received Applications',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$count application${count != 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: ColorRes.brightYellow,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (kDebugMode) // Bouton de test visible uniquement en mode debug
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'create_test':
                    await ApplicationTestHelper.createTestApplication(
                      companyName: companyName,
                    );
                    break;
                  case 'create_multiple':
                    await ApplicationTestHelper.createMultipleTestApplications(
                      companyName: companyName,
                      count: 3,
                    );
                    break;
                  case 'cleanup':
                    await ApplicationTestHelper.cleanupTestApplications(
                      companyName: companyName,
                    );
                    break;
                }
              },
              icon: const Icon(Icons.bug_report, color: Colors.orange),
              tooltip: 'Test Functions (Debug Only)',
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'create_test',
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Create Test Application',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'create_multiple',
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_add, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Create Multiple Tests',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'cleanup',
                  child: Row(
                    children: [
                      const Icon(Icons.cleaning_services, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Cleanup Test Data',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            onPressed: () {
              // Force refresh by rebuilding the StreamBuilder
              Get.snackbar(
                '🔄 Refreshing',
                'Updating applications list...',
                backgroundColor: ColorRes.brightYellow,
                colorText: Colors.black,
                duration: const Duration(seconds: 1),
                snackPosition: SnackPosition.TOP,
              );
            },
            icon: const Icon(Icons.refresh, color: Colors.black),
            tooltip: 'Refresh applications',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Apply')
            .where('companyName', isEqualTo: companyName)
            .orderBy('appliedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ColorRes.brightYellow),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final application = doc.data() as Map<String, dynamic>;
              return _buildApplicationCard(application, doc.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        color: const Color(0xFF8B4513), // Set background color here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Applications Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Applications will appear here when candidates apply to your job posts.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    ),
  );
}

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> application, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Application',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this application?',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Candidate: ${application['userName'] ?? 'Unknown'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Position: ${application['jobTitle'] ?? 'Unknown'}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Text(
                      'Email: ${application['email'] ?? 'No email'}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteApplication(context, application, documentId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // Delete application from Firestore
  void _deleteApplication(BuildContext context, Map<String, dynamic> application, String documentId) async {
    try {
      // Show loading indicator
      _showLoadingDialog(context);

      // Delete the document directly using its ID (much more efficient and reliable)
      await FirebaseFirestore.instance
          .collection('Apply')
          .doc(documentId)
          .delete();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      Get.snackbar(
        '✅ Application Deleted',
        'The application from ${application['userName'] ?? 'Unknown'} has been successfully deleted.',
        backgroundColor: Colors.green[600],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      Get.snackbar(
        '❌ Delete Failed',
        'An error occurred while deleting the application: ${e.toString()}',
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // Show loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(color: ColorRes.brightYellow),
              const SizedBox(width: 20),
              Text(
                'Deleting application...',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application, String documentId) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorRes.brightYellow.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with candidate info
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorRes.brightYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: ColorRes.darkBlue,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['userName'] ?? 'Unknown Candidate',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.textPrimary,
                        ),
                      ),
                      Text(
                        application['email'] ?? 'No email',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: ColorRes.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (application['isTestData'] == true && kDebugMode)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'TEST',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorRes.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NEW',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Job position applied for
            Text(
              'Applied for: ${application['jobTitle'] ?? 'Unknown Position'}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorRes.darkBlue,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Application date
            Text(
              'Applied: ${_formatDate(application['appliedAt'])}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: ColorRes.textSecondary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Open candidate profile or CV
                      Get.snackbar(
                        'View Profile',
                        'Opening candidate profile...',
                        backgroundColor: ColorRes.brightYellow,
                        colorText: Colors.black,
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: Text(
                      'View Profile',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorRes.brightYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scheduleInterview(context, application, documentId),
                    icon: const Icon(Icons.calendar_month, size: 16),
                    label: Text(
                      'Interview',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 6, 71),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Contact button in full width
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Start chat with candidate
                  Get.snackbar(
                    'Contact',
                    'Starting conversation with candidate...',
                    backgroundColor: ColorRes.darkBlue,
                    colorText: Colors.white,
                  );
                },
                icon: const Icon(Icons.chat, size: 16),
                label: Text(
                  'Contact Candidate',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorRes.darkBlue,
                  side: const BorderSide(color: ColorRes.darkBlue),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Erase button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(context, application, documentId),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: Text(
                  'Erase Application',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Schedule interview function
  void _scheduleInterview(BuildContext context, Map<String, dynamic> application, String documentId) {
    final DateTime now = DateTime.now();
    DateTime selectedDate = now.add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();
    final TextEditingController messageController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Schedule Interview',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 0, 6, 71),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Candidate: ${application['userName'] ?? 'Unknown'}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Position: ${application['jobTitle'] ?? 'Unknown'}',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    
                    // Date Picker
                    Text('Interview Date:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Time Picker
                    Text('Interview Time:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 8),
                            Text(selectedTime.format(context)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location field
                    Text('Location:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Office Address or Video Call Link',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Message field
                    Text('Additional Message:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Optional message for the candidate...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: () => _sendInterviewInvitation(
                    context, 
                    application, 
                    documentId, 
                    selectedDate, 
                    selectedTime, 
                    locationController.text,
                    messageController.text,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 6, 71),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Send Invitation', style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Send interview invitation
  Future<void> _sendInterviewInvitation(
    BuildContext context,
    Map<String, dynamic> application,
    String documentId,
    DateTime selectedDate,
    TimeOfDay selectedTime,
    String location,
    String additionalMessage,
  ) async {
    try {
      Navigator.of(context).pop(); // Close dialog
      _showLoadingDialog(context);

      final companyName = PreferencesService.getString(PrefKeys.companyName);
      final interviewDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Create interview document in Firestore
      final interviewData = {
        'candidateEmail': application['email'],
        'candidateName': application['userName'],
        'companyName': companyName,
        'jobTitle': application['jobTitle'],
        'interviewDate': interviewDateTime,
        'location': location,
        'additionalMessage': additionalMessage,
        'status': 'Schedule Interview',
        'createdAt': FieldValue.serverTimestamp(),
        'applicationId': documentId,
      };

      // Save to Interviews collection
      await FirebaseFirestore.instance
          .collection('Interviews')
          .add(interviewData);

      // Update the application status in the Applicants collection
      await FirebaseFirestore.instance
          .collection('Applicants')
          .doc(companyName)
          .collection('userDetails')
          .where('userName', isEqualTo: application['userName'])
          .where('position', isEqualTo: application['jobTitle'])
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({
            'status': 'Schedule Interview',
            'interviewDate': interviewDateTime,
            'interviewLocation': location,
          });
        }
      });

      // Send email notification
      final emailService = EmailService();
      await emailService.sendInterviewInvitation(
        candidateEmail: application['email'] ?? '',
        candidateName: application['userName'] ?? 'Candidate',
        companyName: companyName,
        jobTitle: application['jobTitle'] ?? 'Position',
        interviewDate: interviewDateTime,
        location: location,
        additionalMessage: additionalMessage,
      );

      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      Get.snackbar(
        '📧 Interview Scheduled!',
        'Interview invitation sent to ${application['userName']}',
        backgroundColor: const Color.fromARGB(255, 0, 6, 71),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      Get.snackbar(
        '❌ Error',
        'Failed to schedule interview: ${e.toString()}',
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Unknown date';
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }
}