// lib/screen/smart_apply/smart_apply_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/service/notification_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'dart:io';

class SmartApplyScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;
  
  const SmartApplyScreen({super.key, required this.jobData});

  @override
  State<SmartApplyScreen> createState() => _SmartApplyScreenState();
}

class _SmartApplyScreenState extends State<SmartApplyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  File? _selectedCV;
  String? _cvFileName;
  
  final TextEditingController _motivationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    // Pré-remplir avec les données utilisateur
    final email = PrefService.getString(PrefKeys.email);
    if (email.isNotEmpty) {
      _emailController.text = email;
    }
  }

  Future<void> _pickCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedCV = File(result.files.single.path!);
          _cvFileName = result.files.single.name;
        });
        
        Get.snackbar(
          "✅ CV Sélectionné", 
          "Fichier: ${result.files.single.name}",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "❌ Erreur", 
        "Impossible de sélectionner le fichier: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitApplication() async {
    if (_selectedCV == null) {
      Get.snackbar(
        "⚠️ CV Required", 
        "Please select your CV",
        backgroundColor: ColorRes.appleGreen,
        colorText: Colors.white,
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        "⚠️ Email Required", 
        "Please enter your email",
        backgroundColor: ColorRes.appleGreen,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not connected");
      }

      // Créer la candidature dans Firebase
      final applicationData = {
        'uid': user.uid,
        'userName': PrefService.getString(PrefKeys.fullName),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'motivation': _motivationController.text.trim(),
        'cvFileName': _cvFileName,
        'cvSize': _selectedCV!.lengthSync(),
        'jobId': widget.jobData['docId'] ?? 'unknown',
        'jobTitle': widget.jobData['title'],
        'companyName': widget.jobData['company'],
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'submitted',
        'matchScore': widget.jobData['match'],
        'applicationSource': 'smart_matching',
      };

      // Sauvegarder dans la collection Apply
      await _firestore.collection('Apply').add(applicationData);

      // Mettre à jour les statistiques du job
      if (widget.jobData['docId'] != null) {
        await _firestore.collection('allPost').doc(widget.jobData['docId']).update({
          'applicationsCount': FieldValue.increment(1),
          'lastApplicationDate': FieldValue.serverTimestamp(),
        });
      }

      // Add notification about successful application
      final notificationService = Get.find<NotificationService>();
      await notificationService.addApplicationNotification(
        jobTitle: widget.jobData['title'] ?? 'Unknown Position',
        companyName: widget.jobData['company'] ?? 'Unknown Company',
        jobId: widget.jobData['docId'] ?? '',
      );

      Get.snackbar(
        "🎉 Application Sent!", 
        "Your application for ${widget.jobData['title']} has been submitted successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      // Navigate back to previous screen
      Get.back();

    } catch (e) {
      Get.snackbar(
        "❌ Error", 
        "Unable to send application: $e",
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
        title: Text('📝 Postuler', style: GoogleFonts.poppins()),
        backgroundColor: ColorRes.backgroundColor,
        foregroundColor: ColorRes.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_getMatchColor(), _getMatchColor().withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jobData['title'] ?? 'Poste',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.jobData['company'] ?? 'Entreprise',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.jobData['match'] ?? 0}% de correspondance',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // CV Upload Section
            Text(
              '📄 Télécharger votre CV *',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            InkWell(
              onTap: _isLoading ? null : _pickCV,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedCV != null ? Colors.green : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedCV != null ? Colors.green.withOpacity(0.1) : Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedCV != null ? Icons.check_circle : Icons.upload_file,
                      size: 48,
                      color: _selectedCV != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedCV != null 
                          ? '✅ $_cvFileName' 
                          : '📁 Cliquez pour sélectionner votre CV',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _selectedCV != null ? Colors.green : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedCV == null)
                      Text(
                        'Formats acceptés: PDF, DOC, DOCX',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contact Info
            Text(
              '📧 Informations de contact',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email *',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Motivation
            Text(
              '💬 Lettre de motivation (optionnel)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _motivationController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Expliquez pourquoi vous êtes intéressé par ce poste...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getMatchColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Envoyer ma candidature',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor() {
    final match = widget.jobData['match'] ?? 0;
    if (match >= 95) return Colors.green;
    if (match >= 85) return Colors.blue;
    return ColorRes.appleGreen;
  }

  @override
  void dispose() {
    _motivationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}