import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/screen/dashboard/home/widgets/all_jobs.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_controller.dart';

class JobRecommendationScreen extends StatelessWidget {
  const JobRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobRecommendationController());
    
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Recommandations d\'emploi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ColorRes.containerColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Section de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: ColorRes.containerColor,
            child: Column(
              children: [
                // Barre de recherche
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => controller.updateSearchText(value),
                    decoration: const InputDecoration(
                      hintText: 'Browsing jobs offers...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filtres de catégories
                SizedBox(
                  height: 40,
                  child: GetBuilder<JobRecommendationController>(
                    builder: (jrController) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: jrController.jobs2.length,
                        itemBuilder: (context, index) {
                          return Obx(() => GestureDetector(
                            onTap: () => jrController.onTapJobs2(index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: jrController.selectedJobs2.value == index
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                jrController.jobs2[index],
                                style: TextStyle(
                                  color: jrController.selectedJobs2.value == index
                                      ? ColorRes.containerColor
                                      : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des emplois
          Expanded(
            child: GetBuilder<JobRecommendationController>(
              builder: (jrController) {
                return Obx(() {
                  // Sélectionner le stream approprié selon la catégorie
                  Stream<QuerySnapshot> stream;
                  
                  switch (jrController.selectedJobs2.value) {
                    case 0:
                      stream = FirebaseFirestore.instance.collection("allPost").snapshots();
                      break;
                    case 1:
                      stream = FirebaseFirestore.instance
                          .collection("category")
                          .doc("Design")
                          .collection("Design")
                          .snapshots();
                      break;
                    case 2:
                      stream = FirebaseFirestore.instance
                          .collection("category")
                          .doc("UX")
                          .collection("UX")
                          .snapshots();
                      break;
                    case 3:
                      stream = FirebaseFirestore.instance
                          .collection("category")
                          .doc("Software")
                          .collection("Software")
                          .snapshots();
                      break;
                    case 4:
                      stream = FirebaseFirestore.instance
                          .collection("category")
                          .doc("Database Manager")
                          .collection("Database Manager")
                          .snapshots();
                      break;
                    default:
                      stream = FirebaseFirestore.instance.collection("allPost").snapshots();
                  }
                  
                  return allJobs(stream, seeAll: true);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}