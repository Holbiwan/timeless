import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_res.dart';

class EmailConfirmationScreen extends StatefulWidget {
  const EmailConfirmationScreen({super.key});

  @override
  State<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool isLoading = true;
  bool isSuccess = false;
  String message = '';
  String? token;
  String? email;

  @override
  void initState() {
    super.initState();
    // Récupérer les paramètres de l'URL ou des arguments
    token = Get.parameters['token'];
    email = Get.parameters['email'];
    
    if (token != null && email != null) {
      _confirmEmail();
    } else {
      setState(() {
        isLoading = false;
        message = 'Invalid confirmation link. Please check your email and try again.';
      });
    }
  }

  Future<void> _confirmEmail() async {
    try {
      // Vérifier que l'utilisateur existe dans Firestore
      final employerDoc = await FirebaseFirestore.instance
          .collection('employers')
          .doc(token)
          .get();

      if (!employerDoc.exists) {
        setState(() {
          isLoading = false;
          message = 'Account not found. Please contact support.';
        });
        return;
      }

      final data = employerDoc.data()!;
      
      // Vérifier que l'email correspond
      if (data['email'] != email) {
        setState(() {
          isLoading = false;
          message = 'Email mismatch. Please use the correct confirmation link.';
        });
        return;
      }

      // Vérifier si déjà confirmé
      if (data['emailVerified'] == true) {
        setState(() {
          isLoading = false;
          isSuccess = true;
          message = 'Your email is already confirmed! You can now access your dashboard.';
        });
        return;
      }

      // Confirmer l'email
      await employerDoc.reference.update({
        'emailVerified': true,
        'accountStatus': 'active',
        'emailConfirmedAt': FieldValue.serverTimestamp(),
      });

      // Envoyer email de bienvenue confirmé
      await _sendWelcomeEmail();

      setState(() {
        isLoading = false;
        isSuccess = true;
        message = 'Email confirmed successfully! Welcome to Timeless.';
      });

    } catch (e) {
      setState(() {
        isLoading = false;
        message = 'An error occurred while confirming your email. Please try again.';
      });
      print('Error confirming email: $e');
    }
  }

  Future<void> _sendWelcomeEmail() async {
    try {
      await FirebaseFirestore.instance.collection('mail').add({
        'to': [email!],
        'message': {
          'subject': '🎉 Welcome to Timeless - Account Activated!',
          'html': '''
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Welcome to Timeless</title>
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
                    .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
                    .header { background: linear-gradient(135deg, #000647 0%, #1e3a8a 100%); color: white; text-align: center; padding: 40px 20px; }
                    .header h1 { margin: 0; font-size: 28px; font-weight: 700; }
                    .content { padding: 40px 30px; }
                    .success-box { background: #d4edda; padding: 25px; border-radius: 10px; margin: 25px 0; border-left: 4px solid #28a745; text-align: center; }
                    .btn { display: inline-block; padding: 15px 30px; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white !important; text-decoration: none; border-radius: 8px; font-weight: 600; margin: 10px 0; }
                    .footer { background-color: #f8f9fa; text-align: center; padding: 30px 20px; border-top: 1px solid #eee; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🎉 Welcome to Timeless!</h1>
                        <p>Your account is now fully activated</p>
                    </div>
                    <div class="content">
                        <h2>Congratulations!</h2>
                        <p>Thank you for confirming your email address. Your employer account is now fully activated and ready to use.</p>
                        
                        <div class="success-box">
                            <h3>✅ Account Activated</h3>
                            <p><strong>Email confirmed:</strong> $email</p>
                            <p>You can now start posting job opportunities and connecting with talented candidates.</p>
                            <a href="timeless://post-job" class="btn">Post Your First Job</a>
                        </div>
                        
                        <p><strong>What you can do now:</strong></p>
                        <ul>
                            <li>✅ Post unlimited job opportunities</li>
                            <li>✅ Access your employer dashboard</li>
                            <li>✅ Receive and review applications</li>
                            <li>✅ Manage your company profile</li>
                        </ul>
                        
                        <p>Ready to find your next great hire? Let's get started!</p>
                    </div>
                    <div class="footer">
                        <h3>The Timeless Team 💼</h3>
                        <p>📧 support@timeless.app | 🌐 www.timeless-app.com</p>
                        <p><em>Connecting talent with opportunity</em></p>
                    </div>
                </div>
            </body>
            </html>
          ''',
        },
      });
    } catch (e) {
      print('Error sending welcome email: $e');
    }
  }

  void _goToDashboard() {
    Get.offAllNamed(AppRes.managerDashboardScreen);
  }

  void _goToJobPosting() {
    // Navigate to job posting screen
    Get.offAllNamed('/post-job');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(color: ColorRes.royalBlue),
                    SizedBox(height: 20),
                    Text('Confirming your email...'),
                  ],
                )
              else ...[
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  size: 80,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  isSuccess ? 'Email Confirmed!' : 'Confirmation Failed',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: ColorRes.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                if (isSuccess) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToJobPosting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorRes.royalBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Post Your First Job',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _goToDashboard,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ColorRes.royalBlue),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Go to Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.royalBlue,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorRes.royalBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Go Back',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}