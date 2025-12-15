import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/common/widgets/universal_back_fab.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/app_res.dart';

class EmployerApeSignInScreen extends StatefulWidget {
  const EmployerApeSignInScreen({super.key});

  @override
  State<EmployerApeSignInScreen> createState() => _EmployerApeSignInScreenState();
}

class _EmployerApeSignInScreenState extends State<EmployerApeSignInScreen> {
  final TextEditingController apeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UnifiedTranslationService translationService = UnifiedTranslationService.instance;
  bool isLoading = false;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    apeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: Stack(
        children: [
          Container(
            width: Get.width,
            height: Get.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorRes.backgroundColor,
                  ColorRes.surfaceColor,
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                
                // Logo
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.shadowRegular,
                    ),
                    child: const Image(image: AssetImage(AssetRes.logo)),
                  ),
                ),
                const SizedBox(height: 30),

                // Titre
                Center(
                  child: Text(
                    'Secure Connection',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),

                Center(
                  child: Text(
                    'APE Code + Email + Password',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorRes.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Champ Code APE
                Text(
                  'Code APE *',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF000647), width: 2.0),
                  ),
                  child: TextFormField(
                    controller: apeController,
                    decoration: InputDecoration(
                      hintText: 'Ex: 6201Z',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000647).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.code,
                          color: Color(0xFF000647),
                        ),
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Champ Email
                Text(
                  'Email professionnel *',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF000647), width: 2.0),
                  ),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'contact@votre-entreprise.com',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000647).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.email,
                          color: Color(0xFF000647),
                        ),
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Champ Mot de passe
                Text(
                  'Mot de passe *',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF000647), width: 2.0),
                  ),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: isPasswordHidden,
                    decoration: InputDecoration(
                      hintText: 'Votre mot de passe',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordHidden = !isPasswordHidden;
                              });
                            },
                            icon: Icon(
                              isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFF000647),
                            ),
                          ),
                        ],
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Information
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'We verify that your APE code and email address match a registered employer account.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton de connexion
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signInWithApe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Sign in',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Lien vers l'autre méthode
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Use another sign-in method',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF000647),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          
          // Bouton de retour
          const Positioned(
            top: 40,
            left: 20,
            child: UniversalBackFab(),
          ),
          
          // Loader
          if (isLoading) const CommonLoader(),
        ],
      ),
    );
  }

  Future<void> _signInWithApe() async {
    final ape = apeController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    // Validation des champs
    if (ape.isEmpty) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Champ requis",
        message: "Veuillez saisir votre code APE",
        isError: true,
      );
      return;
    }

    if (email.isEmpty) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Champ requis",
        message: "Veuillez saisir votre email",
        isError: true,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Email invalide",
        message: "Veuillez entrer un email valide",
        isError: true,
      );
      return;
    }

    if (password.isEmpty) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Champ requis",
        message: "Veuillez saisir votre mot de passe",
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Vérifier d'abord que l'email et le code APE correspondent dans Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('employers')
          .where('email', isEqualTo: email)
          .where('apeCode', isEqualTo: ape)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        AppTheme.showStandardSnackBar(
          title: "❌ Compte non trouvé",
          message: "Aucun compte employeur trouvé avec ces informations. Vérifiez votre code APE et votre email.",
          isError: true,
        );
        return;
      }

      // Si le compte existe, procéder à la connexion Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppTheme.showStandardSnackBar(
        title: "✅ Connexion réussie",
        message: "Bienvenue dans votre espace employeur!",
        isError: false,
      );

      // Redirection vers le dashboard employeur
      Get.offAllNamed(AppRes.employerDashboardScreen);

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        case 'user-not-found':
          message = 'Aucun compte trouvé avec cet email';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé';
          break;
        case 'too-many-requests':
          message = 'Trop de tentatives. Réessayez plus tard.';
          break;
        default:
          message = 'Erreur de connexion: ${e.message}';
      }
      AppTheme.showStandardSnackBar(
        title: "❌ Erreur de connexion",
        message: message,
        isError: true,
      );
    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "❌ Erreur",
        message: "Une erreur s'est produite: $e",
        isError: true,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}