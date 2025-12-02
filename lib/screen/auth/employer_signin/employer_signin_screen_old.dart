import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/common/widgets/universal_app_bar.dart';
import 'package:timeless/screen/auth/employer_signin/employer_signin_controller.dart';
import 'package:timeless/utils/color_res.dart';

class EmployerSignInScreen extends StatelessWidget {
  const EmployerSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmployerSignInController());

    return TimelessScaffold(
      title: 'Créer un compte PRO',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec icône pro
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ColorRes.royalBlue, ColorRes.royalBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: ColorRes.royalBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business_center,
                      color: ColorRes.royalBlue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Création compte PRO',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Rejoignez notre plateforme de recrutement',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Formulaire de connexion
            Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de la société
                  _buildInputSection(
                    'Nom de la société *',
                    controller.companyNameController,
                    Icons.business,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Le nom de la société est requis';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Adresse
                  _buildInputSection(
                    'Adresse (Numéro + Type de voie) *',
                    controller.addressController,
                    Icons.location_on,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'L\'adresse est requise';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Code postal
                  _buildInputSection(
                    'Code postal *',
                    controller.postalCodeController,
                    Icons.mail_outline,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Le code postal est requis';
                      }
                      if (value!.length != 5) {
                        return 'Le code postal doit contenir 5 chiffres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Pays
                  _buildInputSection(
                    'Pays *',
                    controller.countryController,
                    Icons.public,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Le pays est requis';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Code SIRET
                  _buildInputSection(
                    'Code SIRET (14 chiffres) *',
                    controller.siretController,
                    Icons.business_center,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Le code SIRET est requis';
                      }
                      if (value!.length != 14) {
                        return 'Le code SIRET doit contenir 14 chiffres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Code APE
                  _buildInputSection(
                    'Code APE *',
                    controller.apeController,
                    Icons.category,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Le code APE est requis';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Email
                  _buildInputSection(
                    'Email professionnel *',
                    controller.emailController,
                    Icons.email_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'L\'email est requis';
                      }
                      if (!GetUtils.isEmail(value!)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Mot de passe
                  Obx(() => _buildInputSection(
                    'Mot de passe *',
                    controller.passwordController,
                    Icons.lock_outline,
                    isPassword: true,
                    isObscure: controller.isPasswordHidden.value,
                    toggleVisibility: () => controller.togglePasswordVisibility(),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Le mot de passe est requis';
                      }
                      if (value!.length < 8) {
                        return 'Minimum 8 caractères';
                      }
                      return null;
                    },
                  )),

                  const SizedBox(height: 20),

                  // Confirmation mot de passe
                  Obx(() => _buildInputSection(
                    'Confirmer le mot de passe *',
                    controller.confirmPasswordController,
                    Icons.lock_outline,
                    isPassword: true,
                    isObscure: controller.isConfirmPasswordHidden.value,
                    toggleVisibility: () => controller.toggleConfirmPasswordVisibility(),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'La confirmation est requise';
                      }
                      if (value != controller.passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  )),

                  const SizedBox(height: 30),

                  // Bouton de création
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value 
                          ? null 
                          : () => controller.createEmployerAccount(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorRes.royalBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Créer mon compte PRO',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )),

                  const SizedBox(height: 20),

                  // Lien vers connexion
                  Center(
                    child: TextButton(
                      onPressed: () => controller.goToEmployerSignIn(),
                      child: Text(
                        'Déjà inscrit ? Se connecter',
                        style: GoogleFonts.poppins(
                          color: ColorRes.royalBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Info légale
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorRes.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'ℹ️ Votre code SIRET et APE permettent de vérifier automatiquement la légalité de votre entreprise selon la base INSEE.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: ColorRes.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorRes.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: ColorRes.royalBlue),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: ColorRes.royalBlue,
                    ),
                    onPressed: toggleVisibility,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorRes.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorRes.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorRes.royalBlue, width: 2),
            ),
            filled: true,
            fillColor: ColorRes.white,
          ),
        ),
      ],
    );
  }
}