import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:timeless/utils/color_res.dart';
import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart';
import 'package:timeless/screen/first_page/first_screen.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';

class EmployerEmailVerificationScreen extends StatefulWidget {
  final String email;
  final String companyName;

  const EmployerEmailVerificationScreen({
    super.key,
    required this.email,
    required this.companyName,
  });

  @override
  State<EmployerEmailVerificationScreen> createState() => _EmployerEmailVerificationScreenState();
}

class _EmployerEmailVerificationScreenState extends State<EmployerEmailVerificationScreen> {
  bool _isLoading = false;
  bool _isResendingEmail = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              // Header with logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF000647), Color(0xFF1e3c72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        size: 40,
                        color: Color(0xFF000647),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verify Your PRO Email',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Complete your PRO account setup',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Company welcome
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF000647), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'Welcome ${widget.companyName}!',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000647),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your PRO account has been created successfully. We\'ve sent a verification email to:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF000647).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.email,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF000647),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Next Steps',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Check your email inbox\n2. Click the verification link\n3. Return here to access your PRO dashboard',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.blue[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkEmailVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000647),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'I\'ve Verified My Email',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isResendingEmail ? null : _resendVerificationEmail,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF000647),
                        side: const BorderSide(color: Color(0xFF000647)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isResendingEmail
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFF000647),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Resend Verification Email',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Debug button for testing
                  if (widget.email == 'Classe.Sainte-Therese@outlook.com')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _debugEmailTest(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'DEBUG: Force Test Email',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  if (widget.email == 'Classe.Sainte-Therese@outlook.com')
                    const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => Get.offAll(() => FirstScreen()),
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Reload user to get latest verification status
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        // Update Firestore to mark employer as verified
        await FirebaseFirestore.instance
            .collection('employers')
            .doc(user.uid)
            .update({'isVerified': true, 'verifiedAt': FieldValue.serverTimestamp()});

        // Save employer preferences
        await PreferencesService.setUserType('employer');
        await PreferencesService.setValue(PrefKeys.isLogin, true);
        await PreferencesService.setValue(PrefKeys.userId, user.uid);

        // Success message
        Get.snackbar(
          '✅ Email Verified!',
          'Welcome to Timeless PRO, ${widget.companyName}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate to PRO dashboard
        Get.offAll(() => ManagerDashBoardScreen());
      } else {
        Get.snackbar(
          '⚠️ Email Not Verified',
          'Please check your email and click the verification link first.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to verify email: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResendingEmail = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        debugPrint('🔄 Resending verification email to: ${user.email}');
        debugPrint('🔍 Current user emailVerified: ${user.emailVerified}');
        debugPrint('🔍 Current user uid: ${user.uid}');
        
        await user.sendEmailVerification();
        debugPrint('✅ Verification email resent successfully');
        
        Get.snackbar(
          '📧 Email Sent',
          'Verification email sent to ${widget.email}. Please check your inbox and spam folder.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        debugPrint('❌ No current user found');
        Get.snackbar(
          '❌ Error',
          'No user session found. Please try signing up again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error resending email: $e');
      debugPrint('❌ Error details: ${e.toString()}');
      
      Get.snackbar(
        '❌ Error',
        'Failed to resend email: $e\n\nPlease try again or contact support.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isResendingEmail = false;
      });
    }
  }

  Future<void> _debugEmailTest() async {
    try {
      
      debugPrint('🔍 DEBUG: Target email: ${widget.email}');
      
      final user = _auth.currentUser;
      if (user != null) {
        debugPrint('🔍 DEBUG: Current user found');
        debugPrint('   - Email: ${user.email}');
        debugPrint('   - UID: ${user.uid}');
        debugPrint('   - Email verified: ${user.emailVerified}');
        debugPrint('   - Provider data: ${user.providerData}');
        
        // Check Firestore data
        final employerDoc = await FirebaseFirestore.instance
            .collection('employers')
            .doc(user.uid)
            .get();
            
        if (employerDoc.exists) {
          final data = employerDoc.data();
          debugPrint('🔍 DEBUG: Employer data found in Firestore');
          debugPrint('   - Company: ${data?['companyName']}');
          debugPrint('   - Email: ${data?['email']}');
          debugPrint('   - Verified: ${data?['isVerified']}');
        } else {
          debugPrint('❌ DEBUG: No employer data found in Firestore');
        }
        
        // Force resend verification email
        debugPrint('🔄 DEBUG: Force sending verification email...');
        await user.sendEmailVerification();
        debugPrint('✅ DEBUG: Verification email sent successfully!');
        
        Get.snackbar(
          '🧪 DEBUG: Email Test',
          'Debug email verification sent to ${user.email}!\nCheck console for detailed logs.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 10),
        );
        
      } else {
        debugPrint('❌ DEBUG: No current user signed in');
        
        // Search for the company in Firestore
        final employersQuery = await FirebaseFirestore.instance
            .collection('employers')
            .where('email', isEqualTo: widget.email)
            .get();
            
        if (employersQuery.docs.isNotEmpty) {
          debugPrint('🔍 DEBUG: Found company in Firestore but no active user session');
          for (var doc in employersQuery.docs) {
            final data = doc.data();
            debugPrint('   - UID: ${doc.id}');
            debugPrint('   - Company: ${data['companyName']}');
            debugPrint('   - Email: ${data['email']}');
          }
        } else {
          debugPrint('❌ DEBUG: No company data found in Firestore');
        }
        
        Get.snackbar(
          '❌ DEBUG: No User Session',
          'No active user session. Company may need to sign in first.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 10),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ DEBUG: Error in email test: $e');
      debugPrint('❌ DEBUG: Stack trace: $stackTrace');
      
      Get.snackbar(
        '❌ DEBUG: Error',
        'Debug test failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
      );
    }
  }
}