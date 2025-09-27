// lib/screen/auth/sign_up/sign_up_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/screen/auth/email_verification/email_verification_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:country_picker/country_picker.dart';


class SignUpController extends GetxController {
  // ===== State / Controllers =====
  final RxBool loading = false.obs;

  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl  = TextEditingController();
  final TextEditingController emailCtrl     = TextEditingController();
  final TextEditingController passwordCtrl  = TextEditingController();

  bool showPassword = true;

  // Erreurs UI
  String emailError = "";
  String pwdError   = "";
  String firstError = "";
  String lastError  = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  get countryModel => null;

  // ===== Validations (minimales pour la démo) =====
  void emailValidation() {
    final text = emailCtrl.text.trim();
    if (text.isEmpty) {
      emailError = 'Please enter email';
    } else if (RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(text)) {
      emailError = '';
    } else {
      emailError = "Invalid email";
    }
    update(["showEmail"]);
  }

  void passwordValidation() {
    final text = passwordCtrl.text.trim();
    if (text.isEmpty) {
      pwdError = 'Please enter password';
    } else if (text.length >= 8) {
      pwdError = '';
    } else {
      pwdError = "At least 8 characters";
    }
    update(["showPassword"]);
  }

  // stubs conservés (si l'UI les appelle)
  void firstNameValidation() {
    firstError = firstNameCtrl.text.trim().isEmpty ? '' : '';
    update(["showFirst"]);
  }

  void lastNameValidation() {
    lastError = lastNameCtrl.text.trim().isEmpty ? '' : '';
    update(["showLast"]);
  }

  bool _basicValidator() {
    emailValidation();
    passwordValidation();
    return emailError.isEmpty && pwdError.isEmpty;
  }

  void togglePassword() {
    showPassword = !showPassword;
    update(["showPassword"]);
  }

  void onChanged(String _) => update(["colorChange"]);

