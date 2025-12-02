import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/common/widgets/universal_app_bar.dart';
import 'package:timeless/models/application_model.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/screen/profile/my_applications_controller.dart';
import 'package:timeless/utils/color_res.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyApplicationsController());

    return TimelessScaffold(
      title: 'Mes candidatures',
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, color: ColorRes.darkGold),
          onPressed: () => _showFilters(context, controller),
        ),
      ],
      body: Column(
        children: [
          // Statistiques en haut
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorRes.darkGold.withOpacity(0.1),
                  ColorRes.orange.withOpacity(0.05),
                ],
              ),
            ),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    controller.applications.length.toString(),
                    Icons.send,
                    ColorRes.darkGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'En cours',
                    controller.pendingApplications.length.toString(),
                    Icons.hourglass_empty,
                    ColorRes.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Vues',
                    controller.viewedApplications.length.toString(),
                    Icons.visibility,
                    ColorRes.royalBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Réponses',
                    controller.respondedApplications.length.toString(),
                    Icons.reply,
                    ColorRes.successColor,
                  ),
                ),
              ],
            )),
          ),

          // Filtres actifs
          Obx(() => controller.hasActiveFilters
              ? Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.activeFilters.length,
                    itemBuilder: (context, index) {
                      final filter = controller.activeFilters[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                        child: Chip(
                          label: Text(filter, style: TextStyle(color: Colors.white)),
                          backgroundColor: ColorRes.darkGold,
                          deleteIcon: Icon(Icons.close, color: Colors.white, size: 18),
                          onDeleted: () => controller.removeFilter(filter),
                        ),
                      );
                    },
                  ),
                )
              : const SizedBox()),

          // Liste des candidatures
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredApplications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: ColorRes.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        controller.applications.isEmpty 
                            ? 'Aucune candidature'
                            : 'Aucune candidature trouvée',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.applications.isEmpty
                            ? 'Commencez à postuler aux offres qui vous intéressent'
                            : 'Essayez de modifier vos filtres',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: ColorRes.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (controller.applications.isEmpty)
                        ElevatedButton(
                          onPressed: () => Get.toNamed('/jobs'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorRes.darkGold,
                          ),
                          child: Text(
                            'Parcourir les offres',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshApplications(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.filteredApplications.length,
                  itemBuilder: (context, index) {
                    final application = controller.filteredApplications[index];
                    return ApplicationCard(
                      application: application,
                      onTap: () => _showApplicationDetail(context, application),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: ColorRes.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context, MyApplicationsController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrer par statut',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...ApplicationStatus.values.map((status) => Obx(() => CheckboxListTile(
              title: Text(_getStatusLabel(status)),
              value: controller.selectedStatuses.contains(status),
              onChanged: (bool? value) {
                if (value == true) {
                  controller.addStatusFilter(status);
                } else {
                  controller.removeStatusFilter(status);
                }
              },
              activeColor: ColorRes.darkGold,
            ))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearFilters();
                      Navigator.pop(context);
                    },
                    child: Text('Effacer'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorRes.darkGold,
                    ),
                    child: Text('Fermer', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationDetail(BuildContext context, ApplicationModel application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationDetailSheet(application: application),
    );
  }

  String _getStatusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'En attente';
      case ApplicationStatus.viewed:
        return 'Vue';
      case ApplicationStatus.shortlisted:
        return 'Présélectionnée';
      case ApplicationStatus.interview:
        return 'Entretien';
      case ApplicationStatus.rejected:
        return 'Refusée';
      case ApplicationStatus.hired:
        return 'Embauchée';
      case ApplicationStatus.withdrawn:
        return 'Retirée';
      case ApplicationStatus.accepted:
        return 'Acceptée';
    }
  }
}

class ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onTap;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Candidature envoyée', // TODO: Get job title
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorRes.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Entreprise', // TODO: Get company name from job
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: ColorRes.darkGold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor().withOpacity(0.3)),
                    ),
                    child: Text(
                      application.statusDisplay,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Informations
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: ColorRes.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Envoyée le ${_formatDate(application.appliedAt)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: ColorRes.textTertiary,
                    ),
                  ),
                  if (application.reviewedAt != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.visibility, size: 14, color: ColorRes.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Vue le ${_formatDate(application.reviewedAt!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: ColorRes.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),

              if (application.coverLetter != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.description, size: 14, color: ColorRes.darkGold),
                    const SizedBox(width: 4),
                    Text(
                      'Avec lettre de motivation',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: ColorRes.darkGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (application.status) {
      case ApplicationStatus.pending:
        return ColorRes.orange;
      case ApplicationStatus.viewed:
        return ColorRes.royalBlue;
      case ApplicationStatus.shortlisted:
        return ColorRes.successColor;
      case ApplicationStatus.interview:
        return ColorRes.darkGold;
      case ApplicationStatus.rejected:
        return ColorRes.errorColor;
      case ApplicationStatus.hired:
        return ColorRes.successColor;
      case ApplicationStatus.withdrawn:
        return ColorRes.textTertiary;
      case ApplicationStatus.accepted:
        return ColorRes.successColor;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0) return 'aujourd\'hui';
    if (diff == 1) return 'hier';
    if (diff < 7) return 'il y a $diff jours';
    if (diff < 30) return 'il y a ${(diff / 7).floor()} semaines';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ApplicationDetailSheet extends StatelessWidget {
  final ApplicationModel application;

  const ApplicationDetailSheet({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: ColorRes.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ColorRes.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Détail de la candidature',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    application.statusDisplay,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('CV envoyé', application.cvFileName),
                  
                  if (application.coverLetter != null)
                    _buildInfoSection('Lettre de motivation', application.coverLetter!),
                  
                  _buildInfoSection('Date d\'envoi', _formatFullDate(application.appliedAt)),
                  
                  if (application.reviewedAt != null)
                    _buildInfoSection('Date de consultation', _formatFullDate(application.reviewedAt!)),
                  
                  if (application.reviewNotes != null)
                    _buildInfoSection('Notes du recruteur', application.reviewNotes!),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorRes.darkGold,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Fermer',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorRes.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: ColorRes.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (application.status) {
      case ApplicationStatus.pending:
        return ColorRes.orange;
      case ApplicationStatus.viewed:
        return ColorRes.royalBlue;
      case ApplicationStatus.shortlisted:
        return ColorRes.successColor;
      case ApplicationStatus.interview:
        return ColorRes.darkGold;
      case ApplicationStatus.rejected:
        return ColorRes.errorColor;
      case ApplicationStatus.hired:
        return ColorRes.successColor;
      case ApplicationStatus.withdrawn:
        return ColorRes.textTertiary;
      case ApplicationStatus.accepted:
        return ColorRes.successColor;
    }
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}