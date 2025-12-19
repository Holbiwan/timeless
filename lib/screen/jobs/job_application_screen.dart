import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:timeless/models/job_offer_model.dart'; // Removed - using Map instead
import 'package:timeless/services/job_service.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';

class JobApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  final String? docId;

  const JobApplicationScreen({super.key, required this.job, this.docId});

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _commentController = TextEditingController();
  final UnifiedTranslationService translationService =
      UnifiedTranslationService();

  File? _selectedCV;
  bool _isLoading = false;
  String? _cvFileName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    // Charger les informations de l'utilisateur depuis les préférences
    try {
      _nameController.text = PreferencesService.getString(PrefKeys.fullName);
      _emailController.text = PreferencesService.getString(PrefKeys.email);
      _phoneController.text =
          PreferencesService.getString(PrefKeys.phoneNumber);
    } catch (e) {
      print(translationService.getText('error_loading_user_info') + ': $e');
    }
  }

  Future<void> _pickCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedCV = File(result.files.single.path!);
          _cvFileName = result.files.single.name;
        });
      }
    } catch (e) {
      Get.snackbar(
        translationService.getText('error'),
        translationService.getText('file_selection_error') + ': $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Application Submitted Successfully!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your application for ${widget.job['Position'] ?? 'this position'} at ${widget.job['CompanyName'] ?? 'this company'} has been submitted successfully.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.blue[700],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A confirmation email has been sent to ${_emailController.text}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme le dialog
                    Navigator.of(context).pop(); // Retourne à l'écran précédent
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000647),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Perfect!',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCV == null) {
      Get.snackbar(
        translationService.getText('cv_required'),
        translationService.getText('please_select_cv'),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await JobService.submitApplication(
        jobId: widget.docId ?? 'unknown_job_id',
        candidateId: PreferencesService.getString(PrefKeys.userId),
        employerId: widget.job['employerId'] ?? 'unknown_employer',
        candidateName: _nameController.text.trim(),
        candidateEmail: _emailController.text.trim(),
        candidatePhone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        cvFile: _selectedCV!,
        coverLetter: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
        candidateProfile: {
          'phone': _phoneController.text.trim(),
          'appliedAt': DateTime.now().toIso8601String(),
        },
      );

      _showSuccessDialog();
    } catch (e) {
      Get.snackbar(
        translationService.getText('error'),
        translationService.getText('application_send_error') + ': $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: Text(
          '${translationService.getText('apply')} - ${widget.job['Position'] ?? translationService.getText('position_default')}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 20,
          vertical: 8,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Information sur l'offre
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFF000647), width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000647).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.work,
                            color: const Color(0xFF000647),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job['Position'] ??
                                    translationService
                                        .getText('position_not_specified'),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                widget.job['CompanyName'] ??
                                    translationService
                                        .getText('company_not_specified'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.job['location'] ??
                                translationService
                                    .getText('location_not_specified'),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.job['salary'] != null &&
                                    widget.job['salary'] != "0"
                                ? "${widget.job['salary']}€"
                                : translationService
                                    .getText('salary_not_specified'),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Formulaire de candidature
              Text(
                translationService.getText('personal_information_title'),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Nom complet
              TextFormField(
                controller: _nameController,
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                  labelText: translationService.getText('full_name_label'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: const Color(0xFF000647), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return translationService.getText('name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: translationService.getText('email_label'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: const Color(0xFF000647), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return translationService
                        .getText('email_required_validation');
                  }
                  if (!GetUtils.isEmail(value.trim())) {
                    return translationService
                        .getText('invalid_email_validation');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Téléphone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: translationService.getText('phone_number_label'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: const Color(0xFF000647), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return translationService.getText('phone_number_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // CV Upload Section
              Text(
                translationService.getText('curriculum_vitae_title'),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              InkWell(
                onTap: _pickCV,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: ColorRes.backgroundColor,
                                        width: 1.5,
                                      ),                    borderRadius: BorderRadius.circular(10),
                    color: _selectedCV != null
                        ? const Color(0xFF000647).withOpacity(0.05)
                        : Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedCV != null
                            ? Icons.check_circle
                            : Icons.upload_file,
                        size: 24,
                        color: _selectedCV != null
                            ? const Color(0xFF000647)
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCV != null
                                  ? '${translationService.getText('cv_selected_message')}: $_cvFileName'
                                  : translationService
                                      .getText('select_your_cv_label'),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: _selectedCV != null
                                    ? const Color(0xFF000647)
                                    : Colors.grey[700],
                                fontWeight: _selectedCV != null
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            if (_selectedCV == null)
                              Text(
                                translationService
                                    .getText('accepted_formats_label'),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Commentaire/Lettre de motivation
              Text(
                translationService.getText('cover_letter_title'),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),

              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: translationService.getText('cover_letter_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: const Color(0xFF000647), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton d'envoi
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000647),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12), // Reduced padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFF000647).withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          translationService.getText('send_my_application'),
                          style: GoogleFonts.poppins(
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
