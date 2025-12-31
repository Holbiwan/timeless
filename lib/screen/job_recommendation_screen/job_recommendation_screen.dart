import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/screen/dashboard/home/widgets/all_jobs.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_controller.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/common/widgets/date_sort_filter.dart';
import 'package:timeless/common/widgets/modern_filter_dialog.dart';
import 'package:timeless/common/widgets/modern_sort_dialog.dart';

class JobRecommendationScreen extends StatelessWidget {
  const JobRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobRecommendationController());
    final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();
    
    return Obx(() => Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text(
          'Job Offers',
          style: accessibilityService.getAccessibleTextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF000647),
          ),
        ),
        backgroundColor: Colors.white,
        leading: accessibilityService.buildAccessibleWidget(
          semanticLabel: translationService.getText('back'),
          onTap: () {
            accessibilityService.triggerHapticFeedback();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.offAllNamed('/dashboard');
            }
          },
          child: IconButton(
            icon: Icon(
              Icons.arrow_back, 
              color: const Color(0xFF000647),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Get.offAllNamed('/dashboard');
              }
            },
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Section de recherche
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              children: [
                // Barre de recherche
                Container(
                  decoration: BoxDecoration(
                    color: accessibilityService.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                    boxShadow: AppTheme.shadowRegular,
                    border: Border.all(color: accessibilityService.borderColor, width: 1),
                  ),
                  child: TextField(
                    onChanged: (value) => controller.updateSearchText(value),
                    style: accessibilityService.getAccessibleTextStyle(),
                    decoration: InputDecoration(
                      hintText: '${translationService.getText('search')} jobs...',
                      hintStyle: accessibilityService.getAccessibleTextStyle(
                        color: accessibilityService.secondaryTextColor,
                      ),
                      prefixIcon: Icon(
                        Icons.search, 
                        color: accessibilityService.secondaryTextColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingRegular,
                        vertical: AppTheme.spacingRegular,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filtres en ligne
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Filtres avec badges
                        _buildFilterChip(
                        'Category', 
                        controller.selectedCategory.value,
                        () => _showCategoryFilter(context, controller),
                        controller,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Type', 
                        controller.selectedJobType.value,
                        () => _showJobTypeFilter(context, controller),
                        controller,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Location', 
                        controller.selectedLocation.value,
                        () => _showLocationFilter(context, controller),
                        controller,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Salary', 
                        controller.selectedSalaryRange.value,
                        () => _showSalaryFilter(context, controller),
                        controller,
                      ),
                      const SizedBox(width: 8),
                      // Date Sort Filter
                      _buildFilterChip(
                        'Sort', 
                        controller.selectedDateSort.value.label,
                        () => _showDateSortFilter(context, controller),
                        controller,
                      ),
                      if (controller.hasActiveFilters()) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => controller.clearAllFilters(),
                          icon: const Icon(Icons.clear_all, color: Colors.red),
                          tooltip: 'Reset All Filters',
                        ),
                      ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des emplois
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("allPost")
                  .where('isFromVerifiedEmployer', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                return allJobs(
                  FirebaseFirestore.instance
                      .collection("allPost")
                      .where('isFromVerifiedEmployer', isEqualTo: true)
                      .snapshots(), 
                  seeAll: true
                );
              },
            ),
          ),
        ],
      ),
    ));
  }

  // Widget pour les chips de filtre
  Widget _buildFilterChip(
    String label, 
    String value, 
    VoidCallback onTap, 
    JobRecommendationController controller,
  ) {
    final isActive = value != 'All';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFF4A90E2) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? '$label: $value' : label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Dialogue de filtre catégorie
  void _showCategoryFilter(BuildContext context, JobRecommendationController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ModernFilterDialog(
        title: 'Category',
        options: controller.categories,
        selectedValue: controller.selectedCategory.value,
        onChanged: (value) => controller.updateCategory(value),
      ),
    );
  }

  // Dialogue de filtre type de poste
  void _showJobTypeFilter(BuildContext context, JobRecommendationController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ModernFilterDialog(
        title: 'Job Type',
        options: controller.jobTypes,
        selectedValue: controller.selectedJobType.value,
        onChanged: (value) => controller.updateJobType(value),
      ),
    );
  }

  // Dialogue de filtre localisation
  void _showLocationFilter(BuildContext context, JobRecommendationController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ModernFilterDialog(
        title: 'Location',
        options: controller.locations,
        selectedValue: controller.selectedLocation.value,
        onChanged: (value) => controller.updateLocation(value),
      ),
    );
  }

  // Dialogue de filtre salaire
  void _showSalaryFilter(BuildContext context, JobRecommendationController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ModernFilterDialog(
        title: 'Salary Range',
        options: controller.salaryRanges,
        selectedValue: controller.selectedSalaryRange.value,
        onChanged: (value) => controller.updateSalaryRange(value),
      ),
    );
  }


  // Dialogue de filtre de tri par date
  void _showDateSortFilter(BuildContext context, JobRecommendationController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ModernSortDialog(
        title: 'Sort by',
        options: DateSortOption.values,
        selectedValue: controller.selectedDateSort.value,
        onChanged: (value) => controller.updateDateSort(value),
      ),
    );
  }
}