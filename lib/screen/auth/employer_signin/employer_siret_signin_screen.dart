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

class EmployerSiretSignInScreen extends StatefulWidget {
  const EmployerSiretSignInScreen({super.key});

  @override
  State<EmployerSiretSignInScreen> createState() => _EmployerSiretSignInScreenState();
}

class _EmployerSiretSignInScreenState extends State<EmployerSiretSignInScreen> {
  final TextEditingController siretController = TextEditingController();
  final UnifiedTranslationService translationService = UnifiedTranslationService.instance;
  bool isLoading = false;

  @override
  void dispose() {
    siretController.dispose();
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
                    height: 80,
                    width: 80,
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
                    'Connexion par SIRET',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),

                Center(
                  child: Text(
                    'Saisissez votre numéro SIRET pour accéder à votre espace employeur',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorRes.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // Champ SIRET
                Text(
                  'Code SIRET *',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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
                    controller: siretController,
                    keyboardType: TextInputType.number,
                    maxLength: 14,
                    decoration: InputDecoration(
                      hintText: 'Ex: 12345678901234',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000647).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: Color(0xFF000647),
                        ),
                      ),
                    ),
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Information
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber[700],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Le SIRET est un identifiant unique de 14 chiffres attribué à chaque établissement d\'entreprise en France.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.amber[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Bouton de connexion
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signInWithSiret,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Se connecter',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lien vers l'autre méthode
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Utiliser une autre méthode de connexion',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
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

  Future<void> _signInWithSiret() async {
    final siret = siretController.text.trim();
    
    if (siret.isEmpty) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Champ requis",
        message: "Veuillez saisir votre code SIRET",
        isError: true,
      );
      return;
    }

    if (siret.length != 14) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ SIRET invalide",
        message: "Le code SIRET doit contenir exactement 14 chiffres",
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Rechercher l'employeur avec ce SIRET dans Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('employers')
          .where('siretCode', isEqualTo: siret)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        AppTheme.showStandardSnackBar(
          title: "❌ Compte non trouvé",
          message: "Aucun compte employeur trouvé avec ce SIRET. Veuillez créer un compte d'abord.",
          isError: true,
        );
        return;
      }

      final employerDoc = querySnapshot.docs.first;
      final employerData = employerDoc.data();
      
      // Récupérer l'email associé à ce compte
      final email = employerData['email'];
      
      if (email == null) {
        AppTheme.showStandardSnackBar(
          title: "❌ Erreur",
          message: "Données de compte incomplètes. Contactez le support.",
          isError: true,
        );
        return;
      }

      // Afficher une boîte de dialogue pour saisir le mot de passe
      _showPasswordDialog(email, employerDoc.id);

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

  void _showPasswordDialog(String email, String uid) {
    final passwordController = TextEditingController();
    bool isPasswordLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Mot de passe requis',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compte trouvé pour: $email',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Mot de passe:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Saisissez votre mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isPasswordLoading ? null : () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isPasswordLoading ? null : () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  AppTheme.showStandardSnackBar(
                    title: "⚠️ Champ requis",
                    message: "Veuillez saisir votre mot de passe",
                    isError: true,
                  );
                  return;
                }

                setDialogState(() {
                  isPasswordLoading = true;
                });

                try {
                  // Connexion Firebase Auth
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  Navigator.of(context).pop(); // Fermer la dialog
                  
                  AppTheme.showStandardSnackBar(
                    title: "✅ Connexion réussie",
                    message: "Bienvenue dans votre espace employeur!",
                    isError: false,
                  );

                  // Redirection vers le dashboard employeur (à adapter selon votre routing)
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                } on FirebaseAuthException catch (e) {
                  String message;
                  switch (e.code) {
                    case 'wrong-password':
                      message = 'Mot de passe incorrect';
                      break;
                    case 'user-not-found':
                      message = 'Compte non trouvé';
                      break;
                    case 'invalid-email':
                      message = 'Email invalide';
                      break;
                    case 'user-disabled':
                      message = 'Compte désactivé';
                      break;
                    default:
                      message = 'Erreur de connexion: ${e.message}';
                  }
                  AppTheme.showStandardSnackBar(
                    title: "❌ Erreur",
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
                  setDialogState(() {
                    isPasswordLoading = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000647),
                foregroundColor: Colors.white,
              ),
              child: isPasswordLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Se connecter',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}