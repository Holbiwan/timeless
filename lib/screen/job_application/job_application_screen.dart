import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/google_auth_service.dart';
import 'package:timeless/services/job_service.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
  final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
  
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
        'Error',
        'Failed to pick CV file: $e',
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
        title: Text('Connexion requise'),
        content: Text('Veuillez vous connecter pour postuler à cette offre'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _signInWithGoogle();
            },
            icon: Icon(Icons.login),
            label: Text('Se connecter avec Google'),
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
        await GoogleAuthService.saveUserToFirestore(user);
        Get.snackbar(
          'Succès',
          'Connexion réussie! Vous pouvez maintenant postuler.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _checkApplicationStatus();
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la connexion: $e',
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
        'CV requis',
        'Veuillez sélectionner votre CV',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'Téléphone requis',
        'Veuillez saisir votre numéro de téléphone',
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
            : _coverLetterController.text.trim(),
      );

      Get.snackbar(
        'Candidature envoyée!',
        'Votre candidature a été envoyée avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      setState(() {
        _hasApplied = true;
      });

    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'envoi: $e',
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
          'Postuler',
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
                    widget.jobData['Position'] ?? 'Unknown Position',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000647),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.jobData['CompanyName'] ?? 'Unknown Company',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.jobData['location'] ?? 'Unknown Location',
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
                        'Vous avez déjà postulé à cette offre',
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
                'Informations de candidature',
                style: accessibilityService.getAccessibleTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF000647),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Phone number field
              Text(
                'Numéro de téléphone *',
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
                  hintText: 'Votre numéro de téléphone',
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
                'CV (PDF) *',
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
                              : 'Cliquez pour sélectionner votre CV (PDF)',
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
                'Lettre de motivation (optionnel)',
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
                  hintText: 'Expliquez pourquoi vous êtes intéressé(e) par ce poste...',
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
                          'Postuler maintenant',
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
                              ? Icon(Icons.person) 
                              : null,
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connecté en tant que:',
                                style: accessibilityService.getAccessibleTextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                user.displayName ?? user.email ?? 'Utilisateur',
                                style: accessibilityService.getAccessibleTextStyle(
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
                          child: Text('Déconnexion'),
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