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
      backgroundColor: const Color(0xFF000647),
      appBar: AppBar(
        title:
            const Text('Edit profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF000647),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF000647), width: 2.0),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
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
                    Center(child: _buildAvatar()),
                    const SizedBox(height: 16),

                    // -------- Photo Upload Buttons --------
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Caméra',
                                style: appTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () => controller.ontap(),
                                  icon: const Icon(Icons.photo_camera),
                                  label: const Text('Photo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF000647),
                                    side: const BorderSide(
                                        color: Color(0xFF000647), width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Galerie',
                                style: appTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () => controller.ontapGallery(),
                                  icon:
                                      const Icon(Icons.photo_library_outlined),
                                  label: const Text('Galerie'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF000647),
                                    side: const BorderSide(
                                        color: Color(0xFF000647), width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // -------- PERSONAL INFORMATION --------
                    _buildSectionTitle('Informations personnelles'),
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
                      label: 'Date de naissance',
                      controller: controller.dateOfBirthController,
                      hint: 'JJ/MM/AAAA',
                    ),

                    // -------- LOCATION --------
                    _buildSectionTitle('Localisation'),
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

                    // -------- PROFESSIONAL INFORMATION --------
                    _buildSectionTitle('Informations professionnelles'),
                    _buildFormField(
                      label: 'Profession actuelle',
                      controller: controller.occupationController,
                      hint: 'Développeur, Designer, etc.',
                    ),

                    _buildFormField(
                      label: 'Poste actuel',
                      controller: controller.jobPositionController,
                      hint: 'Chef de projet, Lead Developer, etc.',
                    ),

                    _buildFormField(
                      label: 'Niveau d\'expérience',
                      controller: controller.experienceLevelController,
                      hint: 'junior, mid-level, senior, lead...',
                    ),

                    _buildFormField(
                      label: 'À propos',
                      controller: controller.bioController,
                      hint: 'Parlez-nous de vous...',
                      maxLines: 3,
                    ),

                    // -------- SKILLS --------
                    _buildSectionTitle('Compétences'),
                    _buildFormField(
                      label: 'Compétences (séparées par des virgules)',
                      controller: controller.skillsController,
                      hint: 'Flutter, Dart, JavaScript, Python...',
                    ),

                    // -------- SALARY EXPECTATIONS --------
                    _buildSectionTitle('Attentes salariales'),
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

                    // -------- CV Upload Section --------
                    Text(
                      'Télécharger CV',
                      style: appTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GetBuilder<ProfileUserController>(
                      id: 'cv_section',
                      builder: (controller) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF000647), width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.description,
                                      color: Color(0xFF000647)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'CV Upload',
                                    style: appTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (controller.cvFileName.value.isEmpty)
                                // Bouton d'upload
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: controller.pickCVFile,
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text(
                                        'Upload CV (PDF, DOC, DOCX)'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF000647),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                )
                              else
                                // CV uploadé
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          controller.cvFileName.value,
                                          style: appTextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: controller.removeCVFile,
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        tooltip: 'Remove CV',
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // -------- Save button --------
                    Text(
                      'Sauvegarder',
                      style: appTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                              color: Color(0xFF000647), width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: appTextStyle(
                              color: Colors.black,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
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
        Text(label,
            style: appTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 8),
        maxLines > 1
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF000647), width: 2),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType ?? TextInputType.text,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF000647), width: 2),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType ?? TextInputType.text,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Build avatar in priority:
  // 1) fbImageUrl (Network)
  // 2) image local File
  // 3) placeholder Asset
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
            BoxShadow(
                blurRadius: 4, offset: Offset(0, 2), color: Colors.black12)
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
