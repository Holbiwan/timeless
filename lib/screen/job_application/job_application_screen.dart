import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/services/google_auth_service.dart';
import 'package:timeless/services/job_service.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:timeless/screen/profile/my_applications_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import


class JobApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;
  final String jobId;

  const JobApplicationScreen({
    super.key,
    required this.jobData,
    required this.jobId,
  });

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final UnifiedTranslationService translationService =
      Get.find<UnifiedTranslationService>();
  final AccessibilityService accessibilityService =
      Get.find<AccessibilityService>();

  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedCV;
  bool _isLoading = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final hasApplied = await JobService.hasApplied(user.uid, widget.jobId);
      setState(() {
        _hasApplied = hasApplied;
      });
    }
  }

  Future<void> _pickCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedCV = File(result.files.single.path!);
        });
      }
    } catch (e) {
      Get.snackbar(
        translationService.getText('error'),
        '${translationService.getText('file_selection_error')}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _authenticateAndApply() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Show authentication dialog
      _showAuthDialog();
    } else {
      // User is authenticated, proceed with application
      _submitApplication();
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translationService.getText('connection_required')),
        content: Text(translationService.getText('please_login_to_apply')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translationService.getText('cancel')),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _signInWithGoogle();
            },
            icon: const Icon(Icons.login),
            label: Text(translationService.getText('login_with_google')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);

      final user = await GoogleAuthService.signInWithGoogle();
      if (user != null) {
        await GoogleAuthService.saveUserToFirestore(user as User);
        Get.snackbar(
          translationService.getText('success'), // Using existing 'success' key
          translationService.getText('connection_success'),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _checkApplicationStatus();
      }
    } catch (e) {
      Get.snackbar(
        translationService.getText('error'),
        '${translationService.getText('connection_failed')} $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitApplication() async {
    if (_selectedCV == null) {
      Get.snackbar(
        translationService.getText('cv_required_popup'),
        translationService.getText('please_select_your_cv'),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      Get.snackbar(
        translationService.getText('phone_required'),
        translationService.getText('please_enter_phone'),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser!;

      // Get employer ID from job data
      final employerId = widget.jobData['EmployerId'] ?? 'unknown';

      await JobService.submitApplication(
        jobId: widget.jobId,
        candidateId: user.uid,
        employerId: employerId,
        candidateName: user.displayName ?? 'Anonymous',
        candidateEmail: user.email ?? '',
        candidatePhone: _phoneController.text.trim(),
        cvFile: _selectedCV!,
        coverLetter: _coverLetterController.text.trim().isEmpty
            ? null
            : _coverLetterController.text.trim(), candidateProfile: {},
      );

      // Trigger email to recruiter (using Firebase Trigger Email Extension pattern)
      if (widget.jobData['employerEmail'] != null) {
        FirebaseFirestore.instance.collection('mail').add({
          'to': widget.jobData['employerEmail'],
          'message': {
            'subject': 'New Application Received: ${widget.jobData['Position']}',
            'text': 'Hello,\n\nA new candidate (${user.displayName ?? 'Anonymous'}) has applied for the position "${widget.jobData['Position']}".\n\nPlease check your Employer Dashboard to review the application and CV.\n\nBest regards,\nTimeless App',
          },
        });
      }

      Get.snackbar(
        translationService.getText('your_application_sent'),
        translationService.getText('your_application_submitted_successfully'),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      setState(() {
        _hasApplied = true;
      });

      // Navigate to My Applications after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        Get.to(() => const MyApplicationsScreen());
      });
    } catch (e) {
      Get.snackbar(
        translationService.getText('error'),
        '${translationService.getText('application_failed_to_send')} $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      appBar: AppBar(
        title: Text(
          translationService.getText('apply_screen_title'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job information card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jobData['Position'] ??
                        translationService.getText('unknown_position'),
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000647),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.jobData['CompanyName'] ??
                        translationService.getText('unknown_company'),
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                                            Text(
                                              widget.jobData['location'] ?? 
                                              widget.jobData['Location'] ?? 
                                              translationService.getText('location_not_specified'),
                                              style: accessibilityService.getAccessibleTextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_hasApplied) ...[
              // Already applied message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        translationService.getText('already_applied_message'),
                        style: accessibilityService.getAccessibleTextStyle(
                          fontSize: 16,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Application form
              Text(
                translationService.getText('personal_information_title'),
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF000647),
                ),
              ),

              const SizedBox(height: 16),

              // Phone number field
              Text(
                translationService.getText('phone_number_label_asterisk'),
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: accessibilityService.getAccessibleTextStyle(),
                decoration: InputDecoration(
                  hintText:
                      translationService.getText('your_phone_number_hint'),
                  hintStyle: accessibilityService.getAccessibleTextStyle(
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CV upload section
              Text(
                translationService.getText('select_cv_pdf_label'),
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickCV,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedCV != null
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedCV != null
                            ? Icons.check_circle
                            : Icons.upload_file,
                        color: _selectedCV != null
                            ? Colors.green
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedCV != null
                              ? _selectedCV!.path.split('/').last
                              : translationService
                                  .getText('click_select_your_cv_pdf'),
                          style: accessibilityService.getAccessibleTextStyle(
                            color: _selectedCV != null
                                ? Colors.green.shade800
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Cover letter field
              Text(
                translationService.getText('cover_letter_optional'),
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _coverLetterController,
                maxLines: 5,
                style: accessibilityService.getAccessibleTextStyle(),
                decoration: InputDecoration(
                  hintText: translationService.getText('cover_letter_hint'),
                  hintStyle: accessibilityService.getAccessibleTextStyle(
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _authenticateAndApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000647),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          translationService.getText('apply_now_button'),
                          style: accessibilityService.getAccessibleTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Current user info (if logged in)
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final user = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? const Icon(Icons.person)
                              : null,
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translationService.getText('logged_in_as'),
                                style:
                                    accessibilityService.getAccessibleTextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                user.displayName ??
                                    user.email ??
                                    translationService.getText('user'),
                                style:
                                    accessibilityService.getAccessibleTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await GoogleAuthService.signOut();
                            setState(() {});
                          },
                          child: Text(translationService.getText('disconnect')),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
