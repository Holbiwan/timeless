import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// 🔑 Assure-toi que ce chemin et cette classe existent bien :
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

const kJYellow = Color(0xFFFFD700);
const kJGreen = Color(0xFFDC2626);

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
                        color: ColorRes.royalBlue,
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
                          color: ColorRes.royalBlue,
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

            // Carrousel (3 pages)
            SizedBox(
              height: h * 0.60,
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
                activeDotColor: kJGreen,
                dotColor: kJYellow.withOpacity(0.25),
                dotWidth: 9,
                dotHeight: 9,
              ),
            ),

            const SizedBox(height: 28),

            // CTA final sur la 3e page
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
                        Color(0xFFFFD700),
                        Color(0xFFDC2626),
                      ],
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: appTextStyle(
                      fontSize: 18,
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
            _buildTitleWithHighlight(),
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

  Widget _buildTitleWithHighlight() {
    const bordeauxColor = Color(0xFF7C2D12); // Bordeaux profond
    const defaultColor = Color(0xFF1A1A1A); // Noir
    
    List<String> wordsToHighlight = [];
    if (highlightWord != null) wordsToHighlight.add(highlightWord!);
    if (highlightWords != null) wordsToHighlight.addAll(highlightWords!);
    
    if (wordsToHighlight.isEmpty) {
      return Text(
        title,
        textAlign: TextAlign.center,
        style: appTextStyle(
          color: defaultColor,
          fontSize: 24,
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
          color: isHighlighted ? bordeauxColor : defaultColor,
          fontSize: 24,
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
