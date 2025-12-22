import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:timeless/screen/dashboard/home/salons_emploi_screen.dart';
import 'package:timeless/screen/dashboard/home/webinaires_screen.dart';
import 'package:timeless/screen/dashboard/home/widgets/appbar.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/services/candidate_dashboard_service.dart';
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
                  // --- SECTION: 

                  // My Applications button with real-time counter ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: StreamBuilder<int>(
                      stream: CandidateDashboardService.getCandidateApplicationsCount(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        
                        return ElevatedButton.icon(
                          onPressed: () {
                            Get.toNamed(AppRes.applicationsUser);
                          },
                          icon: const Icon(
                            Icons.assignment_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "My Applications Sent",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF000647),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000647),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8), // Reduced from 15

                  // --- SECTION: 

                  // Bouton See Jobs Offers (remonté) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(AppRes.jobRecommendationScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFF000647), width: 2.0),
                        minimumSize: const Size(double.infinity, 40), // Reduced from 42
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "See Jobs Offers",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // --- SECTION: 

                  // Encart Events d'emploi ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12), // Reduced from 16
                      decoration: BoxDecoration(
                        color: const Color(0xFF000647),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                              const Icon(
                                Icons.event,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Events Emploi",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8), // Reduced from 12
                          Text(
                            "Discover upcoming job fairs and professional events",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 10), // Reduced from 15
                          
                          // YouTube Video Player
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: YoutubePlayer(
                              controller: YoutubePlayerController(
                                initialVideoId: '0k5C68M7yn8',
                                flags: const YoutubePlayerFlags(
                                  autoPlay: false,
                                  mute: false,
                                ),
                              ),
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.blueAccent,
                            ),
                          ),
                          
                          const SizedBox(height: 10), // Reduced from 15
                          Row(
                            children: [
                              Expanded(
                                child: _buildEventButton(
                                  "Jobs fairs",
                                  Icons.business,
                                  () {
                                    Get.to(() => const SalonsEmploiScreen());
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildEventButton(
                                  "Webinars",
                                  Icons.play_circle,
                                  () {
                                    Get.to(() => const WebinairesScreen());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  // Widget pour les boutons d'events
  Widget _buildEventButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
