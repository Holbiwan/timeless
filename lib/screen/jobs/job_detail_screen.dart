import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/common/widgets/universal_app_bar.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/screen/jobs/job_detail_controller.dart';
import 'package:timeless/screen/jobs/application_screen.dart';
import 'package:timeless/utils/color_res.dart';

class JobDetailScreen extends StatelessWidget {
  final JobOfferModel job;

  const JobDetailScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobDetailController(job));

    return TimelessScaffold(
      title: 'Détail de l\'offre',
      actions: [
        IconButton(
          icon: Obx(() => Icon(
            controller.isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
            color: ColorRes.darkGold,
          )),
          onPressed: () => controller.toggleBookmark(),
        ),
        IconButton(
          icon: Icon(Icons.share, color: ColorRes.darkGold),
          onPressed: () => controller.shareJob(),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de l'offre
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ColorRes.darkGold.withOpacity(0.1),
                          ColorRes.orange.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: ColorRes.darkGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.business_center,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: ColorRes.black,
                                    ),
                                  ),
                                  Text(
                                    job.companyName,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: ColorRes.darkGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Informations clés
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildInfoBadge(Icons.location_on, job.location),
                            _buildInfoBadge(Icons.work, job.jobTypeDisplay),
                            _buildInfoBadge(Icons.star, job.experienceLevelDisplay),
                            _buildInfoBadge(Icons.business, job.industry),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Salaire
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColorRes.darkGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: ColorRes.darkGold.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.euro, color: ColorRes.darkGold),
                              const SizedBox(width: 8),
                              Text(
                                job.salaryDisplay,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ColorRes.darkGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Description
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          'Description du poste',
                          job.description,
                        ),

                        const SizedBox(height: 24),

                        // Compétences requises
                        if (job.skills.isNotEmpty) ...[
                          Text(
                            'Compétences requises',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ColorRes.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: job.skills.map((skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: ColorRes.darkGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: ColorRes.darkGold.withOpacity(0.3)),
                              ),
                              child: Text(
                                skill,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: ColorRes.darkGold,
                                ),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Exigences
                        if (job.requirements.isNotEmpty) ...[
                          Text(
                            'Exigences',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ColorRes.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...job.requirements.map((requirement) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: ColorRes.darkGold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    requirement,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: ColorRes.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          const SizedBox(height: 24),
                        ],

                        // Informations sur l'entreprise
                        _buildSection(
                          'À propos de ${job.companyName}',
                          'Rejoignez une équipe dynamique et innovante dans le secteur ${job.industry}. Nous offrons un environnement de travail stimulant avec de nombreuses opportunités de développement.',
                        ),

                        const SizedBox(height: 24),

                        // Date de publication et deadline
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ColorRes.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Publié le:',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: ColorRes.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(job.createdAt),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: ColorRes.black,
                                    ),
                                  ),
                                ],
                              ),
                              if (job.deadline != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Date limite:',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: ColorRes.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(job.deadline!),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _isDeadlineClose(job.deadline!) 
                                            ? ColorRes.errorColor 
                                            : ColorRes.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Candidatures:',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: ColorRes.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${job.applicationsCount} candidatures',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: ColorRes.darkGold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 80), // Espace pour le bouton fixe
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton de candidature fixe
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.hasAlreadyApplied.value
                    ? null
                    : () => _openApplicationScreen(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.hasAlreadyApplied.value
                      ? ColorRes.textTertiary
                      : const Color(0xFF000647),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isCheckingApplication.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        controller.hasAlreadyApplied.value
                            ? 'Application already sent'
                            : 'Send my application',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorRes.darkGold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: ColorRes.darkGold),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorRes.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorRes.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: ColorRes.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _isDeadlineClose(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference <= 7 && difference >= 0;
  }

  void _openApplicationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationScreen(job: job),
      ),
    );
  }
}