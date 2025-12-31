import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/color_res.dart';

class EmailVerificationGuard {
  // Vérifie si l'utilisateur actuel a confirmé son email
  static Future<bool> isEmailVerified() async {
    // NOUVELLE LOGIQUE : Tous les employeurs sont automatiquement vérifiés
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Tous les utilisateurs connectés sont considérés comme vérifiés
      return true;
    } catch (e) {
      print('Error checking email verification: $e');
      return true; // En cas d'erreur, on autorise quand même
    }
  }

  // Affiche un dialog demandant à l'utilisateur de confirmer son email
  static Future<void> showEmailVerificationDialog() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.email, color: ColorRes.royalBlue),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Email Verification Required',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorRes.royalBlue,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You need to verify your email address before you can post job opportunities.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: ColorRes.textSecondary,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Check your email inbox for the verification link.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: ColorRes.textSecondary,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back();
              await _resendVerificationEmail();
            },
            icon: Icon(Icons.email, size: 18),
            label: Text('Resend Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorRes.royalBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Renvoie l'email de vérification
  static Future<void> _resendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return;

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
                CircularProgressIndicator(color: ColorRes.royalBlue),
                SizedBox(height: 16),
                Text(
                  'Sending verification email...',
                  style: GoogleFonts.inter(),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final confirmationToken = user.uid;
      final confirmationUrl =
          'https://confirm-email-timeless.web.app/confirm?token=$confirmationToken&email=${user.email}';

      await FirebaseFirestore.instance.collection('mail').add({
        'to': [user.email!],
        'message': {
          'subject': '✉️ Please confirm your email address - Timeless',
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
                    .btn { display: inline-block; padding: 12px 24px; background: #000647; color: white !important; text-decoration: none; border-radius: 6px; font-weight: 600; }
                    .footer { background-color: #f8f9fa; text-align: center; padding: 20px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>✉️ Email Verification</h1>
                        <p>Please confirm your email to continue</p>
                    </div>
                    <div class="content">
                        <p>Hello!</p>
                        <p>Please click the button below to verify your email address and activate your account:</p>
                        <p style="text-align: center; margin: 30px 0;">
                            <a href="$confirmationUrl" class="btn">Verify Email Address</a>
                        </p>
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
        'Verification email has been sent to ${user.email}',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.check_circle, color: Colors.green[600]),
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        '❌ Error',
        'Failed to send verification email. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error, color: Colors.red[600]),
        duration: Duration(seconds: 4),
      );
      print('Error resending email: $e');
    }
  }

  // Middleware pour protéger les actions qui nécessitent une email vérifié
  static Future<bool> requireEmailVerification() async {
    // NOUVELLE LOGIQUE : Tous les employeurs passent automatiquement
    return true;
  }
}
