import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:timeless/screen/dashboard/home/salons_emploi_screen.dart';
import 'package:timeless/screen/dashboard/home/webinaires_screen.dart';
import 'package:timeless/screen/dashboard/home/widgets/appbar.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/services/candidate_dashboard_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/common/widgets/neumorphic_button.dart';
import 'package:timeless/screen/analytics/candidate_analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var args = Get.arguments;
  JobDetailsUploadCvController jobDetailsUploadCvController = Get.put(JobDetailsUploadCvController());
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: 'QzLCf84hIwE',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    jobDetailsUploadCvController.init();
    final accessibilityService = AccessibilityService.instance;

    return Obx(() => Container(
      height: Get.height,
      width: Get.width,
      color: accessibilityService.backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 60),
                homeAppBar(),
                
                  const SizedBox(height: 20),

                  // --- SECTION: Boutons Neumorphism côte à côte ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        // Bouton My Applications Neumorphism
                        Expanded(
                          child: StreamBuilder<int>(
                            stream: CandidateDashboardService.getCandidateApplicationsCount(),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              
                              return NeumorphicButton(
                                text: "My Applications",
                                icon: Icons.assignment_outlined,
                                height: 55,
                                backgroundColor: const Color(0xFF000647),
                                textColor: Colors.white,
                                fontSize: 12,
                                badge: count > 0 ? NeumorphicBadge(count: count) : null,
                                onPressed: () {
                                  Get.toNamed(AppRes.applicationsUser);
                                },
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Bouton Job Offers Neumorphism
                        Expanded(
                          child: NeumorphicButton(
                            text: "See All Job Offers",
                            icon: Icons.work_outline,
                            height: 55,
                            backgroundColor: const Color(0xFF000647),
                            textColor: Colors.white,
                            fontSize: 12,
                            onPressed: () {
                              Get.toNamed(AppRes.jobRecommendationScreen);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // --- SECTION: Events Emploi + Calendrier ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF000647),
                            const Color(0xFF000647).withOpacity(0.95),
                            const Color(0xFF000647).withOpacity(0.9),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000647).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFF8C00).withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header avec calendrier mini
                          Container(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Section titre
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFFFF8C00).withOpacity(0.8),
                                                  const Color(0xFFFF8C00).withOpacity(0.6),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.event_available,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "Upcoming Events",
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Discover upcoming job fairs and webinars",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Mini calendrier dynamique
                                StreamBuilder<DateTime>(
                                  stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                                  builder: (context, snapshot) {
                                    final now = snapshot.data ?? DateTime.now();
                                    return Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color(0xFFE67E22),
                                            const Color(0xFFD35400),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFD35400), width: 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE67E22).withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            now.day.toString(),
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            _getMonthName(now.month).toUpperCase(),
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          // Lecteur vidéo amélioré (réduit)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: YoutubePlayer(
                                controller: _youtubeController,
                                showVideoProgressIndicator: true,
                                progressIndicatorColor: const Color(0xFFFF8C00),
                                progressColors: const ProgressBarColors(
                                  playedColor: Color(0xFFFF8C00),
                                  handleColor: Color(0xFFFF8C00),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Boutons Neumorphism pour les événements
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: NeumorphicButton(
                                    text: "Job Fairs",
                                    icon: Icons.domain,
                                    height: 45,
                                    backgroundColor: const Color(0xFFE67E22),
                                    textColor: Colors.white,
                                    fontSize: 11,
                                    onPressed: () => Get.to(() => const SalonsEmploiScreen()),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: NeumorphicButton(
                                    text: "Webinars",
                                    icon: Icons.play_circle_fill,
                                    height: 45,
                                    backgroundColor: const Color(0xFFE67E22),
                                    textColor: Colors.white,
                                    fontSize: 11,
                                    onPressed: () => Get.to(() => const WebinairesScreen()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  // Widget moderne pour les boutons d'events
  Widget _buildModernEventButton(String title, IconData icon, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF8C00).withOpacity(0.8),
                    const Color(0xFFFF8C00).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour obtenir le nom du mois
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
