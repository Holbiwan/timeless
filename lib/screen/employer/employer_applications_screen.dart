import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeless/controllers/employer_applications_controller.dart';
import 'package:timeless/models/application_model.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/screen/employer/application_detail_screen.dart';

class EmployerApplicationsScreen extends StatelessWidget {
  const EmployerApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmployerApplicationsController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Professional Space - Applications', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _showFiltersModal(context, controller),
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
          IconButton(
            onPressed: () => controller.refreshData(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Column(
          children: [
            // Statistics Header
            _buildStatisticsHeader(controller),
            
            // Filters Summary
            _buildFiltersSection(controller),
            
            // Applications List
            Expanded(
              child: controller.filteredApplications.isEmpty
                  ? _buildEmptyState()
                  : _buildApplicationsList(controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatisticsHeader(EmployerApplicationsController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.black, size: 24),
              const SizedBox(width: 8),
              Text(
                'Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  controller.totalApplications.toString(),
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Today',
                  controller.todayApplications.length.toString(),
                  Icons.today,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Pending',
                  controller.pendingApplications.toString(),
                  Icons.hourglass_empty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Interviews',
                  controller.interviewApplications.toString(),
                  Icons.event,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Hired',
                  controller.hiredApplications.toString(),
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'This Week',
                  controller.thisWeekApplications.length.toString(),
                  Icons.date_range,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.black.withOpacity(0.7), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.black.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFiltersSection(EmployerApplicationsController controller) {
    return Obx(() {
      bool hasFilters = controller.selectedJob.value != null || 
                       controller.selectedStatuses.isNotEmpty;
      
      if (!hasFilters) return const SizedBox.shrink();
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Filtres actifs',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => controller.clearFilters(),
                  child: const Text('Effacer tout', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (controller.selectedJob.value != null)
                  _buildFilterChip(
                    controller.selectedJob.value!.title,
                    () => controller.selectJob(null),
                  ),
                ...controller.selectedStatuses.map(
                  (status) => _buildFilterChip(
                    controller.getStatusLabel(status),
                    () => controller.removeStatusFilter(status),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.1),
      deleteIcon: Icon(Icons.close, size: 16, color: Colors.white),
      onDeleted: onRemove,
      side: BorderSide(color: Colors.white.withOpacity(0.3)),
    );
  }

  Widget _buildApplicationsList(EmployerApplicationsController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredApplications.length,
      itemBuilder: (context, index) {
        final application = controller.filteredApplications[index];
        final job = controller.getJobForApplication(application);
        
        return _buildApplicationCard(application, job, controller);
      },
    );
  }

  Widget _buildApplicationCard(
    ApplicationModel application, 
    JobOfferModel? job,
    EmployerApplicationsController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => ApplicationDetailScreen(application: application)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.candidateName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          application.candidateEmail,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: ColorRes.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: controller.getStatusColor(application.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.getStatusColor(application.status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      controller.getStatusLabel(application.status),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: controller.getStatusColor(application.status),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Job info
              if (job != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorRes.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.work, size: 16, color: Colors.black),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Footer with date and actions
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: ColorRes.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Candidature du ${DateFormat('dd/MM/yyyy à HH:mm').format(application.appliedAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ColorRes.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  if (application.status == ApplicationStatus.pending) ...[
                    _buildQuickActionButton(
                      'Voir',
                      Icons.visibility,
                      Colors.blue,
                      () => controller.updateApplicationStatus(
                        application.id,
                        ApplicationStatus.viewed,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _buildQuickActionButton(
                    'Détail',
                    Icons.arrow_forward,
                    Colors.white,
                    () => Get.to(() => ApplicationDetailScreen(application: application)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: ColorRes.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune candidature',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorRes.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Received applications will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ColorRes.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFiltersModal(BuildContext context, EmployerApplicationsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  'Filtres et tri',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Job filter
            Text(
              'Filtrer par offre d\'emploi',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildJobFilterChip('Toutes les offres', null, controller),
                ...controller.employerJobs.map(
                  (job) => _buildJobFilterChip(job.title, job, controller),
                ),
              ],
            )),
            
            const SizedBox(height: 24),
            
            // Status filter
            Text(
              'Filtrer par statut',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ApplicationStatus.values.map(
                (status) => _buildStatusFilterChip(status, controller),
              ).toList(),
            )),
            
            const SizedBox(height: 24),
            
            // Sort options
            Text(
              'Trier par',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: [
                _buildSortOption('Date (plus récent)', 'date_desc', controller),
                _buildSortOption('Date (plus ancien)', 'date_asc', controller),
                _buildSortOption('Nom candidat', 'name', controller),
                _buildSortOption('Statut', 'status', controller),
              ],
            )),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildJobFilterChip(String title, JobOfferModel? job, EmployerApplicationsController controller) {
    bool isSelected = controller.selectedJob.value == job;
    
    return FilterChip(
      label: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) => controller.selectJob(selected ? job : null),
      backgroundColor: Colors.transparent,
      selectedColor: Colors.white,
      side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5)),
    );
  }

  Widget _buildStatusFilterChip(ApplicationStatus status, EmployerApplicationsController controller) {
    bool isSelected = controller.selectedStatuses.contains(status);
    
    return FilterChip(
      label: Text(
        controller.getStatusLabel(status),
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isSelected ? Colors.white : controller.getStatusColor(status),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.addStatusFilter(status);
        } else {
          controller.removeStatusFilter(status);
        }
      },
      backgroundColor: Colors.transparent,
      selectedColor: controller.getStatusColor(status),
      side: BorderSide(color: controller.getStatusColor(status).withOpacity(0.5)),
    );
  }

  Widget _buildSortOption(String label, String value, EmployerApplicationsController controller) {
    bool isSelected = controller.sortBy.value == value;
    
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected 
          ? Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        controller.changeSortOrder(value);
        Navigator.pop(Get.context!);
      },
    );
  }
}