import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/modern_job_icon.dart';
import 'package:timeless/screen/dashboard/home/home_controller.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_controller.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_style.dart';

Widget allJobs(Stream stream, {bool? seeAll = false}) {
  final HomeController controller = Get.put(HomeController());
  final UnifiedTranslationService translationService =
      Get.find<UnifiedTranslationService>();

  return StreamBuilder<QuerySnapshot>(
    stream: stream as Stream<QuerySnapshot>,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CommonLoader();
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                translationService.getText("no_job_offers_available"),
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      final firebaseJobs = snapshot.data!.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              ...data,
              'source': 'firebase',
              'docId': doc.id,
            };
          })
          .where((job) => job['isFromVerifiedEmployer'] == true)
          .toList();

      return GetBuilder<JobRecommendationController>(
        id: "search",
        init: JobRecommendationController(),
        builder: (jrController) {
          try {
            // Use Firebase jobs with real-time updates
            final filteredJobs = _filterJobs(firebaseJobs, jrController);
            final total = filteredJobs.length;

            controller.jobTypesSaved =
                List.generate(total, (index) => false).obs;

            if (total == 0) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      jrController.hasActiveFilters()
                          ? translationService
                              .getText("no_results_found_filters")
                          : translationService
                              .getText("no_job_offers_available"),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (jrController.hasActiveFilters()) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => jrController.clearAllFilters(),
                        child:
                            Text(translationService.getText("reset_filters")),
                      ),
                    ],
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: seeAll! ? total : (total <= 15 ? total : 15),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                final revIndex = total - 1 - index;
                if (kDebugMode) {
                  print([revIndex]);
                  print('Job ${revIndex}');
                }

                final docData = filteredJobs[revIndex];
                final position = docData["Position"] ??
                    translationService.getText("not_specified");
                final company = docData["CompanyName"] ??
                    translationService.getText("company_name_default");
                final location = docData["location"] ??
                    translationService.getText("not_specified");
                final salary = docData["salary"] ?? "0";
                final category = docData["category"] ?? "";

                // Filtrer les données de démo indésirables et employeurs non vérifiés
                if (company.contains('DemoToday') ||
                    company.contains('FinanceExpert') ||
                    position.contains('DemoToday') ||
                    location.contains('DemoToday') ||
                    docData['isFromVerifiedEmployer'] != true) {
                  return const SizedBox
                      .shrink(); // Ne pas afficher ces annonces
                }

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF000647).withOpacity(0.1),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000647).withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ModernJobIcon(
                            jobTitle: position,
                            category: category,
                            size: 48,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  position,
                                  style: appTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF000647),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  company,
                                  style: appTextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          docData['description'] ??
                              _generateDefaultDescription(position, company),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: appTextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (salary != "0" && salary.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFE67E22)
                                              .withOpacity(0.1),
                                          const Color(0xFFE67E22)
                                              .withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFFE67E22)
                                              .withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.euro,
                                          size: 11,
                                          color: const Color(0xFFE67E22),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          "$salary€",
                                          style: appTextStyle(
                                            fontSize: 10,
                                            color: const Color(0xFFE67E22),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF000647)
                                            .withOpacity(0.1),
                                        const Color(0xFF000647)
                                            .withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: const Color(0xFF000647)
                                            .withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 11,
                                        color: const Color(0xFF000647),
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          location,
                                          style: appTextStyle(
                                            fontSize: 10,
                                            color: const Color(0xFF000647),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () =>
                                _showApplicationDialog(context, docData, null),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.black, Colors.black87],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.send,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    translationService.getText('apply'),
                                    style: appTextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } catch (e) {
            if (kDebugMode) print(' AllJobs error: $e');
            return Center(
              child: Text(translationService.getText('loading_jobs'),
                  style: TextStyle(fontSize: 16)),
            );
          }
        },
      );
    },
  );
}

