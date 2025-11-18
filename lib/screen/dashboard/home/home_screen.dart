import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/screen/dashboard/home/home_controller.dart';
import 'package:timeless/screen/dashboard/home/tipsforyou_screen.dart';
import 'package:timeless/screen/dashboard/home/widgets/all_jobs.dart';
import 'package:timeless/screen/dashboard/home/widgets/appbar.dart';
import 'package:timeless/screen/dashboard/home/widgets/tips_for_you_section.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_controller.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

// Import supprimé : job_list_test_screen n'existe plus
import 'package:timeless/screen/ai_matching/ai_matching_screen.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final HomeController controller = HomeController();
  JobRecommendationController jrcontroller = Get.put(JobRecommendationController());
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  var args = Get.arguments;
  JobDetailsUploadCvController jobDetailsUploadCvController = Get.put(JobDetailsUploadCvController());

  @override
  Widget build(BuildContext context) {
    jobDetailsUploadCvController.init();

    return Container(
      height: Get.height,
      width: Get.width,
      color: ColorRes.backgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 60),
          homeAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- Tips for you section ---
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (con) => const TipsForYouScreen()),
                      );
                    },
                    child: tipsForYouSection(),
                  ),

                  // ---  Boutons Actions Avancées
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      children: [
                        // Bouton See Jobs - Mode sombre professionnel
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Remplacer par un écran de jobs réel
                            Get.snackbar('Info', 'Fonctionnalité en cours de développement');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorRes.primaryAccent,
                            foregroundColor: ColorRes.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.work_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "See Jobs",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Boutons AI & Analytics - Mode sombre professionnel
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(() => const SmartMatchingScreen());
                                },
                                icon: const Icon(Icons.psychology_rounded, size: 18),
                                label: Text(
                                  "Smart Match",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorRes.secondaryAccent,
                                  foregroundColor: ColorRes.white,
                                  minimumSize: const Size(0, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        Text(
                          Strings.jobRecommendation,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: ColorRes.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Get.toNamed(AppRes.jobRecommendationScreen),
                          child: Text(
                            Strings.seeAll,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ColorRes.infoColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    height: 32,
                    child: ListView.builder(
                      itemCount: jrcontroller.jobs2.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => jrcontroller.onTapJobs2(index),
                          child: Obx(
                            () => Container(
                              margin: const EdgeInsets.only(right: 10),
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorRes.borderColor, width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                color: jrcontroller.selectedJobs2.value == index
                                    ? ColorRes.primaryAccent
                                    : ColorRes.cardColor,
                              ),
                              child: Text(
                                jrcontroller.jobs2[index],
                                style: appTextStyle(
                                  color: jrcontroller.selectedJobs2.value == index
                                      ? ColorRes.white
                                      : ColorRes.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),
                  Obx(
                    () => jrcontroller.selectedJobs2.value == 0
                        ? allJobs(fireStore.collection("allPost").snapshots())
                        : jrcontroller.selectedJobs2.value == 1
                            ? allJobs(fireStore.collection("category").doc("Design").collection("Design").snapshots())
                            : jrcontroller.selectedJobs2.value == 2
                                ? allJobs(fireStore.collection("category").doc("UX").collection("UX").snapshots())
                                : jrcontroller.selectedJobs2.value == 3
                                    ? allJobs(fireStore.collection("category").doc("Software").collection("Software").snapshots())
                                    : jrcontroller.selectedJobs2.value == 4
                                        ? allJobs(fireStore.collection("category").doc("Database Manager").collection("Database Manager").snapshots())
                                        : jrcontroller.selectedJobs2.value == 5
                                            ? allJobs(fireStore.collection("category").doc("Product Manager").collection("Product Manager").snapshots())
                                            : jrcontroller.selectedJobs2.value == 6
                                                ? allJobs(fireStore.collection("category").doc("Full-Stack Developer").collection("Full-Stack Developer").snapshots())
                                                : jrcontroller.selectedJobs2.value == 7
                                                    ? allJobs(fireStore.collection("category").doc("Data Scientist").collection("Data Scientist").snapshots())
                                                        : jrcontroller.selectedJobs2.value == 9
                                                            ? allJobs(
                                                                fireStore.collection("category").doc("Web Developers").collection("Web Developers").snapshots(),
                                                                seeAll: true,
                                                              )
                                                            : jrcontroller.selectedJobs2.value == 10
                                                                ? allJobs(fireStore.collection("category").doc("Networking").collection("Networking").snapshots())
                                                                : jrcontroller.selectedJobs2.value == 11
                                                                    ? allJobs(fireStore.collection("category").doc("Cyber Security").collection("Cyber Security").snapshots())
                                                                    : Center(
                                                                        child: Text(
                                                                          jrcontroller.jobs2[jrcontroller.selectedJobs2.value],
                                                                        ),
                                                                      ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
