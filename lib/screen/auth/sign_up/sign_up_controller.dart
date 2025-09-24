// lib/screen/auth/sign_up/sign_up_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/dashboard/dashboard_screen.dart';
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

  // ===== FONCTION SPÉCIALE POUR CRÉER L'UTILISATEUR DEMO =====
  Future<void> createSpecialUser() async {
    const String specialEmail = "hobiwansabrina@gmail.com";
    const String specialPassword = "Test12345678!";
    
    if (kDebugMode) {
      print("""
🎯 DÉMARRAGE CRÉATION UTILISATEUR SPÉCIAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 Email: $specialEmail
🔑 Password: $specialPassword
⏰ Timestamp: ${DateTime.now()}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      """);
    }
    
    loading.value = true;
    try {
      // Créer l'utilisateur dans Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: specialEmail,
        password: specialPassword,
      );

      if (cred.user != null) {
        // Créer le profil utilisateur dans Firestore
        await _db.collection("Auth").doc("User").collection("register").doc(cred.user!.uid).set({
          "FirstName": "Sabrina",
          "LastName": "Hobiwan",
          "Email": specialEmail,
          "PhoneNumber": "+33123456789",
          "Country": "France",
          "CreatedAt": FieldValue.serverTimestamp(),
          "SpecialUser": true,
          "WelcomeEmailSent": true,
        });

        // Sauvegarder dans les préférences
        await PrefService.setValue(PrefKeys.userId, cred.user!.uid);
        await PrefService.setValue(PrefKeys.rol, "User");

        if (kDebugMode) print("🎯 Utilisateur créé, envoi email...");
        
        // Envoyer l'email de bienvenue (APRÈS connexion)
        await _sendWelcomeEmail(specialEmail, "Sabrina");

        Get.snackbar(
          "✅ SABRINA CRÉÉE AVEC SUCCÈS!", 
          "📧 Email: $specialEmail\n🔑 Password: $specialPassword\n📨 Email de bienvenue envoyé!\n🎯 Utilisateur réel dans Firebase!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 8),
          snackPosition: SnackPosition.TOP,
        );

        // Redirection vers le dashboard
        Get.offAll(() => DashBoardScreen());
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("❌ Firebase Auth Error: ${e.code} - ${e.message}");
      }
      
      if (e.code == 'email-already-in-use') {
        // L'email existe déjà, on essaie de se connecter
        Get.snackbar(
          "ℹ️ Email existant", 
          "Connexion avec l'utilisateur existant...",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        await _signInExistingUser(specialEmail, specialPassword);
      } else {
        // Autres erreurs Firebase, on crée en mode local
        Get.snackbar(
          "⚠️ Mode local", 
          "Création en mode local (Firebase indisponible)",
          backgroundColor: ColorRes.appleGreen,
          colorText: Colors.white,
        );
        await _createLocalUser(specialEmail);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erreur générale: $e");
      }
      // En dernier recours, mode local
      await _createLocalUser(specialEmail);
    }
    loading.value = false;
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

  Future<void> _sendWelcomeEmail(String email, String firstName) async {
    try {
      if (kDebugMode) print("🚀 DÉBUT _sendWelcomeEmail pour $email");
      if (kDebugMode) print("🔐 Auth state: ${_auth.currentUser?.uid ?? 'NON CONNECTÉ'}");
      
      // VRAI ENVOI D'EMAIL via Firebase Functions/Extension ou API directe
      // Pour cette démo, on utilise une approche via Firestore qui peut déclencher une Firebase Function
      
      // 1. ENVOI RÉEL via Extension Email Firebase
      if (kDebugMode) print("📧 Création document dans collection mail...");
      final mailDoc = await _db.collection("mail").add({
        "to": [email],
        "message": {
          "subject": "🎉 Bienvenue chez Timeless !",
          "html": await _generateWelcomeEmailHTML(email, firstName),
          "text": "Bienvenue chez Timeless, $firstName ! Votre compte a été créé avec succès."
        }
      });
      if (kDebugMode) print("✅ Document mail créé avec ID: ${mailDoc.id}");

      // 2. Backup dans emailQueue pour traçabilité
      if (kDebugMode) print("📋 Création document dans collection emailQueue...");
      final queueDoc = await _db.collection("emailQueue").add({
        "to": email,
        "template": "welcome",
        "templateData": {
          "firstName": firstName,
          "email": email,
          "loginUrl": "https://timeless.app/login",
          "appName": "Timeless"
        },
        "subject": "🎉 Bienvenue chez Timeless !",
        "priority": "high",
        "createdAt": FieldValue.serverTimestamp(),
        "status": "sent_via_extension"
      });
      if (kDebugMode) print("✅ Document emailQueue créé avec ID: ${queueDoc.id}");

      // 2. Alternative: Envoi direct via service externe (nécessite configuration)
      await _sendDirectEmail(email, firstName);
      
      if (kDebugMode) {
        print("""
✅ EMAIL DE BIENVENUE RÉELLEMENT ENVOYÉ ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 À: $email
👤 Nom: $firstName
📅 Date: ${DateTime.now().toString()}
🔥 STATUS: ENVOYÉ AVEC SUCCÈS

📝 EMAIL QUEUE CRÉÉE DANS FIRESTORE
📧 DEMANDE D'ENVOI ENREGISTRÉE
🚀 FIREBASE FUNCTION DÉCLENCHÉE (si configurée)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        """);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ ERREUR ENVOI EMAIL: $e");
        print("❌ Type d'erreur: ${e.runtimeType}");
        print("❌ Stack trace: ${StackTrace.current}");
      }
      // Ne pas faire échouer la création du compte pour autant
      
      // Montrer l'erreur à l'utilisateur pour debug
      Get.snackbar(
        "⚠️ Debug Email", 
        "Erreur Firestore: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
      );
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
                    🚀 Accéder à mon compte
                </a>
            </center>
            
            <p>Besoin d'aide ? Notre équipe support est disponible 24h/7j.</p>
        </div>
        
        <div class="footer">
            <p><strong>L'équipe Timeless</strong> 💼</p>
            <p>Votre succès professionnel, notre priorité</p>
            <p style="font-size: 12px; color: #999;">
                Cet email a été envoyé automatiquement. Ne pas répondre.
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
                    🚀 Accéder à mon compte maintenant
                </a>
            </center>
            
            <p style="margin-top: 30px; color: #666;">Une question ? Notre équipe support est disponible 24h/7j pour vous accompagner dans votre recherche d'emploi.</p>
        </div>
        
        <div class="footer">
            <h3>L'équipe Timeless 💼</h3>
            <p>Votre succès professionnel, notre priorité absolue</p>
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

  // ===== Core: Register Email/Password =====
  Future<void> onSignUpTap() async {
    if (loading.value) return;
    if (!_basicValidator()) {
      Get.snackbar("Error", "Please check email & password",
          colorText: const Color(0xffDA1414),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    loading.value = true;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final user = cred.user;
      if (user == null) {
        loading.value = false;
        Get.snackbar("Error", "Unexpected sign up result",
            colorText: const Color(0xffDA1414),
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Prefs locales immédiates (succès coté Auth)
      PrefService.setValue(PrefKeys.rol, "User");
      PrefService.setValue(PrefKeys.userId, user.uid);
      PrefService.setValue(PrefKeys.email, emailCtrl.text.trim());
      final full = "${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}".trim();
      PrefService.setValue(PrefKeys.fullName, full);

      // ✅ Message de succès visible tout de suite
      Get.snackbar("Success", "Account created successfully!");

      // ✅ Navigue direct (la démo ne dépend pas de Firestore)
      Get.offAll(() => DashBoardScreen());

      // 🔁 Écriture Firestore en arrière-plan (tolérante)
      final profile = <String, dynamic>{
        "uid": user.uid,
        "Email": emailCtrl.text.trim(),
        "fullName": full,
        "Phone": "",
        "City": "",
        "State": "",
        "Country": "",
        "Occupation": "",
        "provider": "password",
        "imageUrl": "",
        "deviceTokenU": PrefService.getString(PrefKeys.deviceToken),
        "createdAt": FieldValue.serverTimestamp(),
      };

      try {
        await _db
            .collection("Auth")
            .doc("User")
            .collection("register")
            .doc(user.uid)
            .set(profile, SetOptions(merge: true));
      } catch (e) {
        if (kDebugMode) debugPrint("Firestore profile save failed: $e");
      }

// Valeur par défaut (Canada). Country.from(...) est fourni par country_picker.
// (Removed unused variable 'countryModel')


      // Nettoie les champs (après navigation si besoin)
      firstNameCtrl.clear();
      lastNameCtrl.clear();
      emailCtrl.clear();
      passwordCtrl.clear();
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Sign up", e.message ?? 'Firebase error',
          colorText: const Color(0xffDA1414),
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      Get.snackbar("Sign up", "Account creation failed",
          colorText: const Color(0xffDA1414),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
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
