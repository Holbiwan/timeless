import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var args = Get.arguments;
  JobDetailsUploadCvController jobDetailsUploadCvController = Get.put(JobDetailsUploadCvController());
  
  final List<String> _videoIds = [
    'QzLCf84hIwE',
    'bM8XmugoQuI',
    'Wz285x6ygGA',
  ];
  
  late List<YoutubePlayerController> _controllers;
  final PageController _pageController = PageController(viewportFraction: 0.9, initialPage: 1000);
  int _currentIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _controllers = _videoIds.map((id) => YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        enableCaption: true,
        forceHD: false,
      ),
    )).toList();
    
    // Sync index with initial page
    _currentIndex = 1000 % _videoIds.length;
    
    // Start auto-scroll
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Only scroll if the current video is NOT playing
      final currentController = _controllers[_currentIndex];
      if (!currentController.value.isPlaying) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    jobDetailsUploadCvController.init();
    final accessibilityService = AccessibilityService.instance;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  homeAppBar(onRefresh: () => setState(() {})),
                  
                  const SizedBox(height: 6),

                  // Main action cards section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // My Applications card
                        Expanded(
                          child: StreamBuilder<int>(
                            stream: CandidateDashboardService.getCandidateApplicationsCount(),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              
                              return _buildActionCard(
                                title: "My Applications",
                                subtitle: count > 0 ? "$count pending" : "No applications",
                                icon: Icons.assignment_outlined,
                                color: const Color(0xFF000647),
                                onTap: () => Get.toNamed(AppRes.applicationsUser),
                                badge: count,
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Browse Jobs card
                        Expanded(
                          child: _buildActionCard(
                            title: "Browse Jobs",
                            subtitle: "Find opportunities",
                            icon: Icons.work_outline,
                            color: const Color(0xFF1565C0),
                            onTap: () => Get.toNamed(AppRes.jobRecommendationScreen),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Learning & Events section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Learning & Events",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: const Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Video carousel
                        SizedBox(
                          height: 120,
                          child: PageView.builder(
                            controller: _pageController,
                            itemBuilder: (context, index) {
                              final videoIndex = index % _videoIds.length;
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: YoutubePlayer(
                                    controller: _controllers[videoIndex],
                                    showVideoProgressIndicator: true,
                                    progressIndicatorColor: const Color(0xFF000647),
                                    progressColors: const ProgressBarColors(
                                      playedColor: Color(0xFF000647),
                                      handleColor: Color(0xFF000647),
                                    ),
                                  ),
                                ),
                              );
                            },
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index % _videoIds.length;
                              });
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Page indicator
                        Center(
                          child: AnimatedSmoothIndicator(
                            activeIndex: _currentIndex,
                            count: _videoIds.length,
                            effect: const WormEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Color(0xFF000647),
                              dotColor: Colors.grey,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Event action buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildEventCard(
                                title: "Job Fairs",
                                subtitle: "Network with employers",
                                icon: Icons.business_center_outlined,
                                color: const Color(0xFF0D47A1),
                                onTap: () => Get.to(() => const SalonsEmploiScreen()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildEventCard(
                                title: "Webinars",
                                subtitle: "Learn new skills",
                                icon: Icons.play_circle_outline,
                                color: const Color(0xFF2196F3),
                                onTap: () => Get.to(() => const WebinairesScreen()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  // Main action card widget
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                if (badge != null && badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE67E22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event card widget
  Widget _buildEventCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8), // Reduced from 12
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 4), // Reduced from 6
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern event button widget
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

  // Get month name helper function
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
