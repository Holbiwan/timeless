import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/screen/dashboard/home/tipsforyou_screen.dart';
import 'package:timeless/screen/dashboard/home/widgets/appbar.dart';
import 'package:timeless/screen/dashboard/home/widgets/tips_for_you_section.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/color_res.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
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
                            Get.toNamed(AppRes.jobRecommendationScreen);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Color(0xFF000647), width: 2.0),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "See Jobs Offers",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
