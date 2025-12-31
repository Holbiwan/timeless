import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/email_verification_guard.dart';

class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  State<EmailVerificationBanner> createState() => _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  bool showWelcomeBanner = false;
  bool isLoading = true;
  String? companyName;

  @override
  void initState() {
    super.initState();
    _checkWelcomeStatus();
  }

  Future<void> _checkWelcomeStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          showWelcomeBanner = false;
        });
        return;
      }

      final employerDoc = await FirebaseFirestore.instance
          .collection('employers')
          .doc(user.uid)
          .get();

      if (employerDoc.exists) {
        final data = employerDoc.data()!;
        final welcomeShown = data['welcomeBannerShown'] == true;
        setState(() {
          showWelcomeBanner = !welcomeShown; // Show if not shown yet
          companyName = data['companyName'] ?? 'Company';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          showWelcomeBanner = false;
        });
      }
    } catch (e) {
      print('Error checking welcome status: $e');
      setState(() {
        isLoading = false;
        showWelcomeBanner = false;
      });
    }
  }

  Future<void> _resendConfirmationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Show loading
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: ColorRes.primaryBlue),
                SizedBox(height: 16),
                Text('Resending confirmation email...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final confirmationToken = user.uid;
      final confirmationUrl = 'https://dancing-meringue-8e50ad.netlify.app/confirm?token=$confirmationToken&email=${user.email}';
      
      await FirebaseFirestore.instance.collection('mail').add({
        'to': [user.email!],
        'message': {
          'subject': '✉️ Please confirm your email - Timeless [RESEND]',
          'html': '''
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>Email Confirmation - Timeless</title>
                <style>
                    body { font-family: Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
                    .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 16px rgba(0,0,0,0.1); }
                    .header { background: linear-gradient(135deg, #000647 0%, #1e3a8a 100%); color: white; text-align: center; padding: 30px 20px; }
                    .content { padding: 30px; }
                    .btn { display: inline-block; padding: 16px 32px; background: #000647; color: white !important; text-decoration: none; border-radius: 8px; font-weight: 600; font-size: 16px; margin: 20px 0; text-align: center; }
                    .footer { background-color: #f8f9fa; text-align: center; padding: 20px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>✉️ Email Confirmation</h1>
                        <p>Please confirm your email to activate your account</p>
                    </div>
                    <div class="content">
                        <p>Hello!</p>
                        <p>Please click the button below to confirm your email address:</p>
                        <div style="text-align: center; margin: 30px 0;">
                            <a href="$confirmationUrl" class="btn">Confirm Email Address</a>
                        </div>
                        <p>After confirmation, you can start posting job opportunities!</p>
                        <p><small>If you didn't request this, please ignore this email.</small></p>
                    </div>
                    <div class="footer">
                        <p>The Timeless Team 💼</p>
                    </div>
                </div>
            </body>
            </html>
          ''',
        },
      });

      Get.back(); // Close loading dialog
      
      Get.snackbar(
        '✅ Email Sent',
        'Confirmation email has been resent to ${user.email}',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.check_circle, color: Colors.green[600]),
        duration: Duration(seconds: 4),
      );

    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        '❌ Error',
        'Failed to resend email. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error, color: Colors.red[600]),
        duration: Duration(seconds: 4),
      );
    }
  }

  Future<void> _dismissWelcome() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('employers')
            .doc(user.uid)
            .update({'welcomeBannerShown': true});
        
        setState(() {
          showWelcomeBanner = false;
        });
      }
    } catch (e) {
      print('Error dismissing welcome: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || !showWelcomeBanner) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Timeless!',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Your account is ready - start posting jobs!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _dismissWelcome,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your ${companyName ?? 'company'} employer account is fully active! You can now post job opportunities and connect with talented candidates.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.95),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _dismissWelcome,
              icon: const Icon(Icons.rocket_launch, size: 18),
              label: Text(
                'Start Posting Jobs',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}