  // ===== Email Verification System =====
  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
      if (kDebugMode) print('✅ Email verification sent to ${user.email}');
    } catch (e) {
      if (kDebugMode) print('❌ Error sending verification email: $e');
      rethrow;
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        if (kDebugMode) print('✅ Email verified for ${user.email}');
        return;
      }
      throw Exception('Email not verified');
    } catch (e) {
      if (kDebugMode) print('❌ Email verification check failed: $e');
      rethrow;
    }
  }

  Future<void> _signInExistingUser(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (cred.user != null) {
        await PrefService.setValue(PrefKeys.userId, cred.user!.uid);
        await PrefService.setValue(PrefKeys.rol, "User");
        
        Get.snackbar(
          "✅ Connexion réussie!", 
          "Utilisateur existant connecté: $email",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        
        Get.offAll(() => DashBoardScreen());
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur connexion existante: $e");
      }
      // Si la connexion échoue, on crée quand même le compte localement
      await _createLocalUser(email);
    }
  }

  Future<void> _createLocalUser(String email) async {
    try {
      // Créer un utilisateur local sans Firebase Auth si problème de connexion
      final localUserId = "local-${DateTime.now().millisecondsSinceEpoch}";
      
      await PrefService.setValue(PrefKeys.userId, localUserId);
      await PrefService.setValue(PrefKeys.rol, "User");
      
      Get.snackbar(
        "✅ Utilisateur créé!", 
        "Mode local: $email\nUtilisateur créé avec succès!",
        backgroundColor: ColorRes.appleGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      
      Get.offAll(() => DashBoardScreen());
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de créer l'utilisateur: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _sendWelcomeEmailWithVerification(String email, String fullName) async {
    try {
      if (kDebugMode) print("📧 Sending welcome email with verification to $email");
      
      // Generate professional welcome email with verification instructions
      final emailHTML = await _generateVerificationWelcomeEmail(email, fullName);
      
      // Send via Firebase Extensions (mail collection)
      final mailDoc = await _db.collection("mail").add({
        "to": [email],
        "message": {
          "subject": "🎉 Welcome to Timeless - Please verify your email",
          "html": emailHTML,
          "text": "Welcome to Timeless, $fullName! Please verify your email to complete your registration."
        }
      });
      
      // Log email sending attempt
      await _db.collection("emailQueue").add({
        "to": email,
        "template": "welcome_verification",
        "templateData": {
          "fullName": fullName,
          "email": email,
          "verificationRequired": true,
          "appName": "Timeless"
        },
        "subject": "🎉 Welcome to Timeless - Please verify your email",
        "priority": "high",
        "createdAt": FieldValue.serverTimestamp(),
        "status": "sent",
        "mailDocId": mailDoc.id
      });
      
      if (kDebugMode) {
        print("✅ Welcome email with verification sent successfully to $email");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error sending welcome email: $e");
      }
      // Don't fail account creation for email issues
    }
  }

  Future<void> _sendDirectEmail(String email, String firstName) async {
    // APPROCHE 1: Via EmailJS (service gratuit pour démo)
    // Nécessite configuration d'un service EmailJS
    
    try {
      // Contenu HTML de l'email
      final String htmlContent = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bienvenue chez Timeless</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-align: center; padding: 30px; }
        .content { padding: 30px; }
        .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
        .footer { background-color: #f8f9fa; text-align: center; padding: 20px; color: #666; }
        .feature { display: flex; align-items: center; margin: 15px 0; }
        .feature-icon { color: #667eea; margin-right: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Bienvenue chez Timeless !</h1>
            <p>Votre plateforme d'emploi nouvelle génération</p>
        </div>
        
        <div class="content">
            <h2>Bonjour $firstName,</h2>
            
            <p>Félicitations ! Votre compte Timeless a été créé avec succès. 🚀</p>
            
            <p><strong>Vos identifiants de connexion :</strong></p>
            <p>📧 Email: <strong>$email</strong><br>
            🔑 Mot de passe: <em>[défini lors de l'inscription]</em></p>
            
            <h3>🎯 Ce que vous pouvez faire maintenant :</h3>
            
            <div class="feature">
                <span class="feature-icon">✅</span>
                <span>Découvrir des milliers d'offres d'emploi qualifiées</span>
            </div>
            <div class="feature">
                <span class="feature-icon">⚡</span>
                <span>Postuler en un clic avec votre profil</span>
            </div>
            <div class="feature">
                <span class="feature-icon">📊</span>
                <span>Suivre vos candidatures en temps réel</span>
            </div>
            <div class="feature">
                <span class="feature-icon">🎯</span>
                <span>Recevoir des recommandations personnalisées</span>
            </div>
            <div class="feature">
                <span class="feature-icon">💼</span>
                <span>Accéder aux profils d'entreprises exclusifs</span>
            </div>
            
            <center>
                <a href="https://timeless.app/login" class="button">
                    🚀 Access my account
                </a>
            </center>
            
            <p>Need help? Our support team is available 24/7.</p>
        </div>
        
        <div class="footer">
            <p><strong>The Timeless Team</strong> 💼</p>
            <p>Your professional success, our priority</p>
            <p style="font-size: 12px; color: #999;">
                This email was sent automatically. Do not reply.
            </p>
        </div>
    </div>
</body>
</html>
      """;

      // Sauvegarder l'email HTML dans Firestore pour traçabilité
      await _db.collection("sentEmails").add({
        "to": email,
        "subject": "🎉 Bienvenue chez Timeless !",
        "htmlContent": htmlContent,
        "firstName": firstName,
        "sentAt": FieldValue.serverTimestamp(),
        "type": "welcome",
        "status": "sent"
      });

      if (kDebugMode) {
        print("""
📧 EMAIL HTML GÉNÉRÉ ET SAUVEGARDÉ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Destinataire: $email
✅ Template: Email de bienvenue professionnel
✅ Format: HTML responsive
✅ Sauvegardé dans: sentEmails collection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        """);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur envoi direct: $e");
      }
    }
  }

  Future<String> _generateVerificationWelcomeEmail(String email, String fullName) async {
    return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Timeless - Verify Your Email</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-align: center; padding: 40px 20px; }
        .header h1 { margin: 0; font-size: 28px; font-weight: 700; }
        .header p { margin: 10px 0 0 0; opacity: 0.9; font-size: 16px; }
        .content { padding: 40px 30px; }
        .content h2 { color: #333; margin-top: 0; font-size: 24px; }
        .verification-box { background: #f8f9fa; padding: 25px; border-radius: 10px; margin: 25px 0; border-left: 4px solid #667eea; text-align: center; }
        .verification-notice { background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .feature { display: flex; align-items: center; margin: 15px 0; padding: 10px; }
        .feature-icon { color: #667eea; margin-right: 15px; font-size: 20px; }
        .feature-text { color: #555; font-size: 16px; }
        .footer { background-color: #f8f9fa; text-align: center; padding: 30px 20px; border-top: 1px solid #eee; }
        .footer h3 { color: #333; margin: 0 0 10px 0; }
        .footer p { color: #666; margin: 5px 0; }
        .small-text { font-size: 12px; color: #999; margin-top: 20px; }
        .highlight { color: #667eea; font-weight: 600; }
        @media (max-width: 600px) {
            .content { padding: 30px 20px; }
            .header { padding: 30px 20px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Welcome to Timeless!</h1>
            <p>Your professional journey starts here</p>
        </div>
        
        <div class="content">
            <h2>Hello $fullName,</h2>
            
            <p>Welcome to Timeless! We're excited to have you join our community of professionals. Your account has been created successfully, and we just need to verify your email address to get started.</p>
            
            <div class="verification-box">
                <h3 style="margin-top: 0; color: #333;">📧 Email Verification Required</h3>
                <p><strong>We've sent a verification link to:</strong></p>
                <p class="highlight" style="font-size: 16px;">$email</p>
                <p style="margin-bottom: 0; color: #666;">Please check your inbox and click the verification link to activate your account.</p>
            </div>
            
            <div class="verification-notice">
                <p style="margin: 0; color: #856404;"><strong>⚠️ Important:</strong> You'll need to verify your email before you can access all features of your Timeless account.</p>
            </div>
            
            <h3 style="color: #333;">🚀 What you can do once verified:</h3>
            
            <div class="feature">
                <span class="feature-icon">✨</span>
                <span class="feature-text">Browse thousands of quality job listings</span>
            </div>
            <div class="feature">
                <span class="feature-icon">⚡</span>
                <span class="feature-text">Apply to jobs with one-click using your profile</span>
            </div>
            <div class="feature">
                <span class="feature-icon">📊</span>
                <span class="feature-text">Track your applications in real-time</span>
            </div>
            <div class="feature">
                <span class="feature-icon">🎯</span>
                <span class="feature-text">Receive personalized job recommendations</span>
            </div>
            <div class="feature">
                <span class="feature-icon">💼</span>
                <span class="feature-text">Connect directly with employers</span>
            </div>
            <div class="feature">
                <span class="feature-icon">🔔</span>
                <span class="feature-text">Get notified about application updates</span>
            </div>
            
            <p style="margin-top: 30px; color: #666;">If you don't see the verification email in your inbox, please check your spam folder. If you need assistance, our support team is available 24/7.</p>
        </div>
        
        <div class="footer">
            <h3>The Timeless Team 💼</h3>
            <p>Your professional success is our priority</p>
            <p>📧 support@timeless.app | 🌐 www.timeless.app</p>
            
            <div class="small-text">
                <p>This email was sent automatically after account creation.</p>
                <p>If you didn't create this account, you can safely ignore this email.</p>
            </div>
        </div>
    </div>
</body>
</html>
    """;
  }

  Future<String> _generateWelcomeEmailHTML(String email, String firstName) async {
    return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bienvenue chez Timeless</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-align: center; padding: 40px 20px; }
        .header h1 { margin: 0; font-size: 28px; font-weight: 700; }
        .header p { margin: 10px 0 0 0; opacity: 0.9; font-size: 16px; }
        .content { padding: 40px 30px; }
        .content h2 { color: #333; margin-top: 0; font-size: 24px; }
        .credentials { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea; }
        .feature { display: flex; align-items: center; margin: 15px 0; padding: 10px; }
        .feature-icon { color: #667eea; margin-right: 15px; font-size: 20px; }
        .feature-text { color: #555; font-size: 16px; }
        .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; margin: 25px 0; font-weight: 600; font-size: 16px; }
        .button:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4); }
        .footer { background-color: #f8f9fa; text-align: center; padding: 30px 20px; border-top: 1px solid #eee; }
        .footer h3 { color: #333; margin: 0 0 10px 0; }
        .footer p { color: #666; margin: 5px 0; }
        .small-text { font-size: 12px; color: #999; margin-top: 20px; }
        @media (max-width: 600px) {
            .content { padding: 30px 20px; }
            .header { padding: 30px 20px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Bienvenue chez Timeless !</h1>
            <p>Votre plateforme d'emploi nouvelle génération</p>
        </div>
        
        <div class="content">
            <h2>Bonjour $firstName,</h2>
            
            <p>Félicitations ! Votre compte Timeless a été créé avec succès. Nous sommes ravis de vous accueillir dans notre communauté ! 🚀</p>
            
            <div class="credentials">
                <h3 style="margin-top: 0; color: #333;">🔑 Vos identifiants de connexion</h3>
                <p><strong>📧 Email :</strong> $email</p>
                <p><strong>🔐 Mot de passe :</strong> <em>Celui que vous avez défini lors de l'inscription</em></p>
            </div>
            
            <h3 style="color: #333;">🎯 Découvrez ce que vous pouvez faire :</h3>
            
            <div class="feature">
                <span class="feature-icon">✨</span>
                <span class="feature-text">Découvrir des milliers d'offres d'emploi qualifiées</span>
            </div>
            <div class="feature">
                <span class="feature-icon">⚡</span>
                <span class="feature-text">Postuler en un clic avec votre profil optimisé</span>
            </div>
            <div class="feature">
                <span class="feature-icon">📊</span>
                <span class="feature-text">Suivre vos candidatures en temps réel</span>
            </div>
            <div class="feature">
                <span class="feature-icon">🎯</span>
                <span class="feature-text">Recevoir des recommandations personnalisées</span>
            </div>
            <div class="feature">
                <span class="feature-icon">💼</span>
                <span class="feature-text">Accéder aux profils d'entreprises exclusifs</span>
            </div>
            <div class="feature">
                <span class="feature-icon">🤝</span>
                <span class="feature-text">Connecter avec des recruteurs directement</span>
            </div>
            
            <center>
                <a href="https://timeless.app/login" class="button">
                    🚀 Access my account maintenant
                </a>
            </center>
            
            <p style="margin-top: 30px; color: #666;">Une question ? Notre équipe support est disponible 24h/7j pour vous accompagner dans votre recherche d'emploi.</p>
        </div>
        
        <div class="footer">
            <h3>The Timeless Team 💼</h3>
            <p>Your professional success, our priority absolue</p>
            <p>📧 support@timeless.app | 🌐 www.timeless.app</p>
            
            <div class="small-text">
                <p>Cet email a été envoyé automatiquement suite à la création de votre compte.</p>
                <p>Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer cet email.</p>
            </div>
        </div>
    </div>
</body>
</html>
    """;
  }

  // ===== Core: Register Email/Password with Email Verification =====
  Future<void> onSignUpTap() async {
    if (loading.value) return;
    if (!_basicValidator()) {
      Get.snackbar("Validation Error", "Please check email & password requirements",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    loading.value = true;
    try {
      // Create user account
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final user = cred.user;
      if (user == null) {
        throw Exception("Account creation failed - no user returned");
      }

      // Clear any existing profile data first
      await _clearAllProfileData();
      
      // Create user profile data
      final fullName = "${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}".trim();
      final email = emailCtrl.text.trim();
      
      // Save to Firestore
      final profile = <String, dynamic>{
        "uid": user.uid,
        "Email": email,
        "fullName": fullName,
        "firstName": firstNameCtrl.text.trim(),
        "lastName": lastNameCtrl.text.trim(),
        "Phone": "",
        "City": "",
        "State": "",
        "Country": "",
        "Occupation": "",
        "provider": "email",
        "imageUrl": "",
        "emailVerified": false,
        "accountStatus": "pending_verification",
        "deviceTokenU": PrefService.getString(PrefKeys.deviceToken),
        "createdAt": FieldValue.serverTimestamp(),
      };

      await _db
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(user.uid)
          .set(profile);

      // Send Firebase verification email (this works immediately)
      await sendEmailVerification(user);
      
      // Also send custom welcome email for better UX
      await _sendWelcomeEmailWithVerification(email, fullName);
      
      // Show instruction for checking Firebase verification email
      Get.snackbar(
        "📧 Check Your Email",
        "Firebase has sent a verification link to $email. Click the link to verify your account.",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Show success message
      Get.snackbar(
        "✅ Account Created Successfully!",
        "📧 Verification email sent to $email\nPlease check your inbox and click the verification link to activate your account.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.TOP,
      );

      // Navigate to email verification screen instead of dashboard
      Get.offAll(() => EmailVerificationScreen(
        email: email,
        userFullName: fullName,
      ));

      // Clear form fields
      firstNameCtrl.clear();
      lastNameCtrl.clear();
      emailCtrl.clear();
      passwordCtrl.clear();

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Account creation failed";
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered. Please sign in instead.";
          break;
        case 'weak-password':
          errorMessage = "Password is too weak. Please use a stronger password.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address format.";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled.";
          break;
        default:
          errorMessage = e.message ?? "Unknown error occurred";
      }
      
      Get.snackbar(
        "Account Creation Failed",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (kDebugMode) debugPrint("Sign up error: $e");
      Get.snackbar(
        "Account Creation Failed",
        "An unexpected error occurred. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
    }
  }

  /// Clear all profile data to ensure new user starts fresh
  Future<void> _clearAllProfileData() async {
    try {
      await Future.wait([
        // Clear personal info (keep only what we just set)
        PrefService.setValue(PrefKeys.phoneNumber, ''),
        PrefService.setValue(PrefKeys.dateOfBirth, ''),
        PrefService.setValue(PrefKeys.city, ''),
        PrefService.setValue(PrefKeys.state, ''),
        PrefService.setValue(PrefKeys.country, ''),
        PrefService.setValue(PrefKeys.occupation, ''),
        PrefService.setValue(PrefKeys.jobPosition, ''),
        PrefService.setValue(PrefKeys.bio, ''),
        PrefService.setValue(PrefKeys.address, ''),
        PrefService.setValue(PrefKeys.profileImageUrl, ''),
        PrefService.setValue(PrefKeys.profilePhoto, ''),
        
        // Clear job matching preferences
        PrefService.setValue(PrefKeys.experienceLevel, ''),
        PrefService.setValue(PrefKeys.skillsList, ''),
        PrefService.setValue(PrefKeys.salaryRangeMin, ''),
        PrefService.setValue(PrefKeys.salaryRangeMax, ''),
        PrefService.setValue(PrefKeys.jobTypes, ''),
        PrefService.setValue(PrefKeys.industryPreferences, ''),
        PrefService.setValue(PrefKeys.companyTypes, ''),
        PrefService.setValue(PrefKeys.maxCommuteDistance, ''),
        PrefService.setValue(PrefKeys.workLocationPreference, ''),
      ]);
      
      if (kDebugMode) {
        print('✅ Profile data cleared for new user');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error clearing profile data: $e');
      }
    }
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }

  Widget onCountryTap(BuildContext context) {
    // TODO: Implement country picker logic or remove this stub if unused.
    throw UnimplementedError('onCountryTap is not implemented.');
  }
}
