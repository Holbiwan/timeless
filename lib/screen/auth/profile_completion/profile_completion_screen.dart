import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/language_toggle.dart';
import 'package:timeless/screen/auth/profile_completion/profile_completion_controller.dart';
import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/service/google_auth_service.dart';
import 'package:timeless/service/translation_service.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final ProfileCompletionController controller = Get.put(ProfileCompletionController());
  final TranslationService _translationService = TranslationService.instance;

  @override
  void initState() {
    super.initState();
    controller.initializeWithGoogleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          final isLoading = controller.loading.value;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Header avec langue et options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Profile avatar
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: controller.userPhotoUrl.value.isNotEmpty
                              ? NetworkImage(controller.userPhotoUrl.value)
                              : null,
                          child: controller.userPhotoUrl.value.isEmpty
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                        
                        // Language toggle + Menu
                        Row(
                          children: [
                            // Toggle de langue
                            const LanguageToggle(),
                            const SizedBox(width: 12),
                            
                            // Bouton de déconnexion/changement de compte
                            PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: ColorRes.primaryAccent),
                          onSelected: (String value) async {
                            if (value == 'switch_account') {
                              await _switchAccount();
                            } else if (value == 'logout') {
                              await _logout();
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'switch_account',
                              child: Row(
                                children: [
                                  const Icon(Icons.swap_horiz, size: 20),
                                  const SizedBox(width: 8),
                                  Obx(() => Text(_translationService.getText('switch_account'))),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  const Icon(Icons.logout, size: 20),
                                  const SizedBox(width: 8),
                                  Obx(() => Text(_translationService.getText('sign_out'))),
                                ],
                              ),
                            ),
                          ],
                        ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Titre de bienvenue
                    Obx(() => Text(
                      _translationService.getText('welcome_user')
                          .replaceAll('{name}', controller.firstName.value),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: ColorRes.textPrimary,
                      ),
                    )),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                      _translationService.getText('complete_profile_description'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ColorRes.textSecondary,
                      ),
                    )),

                    const SizedBox(height: 30),

                    // Informations de base
                    _buildSectionTitle('Informations personnelles'),
                    const SizedBox(height: 16),

                    // Prénom
                    _buildTextField(
                      label: 'Prénom',
                      controller: controller.firstNameController,
                      required: true,
                    ),

                    const SizedBox(height: 16),

                    // Nom
                    _buildTextField(
                      label: 'Nom',
                      controller: controller.lastNameController,
                      required: true,
                    ),

                    const SizedBox(height: 16),

                    // Téléphone
                    _buildTextField(
                      label: 'Téléphone',
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 30),

                    // Informations professionnelles
                    _buildSectionTitle('Profil professionnel'),
                    const SizedBox(height: 16),

                    // Titre/Poste recherché
                    _buildTextField(
                      label: 'Poste recherché',
                      controller: controller.titleController,
                      hintText: 'Ex: Développeur Flutter, Designer UX...',
                    ),

                    const SizedBox(height: 16),

                    // Niveau d'expérience
                    Text(
                      'Niveau d\'expérience',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorRes.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: ColorRes.borderColor.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 0,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedExperience.value,
                          isExpanded: true,
                          items: [
                            'internship',
                            'junior',
                            'mid',
                            'senior',
                            'expert'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                controller.getExperienceLabel(value),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: ColorRes.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.selectedExperience.value = newValue;
                            }
                          },
                        ),
                      ),
                    )),

                    const SizedBox(height: 16),

                    // Localisation
                    _buildTextField(
                      label: 'Ville',
                      controller: controller.cityController,
                      hintText: 'Ex: Paris, Lyon, Remote...',
                    ),

                    const SizedBox(height: 16),

                    // Bio courte
                    _buildTextField(
                      label: 'Bio (optionnel)',
                      controller: controller.bioController,
                      maxLines: 3,
                      hintText: 'Décrivez-vous en quelques mots...',
                    ),

                    const SizedBox(height: 40),

                    // Boutons d'action
                    Row(
                      children: [
                        // Ignorer (temporairement)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _skipForNow,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: ColorRes.primaryAccent),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Ignorer pour le moment',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorRes.primaryAccent,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Terminer
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _completeProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorRes.primaryAccent,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Terminer',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Loader
              if (isLoading) const CommonLoader(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ColorRes.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorRes.textPrimary,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(fontSize: 15, color: ColorRes.starColor),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 2),
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 8,
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorRes.borderColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              hintText: hintText ?? label,
              filled: true,
              fillColor: Colors.transparent,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorRes.textSecondary.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ColorRes.primaryAccent,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _switchAccount() async {
    try {
      controller.loading.value = true;
      
      // Déconnecter le compte actuel
      await GoogleAuthService.signOut();
      
      // Relancer la connexion Google (permettra de choisir un autre compte)
      final user = await GoogleAuthService.signInWithGoogle();
      
      if (user != null) {
        // Mettre à jour les données avec le nouveau compte
        controller.initializeWithGoogleData();
        Get.snackbar(
          "Compte changé",
          "Connecté avec ${user.email}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue[100],
          colorText: Colors.blue[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de changer de compte",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      controller.loading.value = false;
    }
  }

  Future<void> _logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Déconnexion',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: ColorRes.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Se déconnecter',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        controller.loading.value = true;
        await GoogleAuthService.signOut();
        Get.snackbar(
          "Déconnexion",
          "Vous avez été déconnecté",
          snackPosition: SnackPosition.TOP,
        );
        // Retourner à l'écran de connexion
        Get.offAllNamed('/'); // ou votre route de première page
      } catch (e) {
        Get.snackbar(
          "Erreur",
          "Impossible de se déconnecter",
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        controller.loading.value = false;
      }
    }
  }

  Future<void> _skipForNow() async {
    // Aller directement au dashboard sans compléter le profil
    Get.offAll(() => DashBoardScreen());
  }

  Future<void> _completeProfile() async {
    if (controller.firstNameController.text.trim().isEmpty ||
        controller.lastNameController.text.trim().isEmpty) {
      Get.snackbar(
        "Informations manquantes",
        "Prénom et nom sont requis",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      return;
    }

    try {
      controller.loading.value = true;
      
      // Sauvegarder les informations complètes
      await controller.saveProfileData();
      
      Get.snackbar(
        "Profil complété !",
        "Bienvenue sur Timeless",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
      
      // Aller au dashboard
      Get.offAll(() => DashBoardScreen());
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de sauvegarder le profil",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      controller.loading.value = false;
    }
  }
}