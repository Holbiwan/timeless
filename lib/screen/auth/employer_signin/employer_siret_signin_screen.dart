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
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';

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
                    'SIRET Connection',
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
                    'Enter your SIRET number to access your employer space',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorRes.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Champ SIRET
                Text(
                  'SIRET Code *',
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
                    controller: siretController,
                    keyboardType: TextInputType.number,
                    maxLength: 14,
                    decoration: InputDecoration(
                      hintText: 'Ex: 12345678901234',
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
                          Icons.business,
                          color: Color(0xFF000647),
                        ),
                      ),
                    ),
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
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
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber[700],
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'SIRET is a unique 14-digit identifier assigned to each business establishment in France.',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color.fromRGBO(2, 2, 2, 1),
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
                      'Sign In',
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
                      'Use another connection method',
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
        title: "⚠️ Required Field",
        message: "Please enter your SIRET code",
        isError: true,
      );
      return;
    }

    if (siret.length != 14) {
      AppTheme.showStandardSnackBar(
        title: "⚠️ Invalid SIRET",
        message: "SIRET code must contain exactly 14 digits",
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
          title: "❌ Account Not Found",
          message: "No employer account found with this SIRET. Please create an account first.",
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
          title: "❌ Error",
          message: "Incomplete account data. Contact support.",
          isError: true,
        );
        return;
      }

      // Afficher une boîte de dialogue pour saisir le mot de passe
      _showPasswordDialog(email, employerDoc.id);

    } catch (e) {
      AppTheme.showStandardSnackBar(
        title: "❌ Error",
        message: "An error occurred: $e",
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
    bool isPasswordHidden = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Password Required',
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
                'Account found for: $email',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Password:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setPasswordState) => TextFormField(
                  controller: passwordController,
                  obscureText: isPasswordHidden,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setPasswordState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                      icon: Icon(
                        isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF000647),
                      ),
                    ),
                  ),
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
                'Cancel',
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
                    title: "⚠️ Required Field",
                    message: "Please enter your password",
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
                    title: "✅ Sign In Successful",
                    message: "Welcome to your employer space!",
                    isError: false,
                  );

                  // Redirection vers le dashboard employeur
                  await PreferencesService.setUserType('employer');
                  await PreferencesService.setString(PrefKeys.employerId, uid);
                  await PreferencesService.setValue(PrefKeys.isLogin, true);
                  
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close SIRET screen
                  Navigator.of(context).pop(); // Close choice screen
                  Get.offAllNamed(AppRes.employerDashboardScreen);

                } on FirebaseAuthException catch (e) {
                  String message;
                  switch (e.code) {
                    case 'wrong-password':
                      message = 'Incorrect password';
                      break;
                    case 'user-not-found':
                      message = 'Account not found';
                      break;
                    case 'invalid-email':
                      message = 'Invalid email';
                      break;
                    case 'user-disabled':
                      message = 'Account disabled';
                      break;
                    default:
                      message = 'Connection error: ${e.message}';
                  }
                  AppTheme.showStandardSnackBar(
                    title: "❌ Error",
                    message: message,
                    isError: true,
                  );
                } catch (e) {
                  AppTheme.showStandardSnackBar(
                    title: "❌ Error",
                    message: "An error occurred: $e",
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
                      'Sign In',
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