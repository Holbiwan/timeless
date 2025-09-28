import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/common/widgets/common_text_field.dart';
import 'package:timeless/common/widgets/common_error_box.dart';

// Import du contrôleur utilisateur avec champs vides
import 'package:timeless/screen/profile/edit_profile_user/profile_user_controller.dart';

class EditProfileUserScreen extends StatelessWidget {
  EditProfileUserScreen({super.key});

  final ProfileUserController controller =
      Get.isRegistered<ProfileUserController>()
          ? Get.find<ProfileUserController>()
          : Get.put(ProfileUserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit profile'),
        backgroundColor: ColorRes.containerColor,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Sauvegarde en cours...'),
                  ],
                ),
              )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // -------- Avatar --------
              Center(
                child: Stack(
                  children: [
                    _buildAvatar(),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Row(
                        children: [
                          _smallFab(
                            icon: Icons.photo_camera,
                            onTap: () => controller.ontap(), // camera
                          ),
                          const SizedBox(width: 8),
                          _smallFab(
                            icon: Icons.photo_library_outlined,
                            onTap: () => controller.ontapGallery(), // gallery
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // -------- Formulaire complet --------
              _buildFormField(
                label: 'Nom complet',
                controller: controller.fullNameController,
                hint: 'Votre nom complet',
              ),
              
              _buildFormField(
                label: 'Email',
                controller: controller.emailController,
                hint: 'votre.email@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              
              _buildFormField(
                label: 'Téléphone',
                controller: controller.phoneController,
                hint: '+33 6 12 34 56 78',
                keyboardType: TextInputType.phone,
              ),
              
              _buildFormField(
                label: 'Ville',
                controller: controller.cityController,
                hint: 'Paris',
              ),
              
              _buildFormField(
                label: 'Pays',
                controller: controller.countryController,
                hint: 'France',
              ),
              
              _buildFormField(
                label: 'Profession',
                controller: controller.occupationController,
                hint: 'Développeur, Designer, etc.',
              ),
              
              _buildFormField(
                label: 'À propos',
                controller: controller.bioController,
                hint: 'Parlez-nous de vous...',
                maxLines: 3,
              ),

              // Séparateur pour les données Smart Match
              const Divider(height: 32),
              Text(
                'Informations pour Smart Match',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorRes.primaryAccent,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildFormField(
                label: 'Compétences (séparées par des virgules)',
                controller: controller.skillsController,
                hint: 'Flutter, Dart, JavaScript, Python...',
              ),
              
              _buildFormField(
                label: 'Niveau d\'expérience',
                controller: controller.experienceLevelController,
                hint: 'junior, mid-level, senior, lead...',
              ),
              
              _buildFormField(
                label: 'Salaire minimum souhaité',
                controller: controller.salaryMinController,
                hint: '45000',
                keyboardType: TextInputType.number,
              ),
              
              _buildFormField(
                label: 'Salaire maximum souhaité',
                controller: controller.salaryMaxController,
                hint: '65000',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),

              // -------- Save button --------
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.EditTap,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(ColorRes.containerColor),
                  ),
                  child: Text(
                    'Save',
                    style: appTextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: appTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        maxLines > 1 
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorRes.borderColor),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType ?? TextInputType.text,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        : commonTextFormField(
            controller: controller,
            textDecoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            type: keyboardType,
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Build avatar in priority:
  /// 1) fbImageUrl (Network)
  /// 2) image local File
  /// 3) placeholder Asset
  Widget _buildAvatar() {
    final hasLocal = controller.image != null;

    // AVATAR VIDE par défaut - Pas de photo pré-chargée
    DecorationImage? img;
    if (hasLocal) {
      img = DecorationImage(
        image: FileImage(File(controller.image!.path)),
        fit: BoxFit.cover,
      );
    }
    // Pas d'image par défaut - cercle vide avec icône

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        image: img,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: img == null 
          ? Icon(
              Icons.person_add_outlined,
              size: 40,
              color: Colors.grey.shade500,
            )
          : null,
    );
  }

  Widget _smallFab({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: ColorRes.logoColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(blurRadius: 4, offset: Offset(0, 2), color: Colors.black12)
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
