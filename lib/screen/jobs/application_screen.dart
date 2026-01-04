import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/common/widgets/universal_app_bar.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/screen/jobs/application_controller.dart';
import 'package:timeless/utils/color_res.dart';
import 'dart:io';

class ApplicationScreen extends StatelessWidget {
  final JobOfferModel job;

  const ApplicationScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApplicationController(job));

    return TimelessScaffold(
      title: 'Candidature',
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête de l'offre
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorRes.darkGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorRes.darkGold.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Candidature pour:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: ColorRes.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorRes.black,
                            ),
                          ),
                          Text(
                            job.companyName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: ColorRes.darkGold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Informations personnelles
                    Text(
                      'Informations personnelles',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColorRes.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Prénom et Nom
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Prénom *',
                            controller.firstNameController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Prénom requis';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            'Nom *',
                            controller.lastNameController,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Nom requis';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Email
                    _buildTextField(
                      'Email *',
                      controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email requis';
                        }
                        if (!GetUtils.isEmail(value!)) {
                          return 'Format email invalide';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Téléphone
                    _buildTextField(
                      'Téléphone',
                      controller.phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    // Upload CV
                    Text(
                      'Curriculum Vitae',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColorRes.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(() => controller.selectedCvFile.value != null
                        ? _buildCvSelected(controller.selectedCvFile.value!, controller)
                        : _buildCvUpload(controller)),

                    const SizedBox(height: 16),

                    // Lettre de motivation
                    Text(
                      'Lettre de motivation',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColorRes.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Optionnel - Expliquez votre motivation pour ce poste',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ColorRes.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: controller.coverLetterController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Écrivez votre lettre de motivation ici...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorRes.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorRes.darkGold, width: 2),
                        ),
                        filled: true,
                        fillColor: ColorRes.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Informations supplémentaires
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorRes.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: ColorRes.darkGold, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Informations importantes',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorRes.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Votre CV sera envoyé directement au recruteur\n'
                            '• Vous recevrez un email de confirmation\n'
                            '• Le recruteur peut vous contacter sous 48h\n'
                            '• Vos informations restent confidentielles',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: ColorRes.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Boutons d'action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorRes.white,
              border: Border(top: BorderSide(color: ColorRes.borderColor)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Aperçu des informations
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorRes.darkGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: ColorRes.darkGold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => Text(
                          controller.applicationSummary,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: ColorRes.darkGold,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorRes.darkGold),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(color: ColorRes.darkGold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () => controller.submitApplication(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorRes.darkGold,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: controller.isSubmitting.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Envoyer ma candidature',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorRes.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorRes.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorRes.darkGold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorRes.errorColor, width: 2),
            ),
            filled: true,
            fillColor: ColorRes.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCvUpload(ApplicationController controller) {
    return InkWell(
      onTap: () => controller.pickCvFile(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: ColorRes.darkGold, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
          color: ColorRes.darkGold.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload, size: 48, color: ColorRes.darkGold),
            const SizedBox(height: 12),
            Text(
              'Cliquez pour sélectionner votre CV',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorRes.darkGold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF uniquement, maximum 5 MB',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: ColorRes.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCvSelected(File file, ApplicationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ColorRes.successColor),
        borderRadius: BorderRadius.circular(12),
        color: ColorRes.successColor.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: ColorRes.successColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.path.split('/').last,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
                Text(
                  '${(file.lengthSync() / 1024 / 1024).toStringAsFixed(1)} MB',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: ColorRes.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.removeCvFile(),
            icon: Icon(Icons.close, color: ColorRes.errorColor),
          ),
        ],
      ),
    );
  }
}