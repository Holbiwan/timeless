import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:timeless/screen/auth/sign_in_screen/sign_in_screen.dart';
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart';
import 'package:timeless/screen/organization_profile_screen/organization_profile_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'introduction_controller.dart';

// Jam palette
const kJYellow = Color(0xFFFED100);
const kJGreen = Color(0xFF1FA24A);

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  final IntroductionController _intro = Get.put(IntroductionController());
  Timer? _autoPlay;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlay?.cancel();
    _autoPlay = Timer.periodic(const Duration(seconds: 3), (_) {
      final int current = _pageController.page?.round() ?? 0;
      final int next = (current + 1) % 3;
      if (!mounted) return;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goToApp() {
    final String token = PrefService.getString(PrefKeys.userId);
    final String rol = PrefService.getString(PrefKeys.rol);
    final bool company = PrefService.getBool(PrefKeys.company);

    final DashBoardController dash = Get.put(DashBoardController());
    dash.currentTab = 0;

    Get.off(() => token.isEmpty
        ? DashBoardScreen()
        : rol == "User"
            ? DashBoardScreen()
            : company
                ? ManagerDashBoardScreen()
                : const OrganizationProfileScreen());
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 10, 10),
      body: Obx(
        () => Column(
          children: [
            const SizedBox(height: 40),

            // Top actions: Welcome (left) + Skip (right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Get.to(() => const SigninScreenU()),
                    child: Text(
                      "Welcome",
                      style: appTextStyle(
                        color: kJGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_intro.selectedIndex.value != 2)
                    TextButton(
                      onPressed: _goToApp,
                      child: Text(
                        "Skip",
                        style: appTextStyle(
                          color: kJYellow,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 64),
                ],
              ),
            ),

            // Carousel
            SizedBox(
              height: h * 0.60,
              child: PageView(
                controller: _pageController,
                onPageChanged: _intro.onChangeInd,
                children: const [
                  _IntroPage(
                    asset: AssetRes.page1,
                    title: "Find Your Job",
                    subtitle: "Bridging the gap with timeless talent",
                    subtitleColor: kJGreen,
                  ),
                  _IntroPage(
                    asset: AssetRes.page2,
                    title: "Apply Job",
                    subtitle: "Bridging the gap with timeless talent",
                    subtitleColor: kJYellow,
                  ),
                  _IntroPage(
                    asset: AssetRes.page3,
                    title: "Ready For The Job!",
                    subtitle: "Bridging the gap with timeless talent",
                    subtitleColor: kJYellow,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Dots
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: SlideEffect(
                activeDotColor: kJGreen,
                dotColor: kJYellow.withOpacity(0.25),
                dotWidth: 9,
                dotHeight: 9,
              ),
            ),

            const SizedBox(height: 28),

            // Final CTA
            if (_intro.selectedIndex.value == 2)
              InkWell(
                onTap: _goToApp,
                child: Container(
                  height: 50,
                  width: 294,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 0, 0),
                        Color.fromARGB(255, 50, 235, 47),
                      ],
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: appTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
  });

  final String asset;
  final String title;
  final String subtitle;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final double imgHeight = c.maxHeight * 0.58;
        final double horizontalPad = c.maxWidth * 0.08;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad),
              child: SizedBox(
                height: imgHeight,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    asset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: appTextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: appTextStyle(
                color: subtitleColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }
}
