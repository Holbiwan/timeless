import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/universal_app_bar.dart';
import 'package:timeless/models/job_offer_model.dart';
import 'package:timeless/models/job_offer_model.dart' as JobModel;
import 'package:timeless/screen/jobs/jobs_list_controller.dart';
import 'package:timeless/screen/jobs/job_detail_screen.dart';
import 'package:timeless/screen/jobs/job_application_screen.dart';
import 'package:timeless/utils/color_res.dart';

class JobsListScreen extends StatelessWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobsListController());

    return Scaffold(
      appBar: UniversalAppBar(
        title: 'Offres d\'emploi',
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: ColorRes.darkGold),
            onPressed: () => _showFilters(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: ColorRes.backgroundColor,
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  onChanged: (value) => controller.updateSearchTerm(value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un poste, entreprise...',
                    prefixIcon: Icon(Icons.search, color: ColorRes.darkGold),
                    suffixIcon: Obx(() => controller.searchTerm.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: ColorRes.darkGold),
                            onPressed: () => controller.clearSearch(),
                          )
                        : const SizedBox()),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.locationController,
                        onChanged: (value) => controller.updateLocation(value),
                        decoration: InputDecoration(
                          hintText: 'Ville, région...',
                          prefixIcon: Icon(Icons.location_on, color: ColorRes.darkGold),
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
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => controller.searchJobs(),
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: Text('Rechercher', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorRes.darkGold,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filtres actifs avec scroll optimisé
          Obx(() => controller.hasActiveFilters
              ? Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(), // Améliore la fluidité
                    cacheExtent: 200, // Optimise le cache pour les performances
                    itemCount: controller.activeFilters.length,
                    itemBuilder: (context, index) {
                      final filter = controller.activeFilters[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200), // Animation pour le retrait
                          child: Chip(
                            label: Text(
                              filter, 
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: ColorRes.darkGold,
                            elevation: 2,
                            shadowColor: ColorRes.darkGold.withOpacity(0.3),
                            deleteIcon: const Icon(
                              Icons.close, 
                              color: Colors.white, 
                              size: 18,
                            ),
                            onDeleted: () => controller.removeFilter(filter),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const SizedBox()),

          // Liste des emplois
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.jobs.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off, size: 64, color: ColorRes.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune offre trouvée',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Essayez de modifier vos critères de recherche',
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorRes.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshJobs(),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 600 ? 32 : 16,
                    vertical: 16,
                  ),
                  itemCount: controller.jobs.length,
                  itemBuilder: (context, index) {
                    final job = controller.jobs[index];
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width > 800 ? 700 : double.infinity,
                      ),
                      child: JobCard(
                        job: job,
                        onTap: () => _showApplicationDialog(context, job),
                      ),
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

  void _showFilters(BuildContext context, JobsListController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobFiltersSheet(controller: controller),
    );
  }

  void _showApplicationDialog(BuildContext context, JobOfferModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobApplicationScreen(
          job: {
            'Position': job.title,
            'CompanyName': job.companyName,
            'location': job.location,
            'salary': job.salaryDisplay,
            'employerId': job.employerId,
          },
          docId: job.id,
        ),
      ),
    );
  }
}


class JobCard extends StatelessWidget {
  final JobOfferModel job;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF000647), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF000647).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.work,
                  color: const Color(0xFF000647),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      job.companyName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            job.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              if (job.salaryDisplay != 'Salaire non spécifié')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF000647).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.salaryDisplay,
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF000647),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (job.salaryDisplay != 'Salaire non spécifié') const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  job.location,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF000647), width: 2.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JobFiltersSheet extends StatelessWidget {
  final JobsListController controller;

  const JobFiltersSheet({super.key, required this.controller});

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
            child: Row(
              children: [
                Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => controller.clearAllFilters(),
                  child: Text(
                    'Tout effacer',
                    style: TextStyle(color: ColorRes.darkGold),
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
                  // Type d'emploi
                  _buildFilterSection(
                    'Type d\'emploi',
                    [
                      _FilterOption('Temps plein', JobModel.JobType.fullTime),
                      _FilterOption('Temps partiel', JobModel.JobType.partTime),
                      _FilterOption('Contrat', JobModel.JobType.contract),
                      _FilterOption('Stage', JobModel.JobType.internship),
                      _FilterOption('Freelance', JobModel.JobType.freelance),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Niveau d'expérience
                  _buildFilterSection(
                    'Niveau d\'expérience',
                    [
                      _FilterOption('Débutant', JobModel.ExperienceLevel.entry),
                      _FilterOption('Junior', JobModel.ExperienceLevel.junior),
                      _FilterOption('Confirmé', JobModel.ExperienceLevel.mid),
                      _FilterOption('Senior', JobModel.ExperienceLevel.senior),
                      _FilterOption('Lead', JobModel.ExperienceLevel.lead),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Boutons d'action
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: ColorRes.borderColor)),
            ),
            child: Row(
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
                      style: TextStyle(color: ColorRes.darkGold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorRes.darkGold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Appliquer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildFilterSection<T>(String title, List<_FilterOption<T>> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorRes.black,
          ),
        ),
        const SizedBox(height: 12),
        ...options.map((option) => Obx(() => CheckboxListTile(
              title: Text(option.label),
              value: controller.isFilterSelected(option.value),
              onChanged: (bool? value) {
                if (value == true) {
                  controller.addFilter(option.value);
                } else {
                  controller.removeFilter(option.label);
                }
              },
              activeColor: ColorRes.darkGold,
              contentPadding: EdgeInsets.zero,
            ))),
      ],
    );
  }

}

class _FilterOption<T> {
  final String label;
  final T value;

  _FilterOption(this.label, this.value);
}