void _showApplicationDialog(BuildContext context, Map<String, dynamic> jobData,
    QueryDocumentSnapshot? doc) {
  final UnifiedTranslationService translationService =
      Get.find<UnifiedTranslationService>();
  print('🎯 POPUP APPELÉ - Job: ${jobData["Position"]}');
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding:
            EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 32 : 20),
        title: Row(
          children: [
            Icon(
              Icons.work,
              color: const Color(0xFF000647),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${translationService.getText('apply_for')} ${jobData["Position"] ?? translationService.getText("this_position")}',
                style: appTextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${translationService.getText('you_are_applying_for')} ${jobData["Position"] ?? translationService.getText("not_specified")} ${translationService.getText('at')} ${jobData["CompanyName"] ?? translationService.getText("this_company")}.',
              textAlign: TextAlign.center,
              style: appTextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton Cancel plus compact
                Container(
                  width: 100,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    child: Text(
                      translationService.getText('cancel'),
                      style: appTextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Bouton Apply plus élégant
                Container(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Rediriger vers l'écran de candidature
                      Get.toNamed(AppRes.jobApplicationScreen, arguments: {
                        'job': jobData,
                        'docId': doc?.id ?? jobData['docId'] ?? 'unknown',
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF000647).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      translationService.getText('apply'),
                      style: appTextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

String _generateDefaultDescription(String position, String company) {
  final UnifiedTranslationService translationService =
      Get.find<UnifiedTranslationService>();

  final descriptions = [
    translationService.getText("job_desc_1"),
    translationService.getText("job_desc_2"),
    translationService.getText("job_desc_3"),
    translationService.getText("job_desc_4"),
    translationService.getText("job_desc_5"),
    translationService.getText("job_desc_6"),
    translationService.getText("job_desc_7"),
    translationService.getText("job_desc_8"),
  ];

  final hash = (position + company).hashCode.abs();
  return descriptions[hash % descriptions.length];
}

// Real-time Firebase jobs now handled by StreamBuilder above

// Fonction pour filtrer les jobs selon les critères du controller
List<Map<String, dynamic>> _filterJobs(
    List<Map<String, dynamic>> jobs, dynamic controller) {
  List<Map<String, dynamic>> filteredJobs = List.from(jobs);

  // Filtre de recherche textuelle (nom société, lieu, salaire, poste, description)
  if (controller.searchText.value.isNotEmpty) {
    final searchQuery = controller.searchText.value.toLowerCase();
    filteredJobs = filteredJobs.where((job) {
      final position = (job['Position'] ?? '').toString().toLowerCase();
      final company = (job['CompanyName'] ?? '').toString().toLowerCase();
      final location = (job['location'] ?? '').toString().toLowerCase();
      final salary = (job['salary'] ?? '').toString().toLowerCase();
      final description = (job['description'] ?? '').toString().toLowerCase();
      final category = (job['category'] ?? '').toString().toLowerCase();

      return position.contains(searchQuery) ||
          company.contains(searchQuery) ||
          location.contains(searchQuery) ||
          salary.contains(searchQuery) ||
          description.contains(searchQuery) ||
          category.contains(searchQuery);
    }).toList();
  }

  // Filtre par catégorie
  if (controller.selectedCategory.value != 'All') {
    filteredJobs = filteredJobs.where((job) {
      final jobCategory = job['category'] ?? '';
      return jobCategory == controller.selectedCategory.value;
    }).toList();
  }

  // Filtre par type d'emploi
  if (controller.selectedJobType.value != 'All') {
    filteredJobs = filteredJobs.where((job) {
      final jobType = job['jobType'] ?? job['type'] ?? '';
      return jobType == controller.selectedJobType.value;
    }).toList();
  }

  // Filtre par localisation
  if (controller.selectedLocation.value != 'All') {
    filteredJobs = filteredJobs.where((job) {
      final jobLocation = (job['location'] ?? '').toString().toLowerCase();
      final selectedLoc = controller.selectedLocation.value.toLowerCase();
      return jobLocation.contains(selectedLoc);
    }).toList();
  }

  // Filtre par fourchette salariale
  if (controller.selectedSalaryRange.value != 'All') {
    filteredJobs = filteredJobs.where((job) {
      final salaryStr = (job['salary'] ?? '0').toString();
      final salary =
          int.tryParse(salaryStr.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

      switch (controller.selectedSalaryRange.value) {
        case '< 35K':
          return salary < 35000;
        case '35K-50K':
          return salary >= 35000 && salary <= 50000;
        case '50K-70K':
          return salary > 50000 && salary <= 70000;
        case '70K-90K':
          return salary > 70000 && salary <= 90000;
        case '90K+':
          return salary > 90000;
        default:
          return true;
      }
    }).toList();
  }

  // Tri par date selon le filtre de date - Use createdAt Timestamp from Firebase
  try {
    filteredJobs.sort((a, b) {
      // Get Timestamp from Firebase and convert to DateTime
      final aTimestamp = a['createdAt'];
      final bTimestamp = b['createdAt'];

      final aDate = aTimestamp is Timestamp
          ? aTimestamp.toDate()
          : (DateTime.tryParse(a['postingDate'] ?? '') ?? DateTime.now());
      final bDate = bTimestamp is Timestamp
          ? bTimestamp.toDate()
          : (DateTime.tryParse(b['postingDate'] ?? '') ?? DateTime.now());

      switch (controller.selectedDateSort.value.name) {
        case 'newest':
          return bDate.compareTo(aDate); // Plus récent en premier
        case 'oldest':
          return aDate.compareTo(bDate); // Plus ancien en premier
        default:
          return bDate.compareTo(aDate); // Par défaut: plus récent en premier
      }
    });
  } catch (e) {
    print('Erreur lors du tri par date: $e');
  }

  return filteredJobs;
}
