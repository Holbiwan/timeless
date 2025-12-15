import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/screen/dashboard/home/home_controller.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_controller.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_style.dart';

Widget allJobs(Stream stream, {bool? seeAll = false}) {
  final HomeController controller = Get.put(HomeController());
  final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();

  return GetBuilder<JobRecommendationController>(
    id: "search",
    // ✅ s'assure qu'une instance existe:
    init: JobRecommendationController(),
    builder: (jrController) {
      return StreamBuilder(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          try {
            // ✅ check avant d'accéder à .docs
            if (snapshot.hasData && snapshot.data != null) {
              jrController.documents = snapshot.data.docs;
            } else {
              return const CommonLoader();
            }

            // Utiliser les filtres du controller
            final filteredDocs = jrController.getFilteredDocuments();
            final total = filteredDocs.length;
            
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
                          ? translationService.getText("no_results_found_filters")
                          : translationService.getText("no_job_offers_available"),
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
                        child: Text(translationService.getText("reset_filters")),
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
                  print(filteredDocs[revIndex].id);
                }

                final doc = filteredDocs[revIndex];
                final docData = doc.data() as Map<String, dynamic>;
                final position = docData["Position"] ?? translationService.getText("not_specified");
                final company = docData["CompanyName"] ?? translationService.getText("company_name_default");
                final location = docData["location"] ?? translationService.getText("not_specified");
                final salary = docData["salary"] ?? "0";

                // Filtrer les données de démo indésirables
                if (company.contains('DemoToday') || 
                    company.contains('FinanceExpert') ||
                    position.contains('DemoToday') ||
                    location.contains('DemoToday')) {
                  return const SizedBox.shrink(); // Ne pas afficher ces annonces
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  padding: const EdgeInsets.all(20),
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
                          Image.network(
                            'https://zupimages.net/up/25/51/vaft.png',
                            width: 48, // Increased size further
                            height: 48, // Increased size further
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  position,
                                  style: appTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  company,
                                  style: appTextStyle(
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
                        docData['description'] ?? translationService.getText("description_not_available"),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: appTextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          if (salary != "0" && salary.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "$salary€",
                                style: appTextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (salary != "0" && salary.isNotEmpty) const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              location,
                              style: appTextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => _showApplicationDialog(context, docData, doc),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF000647), width: 2.0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                translationService.getText('apply'),
                                style: appTextStyle(
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
              },
            );
          } catch (e) {
            if (kDebugMode) print(' AllJobs error: $e');
            return Center(
              child: Text(translationService.getText('loading_jobs'), style: TextStyle(fontSize: 16)),
            );
          }
        },
      );
    },
  );
}

void _showApplicationDialog(BuildContext context, Map<String, dynamic> jobData, QueryDocumentSnapshot doc) {
  final UnifiedTranslationService translationService = Get.find<UnifiedTranslationService>();
  print('🎯 POPUP APPELÉ - Job: ${jobData["Position"]}');
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 32 : 20),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF000647),
                      side: const BorderSide(color: Color(0xFF000647)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height > 600 ? 16 : 12,
                      ),
                    ),
                    child: Text(
                      translationService.getText('cancel'),
                      style: appTextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width > 600 ? 15 : 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Rediriger vers l'écran de candidature
                      Get.toNamed(AppRes.jobApplicationScreen, arguments: {
                        'job': jobData,
                        'docId': doc.id,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height > 600 ? 16 : 12,
                      ),
                    ),
                    child: Text(
                      translationService.getText('apply'),
                      style: appTextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width > 600 ? 15 : 14,
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
