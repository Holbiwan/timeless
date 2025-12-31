import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_res.dart';

class EmailVerificationCodeScreen extends StatefulWidget {
  const EmailVerificationCodeScreen({super.key});

  @override
  State<EmailVerificationCodeScreen> createState() => _EmailVerificationCodeScreenState();
}

class _EmailVerificationCodeScreenState extends State<EmailVerificationCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _userEmail = FirebaseAuth.instance.currentUser?.email;
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'User not found. Please sign in again.';
          _isLoading = false;
        });
        return;
      }

      // Récupérer les données utilisateur
      final employerDoc = await FirebaseFirestore.instance
          .collection('employers')
          .doc(user.uid)
          .get();

      if (!employerDoc.exists) {
        setState(() {
          _errorMessage = 'Account not found. Please contact support.';
          _isLoading = false;
        });
        return;
      }

      final data = employerDoc.data()!;
      final storedCode = data['confirmationCode']?.toString();
      final expiresAt = data['codeExpiresAt'] as int?;
      final inputCode = _codeController.text.trim();

      // Vérifier si le code a expiré
      if (expiresAt != null && DateTime.now().millisecondsSinceEpoch > expiresAt) {
        setState(() {
          _errorMessage = 'This code has expired. Please request a new one.';
          _isLoading = false;
        });
        return;
      }

      // Vérifier le code
      if (storedCode != inputCode) {
        setState(() {
          _errorMessage = 'Invalid code. Please check and try again.';
          _isLoading = false;
        });
        return;
      }

      // Code correct ! Activer le compte
      await employerDoc.reference.update({
        'emailVerified': true,
        'accountStatus': 'active',
        'emailConfirmedAt': FieldValue.serverTimestamp(),
        'confirmationCode': FieldValue.delete(), // Supprimer le code utilisé
        'codeExpiresAt': FieldValue.delete(),
      });

      // Envoyer email de bienvenue
      await _sendWelcomeEmail(user.email!);

      setState(() {
        _isLoading = false;
      });

      // Afficher message de succès et rediriger
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Email Verified!', style: GoogleFonts.inter(color: Colors.green)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your email has been successfully verified. You can now access all features and post job opportunities.',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              SizedBox(height: 16),
              Icon(Icons.celebration, size: 48, color: Colors.orange),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed(AppRes.managerDashboardScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorRes.royalBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Go to Dashboard', style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        ),
        barrierDismissible: false,
      );

    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
      print('Error verifying code: $e');
    }
  }

  Future<void> _sendWelcomeEmail(String email) async {
    try {
      await FirebaseFirestore.instance.collection('mail').add({
        'to': [email],
        'message': {
          'subject': '🎉 Welcome to Timeless - Account Activated!',
          'html': '''
            <h1>🎉 Welcome to Timeless!</h1>
            <p>Congratulations! Your email has been verified and your account is now fully activated.</p>
            <p><strong>What you can do now:</strong></p>
            <ul>
              <li>✅ Post unlimited job opportunities</li>
              <li>✅ Access your employer dashboard</li>
              <li>✅ Receive and review applications</li>
              <li>✅ Connect with talented candidates</li>
            </ul>
            <p>Ready to find your next great hire? Let's get started!</p>
            <p>The Timeless Team 💼</p>
          ''',
        },
      });
    } catch (e) {
      print('Error sending welcome email: $e');
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Générer nouveau code
      final newCode = (DateTime.now().millisecondsSinceEpoch % 900000 + 100000).toString();
      
      // Mettre à jour en base
      await FirebaseFirestore.instance
          .collection('employers')
          .doc(user.uid)
          .update({
        'confirmationCode': newCode,
        'codeExpiresAt': DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch,
      });

      // Envoyer nouvel email
      await FirebaseFirestore.instance.collection('mail').add({
        'to': [user.email!],
        'message': {
          'subject': '✉️ New confirmation code - Timeless',
          'html': '''
            <h1>📱 New Verification Code</h1>
            <p>Here's your new confirmation code:</p>
            <div style="text-align: center; font-size: 32px; font-weight: bold; color: #000647; letter-spacing: 8px; background: #f0f0f0; padding: 20px; border-radius: 8px; margin: 20px 0;">
              $newCode
            </div>
            <p>This code will expire in 10 minutes.</p>
            <p>The Timeless Team 💼</p>
          ''',
        },
      });

      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'Code Sent',
        'A new verification code has been sent to your email',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.email, color: Colors.green),
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to send new code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorRes.royalBlue),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Email Verification',
          style: GoogleFonts.inter(
            color: ColorRes.royalBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorRes.royalBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.email_outlined,
                size: 60,
                color: ColorRes.royalBlue,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              'Enter Verification Code',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorRes.royalBlue,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'We sent a 6-digit code to\n${_userEmail ?? 'your email'}',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: ColorRes.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Code input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 24,
                    color: Colors.grey[400],
                    letterSpacing: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorRes.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorRes.royalBlue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
                onChanged: (value) {
                  setState(() {
                    _errorMessage = null;
                  });
                  if (value.length == 6) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Verify button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorRes.royalBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                        'Verify Email',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Resend button
            TextButton.icon(
              onPressed: _isLoading ? null : _resendCode,
              icon: Icon(Icons.refresh, size: 18),
              label: Text(
                'Didn\'t receive the code? Resend',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: ColorRes.royalBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}