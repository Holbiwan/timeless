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
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'introduction_controller.dart';

// Utilisation des couleurs harmonisées

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
    // Direct redirect to sign-in page for clean demo
    debugPrint('[INTRO] Get Started - Going to Sign In');
    Get.off(() => const SigninScreenU());
  }

  void _goToWelcome() {
    // 🛠️ Calls the sign-in screen. If constructor is not const, remove "const".
    debugPrint('[INTRO] Welcome tapped');
    try {
      Get.to(() => const SigninScreenU());
    } catch (e) {
      debugPrint('[INTRO] Get.to failed: $e — trying Navigator.push');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SigninScreenU()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: Obx(
        () => Column(
          children: [
            const SizedBox(height: 40),

            // Welcome (gauche) + Skip (droite)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _goToWelcome,
                    child: Text(
                      "Welcome",
                      style: appTextStyle(
                        color: ColorRes.darkGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_intro.selectedIndex.value != 2)
                    InkWell(
                      onTap: _goToApp,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorRes.brightYellow,
                              ColorRes.orange,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ColorRes.darkGold),
                        ),
                        child: Text(
                          "Skip",
                          style: appTextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 64),
                ],
              ),
            ),

            // Carrousel (3 pages)
            SizedBox(
              height: h * 0.85,
              child: PageView(
                controller: _pageController,
                onPageChanged: _intro.onChangeInd,
                children: const [
                  _IntroPage(
                    asset: AssetRes.page1,
                    title: "Find Your Job",
                    subtitle: "Bridging the gap with Timeless talent",
                    subtitleColor: ColorRes.textSecondary,
                    highlightWord: "Timeless",
                  ),
                  _IntroPage(
                    asset: AssetRes.page2,
                    title: "Job Applications",
                    subtitle: "Bridging the gap with timeless talent",
                    subtitleColor: ColorRes.textSecondary,
                    highlightWords: ["Dream", "Applications"],
                  ),
                  _IntroPage(
                    asset: AssetRes.page3,
                    title: "Start Now!",
                    subtitle: "Bridging the gap with timeless talent",
                    subtitleColor: ColorRes.textSecondary,
                    highlightWord: "Now",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Indicateurs
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: SlideEffect(
                activeDotColor: ColorRes.orange,
                dotColor: ColorRes.brightYellow.withOpacity(0.3),
                dotWidth: 8,
                dotHeight: 8,
              ),
            ),

            const SizedBox(height: 28),

            // CTA final sur la 3e page
            if (_intro.selectedIndex.value == 2)
              InkWell(
                onTap: _goToApp,
                child: Container(
                  height: 45,
                  width: 294,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        ColorRes.brightYellow,
                        ColorRes.orange,
                      ],
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: appTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
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
    this.highlightWord,
    this.highlightWords,
  });

  final String asset;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final String? highlightWord;
  final List<String>? highlightWords;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final double imgHeight = c.maxHeight * 1.0;
        final double horizontalPad = c.maxWidth * 0.02;

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
                  child: Stack(
                    children: [
                      Image.asset(
                        asset,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      // Logo en filigrane
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.contain,
                              opacity: 0.6, // Beaucoup plus visible
                              alignment: Alignment.center,
                              scale: 1.2,
                              colorFilter: ColorFilter.mode(
                                ColorRes.brightYellow.withOpacity(0.9),
                                BlendMode.overlay,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Texte "Bridging the Gap With Timeless Talent" en blanc sur la première page
                      if (asset == AssetRes.page1)
                        Positioned(
                          bottom: 30,
                          left: 20,
                          right: 20,
                          child: Text(
                            'Bridging the Gap With Timeless Talent',
                            textAlign: TextAlign.center,
                            style: appTextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ).copyWith(
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildTitleWithHighlight(),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: appTextStyle(
                color: subtitleColor,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleWithHighlight() {
    const highlightColor = ColorRes.orange; // Orange pour les mots clés
    const defaultColor = ColorRes.textPrimary; // Noir primaire
    
    List<String> wordsToHighlight = [];
    if (highlightWord != null) wordsToHighlight.add(highlightWord!);
    if (highlightWords != null) wordsToHighlight.addAll(highlightWords!);
    
    if (wordsToHighlight.isEmpty) {
      return Text(
        title,
        textAlign: TextAlign.center,
        style: appTextStyle(
          color: defaultColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    
    List<TextSpan> spans = [];
    List<String> words = title.split(' ');
    
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      bool isHighlighted = wordsToHighlight.any((highlight) => 
        word.toLowerCase().contains(highlight.toLowerCase()));
      
      spans.add(TextSpan(
        text: word + (i < words.length - 1 ? ' ' : ''),
        style: appTextStyle(
          color: isHighlighted ? highlightColor : defaultColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ));
    }
    
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }
}
