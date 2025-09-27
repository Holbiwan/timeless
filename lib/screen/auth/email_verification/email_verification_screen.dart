// lib/screen/auth/email_verification/email_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/screen/auth/sign_in_screen/sign_in_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String userFullName;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.userFullName,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _canResendEmail = true;
  int _resendTimer = 0;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  void _startEmailVerificationCheck() {
    // Check email verification status every 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkEmailVerificationStatus();
      }
    });
  }

  Future<void> _checkEmailVerificationStatus() async {
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      
      if (user != null && user.emailVerified) {
        // Email verified, update Firestore and navigate to dashboard
        await _updateUserVerificationStatus(user);
        _navigateToDashboard();
      } else {
        // Continue checking
        if (mounted) {
          _startEmailVerificationCheck();
        }
      }
    } catch (e) {
      print('Error checking email verification: $e');
      if (mounted) {
        _startEmailVerificationCheck();
      }
    }
  }

  Future<void> _updateUserVerificationStatus(User user) async {
    try {
      await _db
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid)
          .update({
        "emailVerified": true,
        "accountStatus": "active",
        "verifiedAt": FieldValue.serverTimestamp(),
      });

      // Save user data to preferences
      await PrefService.setValue(PrefKeys.userId, user.uid);
      await PrefService.setValue(PrefKeys.email, widget.email);
      await PrefService.setValue(PrefKeys.fullName, widget.userFullName);
      await PrefService.setValue(PrefKeys.rol, "User");

      print('✅ User verification status updated');
    } catch (e) {
      print('❌ Error updating verification status: $e');
    }
  }

  void _navigateToDashboard() {
    Get.snackbar(
      "✅ Email Verified!",
      "Welcome to Timeless! Your account is now active.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    Get.offAll(() => DashBoardScreen());
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        
        Get.snackbar(
          "📧 Verification Email Sent",
          "A new verification email has been sent to ${widget.email}",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Start countdown timer
        setState(() {
          _canResendEmail = false;
          _resendTimer = 60;
        });

        _startResendTimer();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send verification email. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResendEmail = true;
        });
      }
    });
  }

  Future<void> _checkEmailManually() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      
      if (user != null && user.emailVerified) {
        await _updateUserVerificationStatus(user);
        _navigateToDashboard();
      } else {
        Get.snackbar(
          "Email Not Verified",
          "Please check your email and click the verification link first.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to check verification status. Please try again.",
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Logo
              Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorRes.logoColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Image(image: AssetImage(AssetRes.logo)),
              ),
              
              const SizedBox(height: 30),
              
              // Email icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: ColorRes.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 40,
                  color: ColorRes.primaryAccent,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                "Verify Your Email",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ColorRes.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              // Subtitle
              Text(
                "We've sent a verification link to:",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: ColorRes.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              // Email display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorRes.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorRes.primaryAccent.withOpacity(0.3)),
                ),
                child: Text(
                  widget.email,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.primaryAccent,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please check your email and click the verification link to activate your account. The verification will be detected automatically.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Check manually button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkEmailManually,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorRes.primaryAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "I've Verified My Email",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Resend email button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _canResendEmail && !_isLoading ? _resendVerificationEmail : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorRes.primaryAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _canResendEmail 
                        ? "Resend Verification Email"
                        : "Resend in ${_resendTimer}s",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _canResendEmail ? ColorRes.primaryAccent : Colors.grey,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Automatic verification notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.autorenew,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Checking verification status automatically...",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Back to sign in
              TextButton(
                onPressed: () {
                  Get.offAll(() => const SigninScreenU());
                },
                child: Text(
                  "Back to Sign In",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: ColorRes.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}