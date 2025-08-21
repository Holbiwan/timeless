import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart';
import 'package:timeless/screen/organization_profile_screen/organization_profile_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'introduction_controller.dart';

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
            const SizedBox(height: 60),
            if (_intro.selectedIndex.value != 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _goToApp,
                      child: const Text("skip",
                          style: TextStyle(color: Colors.yellow),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 24),
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
                    subtitleColor: Color.fromARGB(255, 9, 205, 48),
                  ),
                  _IntroPage(
                    asset: AssetRes.page2,
                    title: "Apply Job",
                    subtitle: "Bridging the gap with timeless talent",
                    subtitleColor: Color.fromARGB(255, 234, 255, 0),
                  ),
                  _IntroPage(
                    asset: AssetRes.page3,
                    title: "Ready For The Job!",
                    subtitle: "Bridging the gap with timeless talent",
                    subtitleColor: Color.fromARGB(255, 255, 247, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: SlideEffect(
                activeDotColor: const Color.fromARGB(255, 31, 167, 10),
                dotColor:
                    const Color.fromARGB(255, 240, 229, 6).withOpacity(0.20),
                dotWidth: 9,
                dotHeight: 9,
              ),
            ),
            const SizedBox(height: 32),
            if (_intro.selectedIndex.value == 2)
              InkWell(
                onTap: _goToApp,
                child: Container(
                  height: 50,
                  width: 294,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  margin: const EdgeInsets.only(right: 18, left: 18, top: 10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 0, 0),
                        Color.fromARGB(255, 50, 235, 47),
                      ],
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style:
                        appTextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
