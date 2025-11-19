// lib/screen/splashScreen/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/screen/first_page/first_screen.dart';
import 'package:timeless/utils/color_res.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _slideController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));
  late final AnimationController _textController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800));
  late final AnimationController _logoController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2500))
    ..repeat(reverse: true);


  late final Animation<double> _fadeAnimation =
      CurvedAnimation(parent: _textController, curve: Curves.easeIn);

  late final Animation<double> _logoScaleAnimation =
      Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeInOut));

  int _currentSlide = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Welcome to',
      'subtitle': 'Timeless',
      'description': 'Bridging the Gap With Timeless Talent',
      'isLogo': true
    },
    {
      'title': 'Find Your',
      'subtitle': 'Job Offers',
      'description': 'Discover opportunities that match your skills',
      'isImage': true,
      'imagePath': 'assets/images/love_emoji.png'
    },
    {
      'title': 'Smart Job',
      'subtitle': 'Apply',
      'description': 'Apply matching offers with a single click',
      'isImage': true,
      'imagePath': 'assets/images/search_job.jpg'
    },
    {
      'title': 'Get Started',
      'subtitle': 'Now',
      'description': 'Join our job seekers',
      'icon': '✨'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startSlideShow();
  }

  void _startSlideShow() async {
    for (int i = 0; i < _slides.length; i++) {
      _currentSlide = i;

      // Reset and start animations
      _slideController.reset();
      _textController.reset();

      // Start slide animation
      _slideController.forward();
      await Future.delayed(const Duration(milliseconds: 300));

      // Start text animation
      _textController.forward();

      // Wait before next slide (except last one)
      if (i < _slides.length - 1) {
        // Plus long pour la première slide avec le logo qui tourne
        final duration = i == 0
            ? 6500
            : 3500; // 6.5s pour première slide, 3.5s pour les autres
        await Future.delayed(Duration(milliseconds: duration));
      } else {
        // On last slide, wait then navigate
        await Future.delayed(const Duration(milliseconds: 4000));
        Get.offAll(() => FirstScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: w,
        height: h,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: AssetImage('assets/images/logo.png'),
            fit: BoxFit.contain,
            opacity: 0.08,
            alignment: Alignment.center,
            scale: 0.7,
            colorFilter: ColorFilter.mode(
              Color(0xFF1E3A8A),
              BlendMode.modulate,
            ),
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_slideController, _textController]),
            builder: (context, child) {
              final currentSlideData = _slides[_currentSlide];

              return Stack(
                children: [
                  // Animated background particles
                  ...List.generate(20, (index) {
                    return Positioned(
                      left: (index * 50) % w,
                      top: (index * 80) % h,
                      child: AnimatedBuilder(
                        animation: _slideController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              sin(_slideController.value * 2 * pi + index) * 10,
                              cos(_slideController.value * 2 * pi + index) * 10,
                            ),
                            child: Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                  // Main content
                  Positioned.fill(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon/Logo with scale animation
                            currentSlideData['isLogo'] == true
                                ? FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: ScaleTransition(
                                      scale: _logoScaleAnimation,
                                      child: Container(
                                        width: 380,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorRes.darkBlue
                                                  .withOpacity(0.3),
                                              blurRadius: 20,
                                              spreadRadius: 3,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: ColorRes.darkBlue
                                                .withOpacity(0.6),
                                            width: 3,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: ScaleTransition(
                                      scale: _fadeAnimation,
                                      child: Center(
                                        child: currentSlideData['isImage'] ==
                                                true
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.asset(
                                                  currentSlideData[
                                                      'imagePath']!,
                                                  width: 300,
                                                  height: 300,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Text(
                                                currentSlideData['icon']!,
                                                style: const TextStyle(
                                                    fontSize: 60,
                                                    color: Colors.white),
                                              ),
                                      ),
                                    ),
                                  ),

                            const SizedBox(height: 20),

                            // Title animation
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                currentSlideData['title']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: _currentSlide == 0
                                      ? ColorRes.brightYellow
                                      : ColorRes.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Subtitle animation
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                currentSlideData['subtitle']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: ColorRes.darkBlue,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: ColorRes.darkBlue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(2, 2),
                                    ),
                                    Shadow(
                                      color: ColorRes.brightYellow
                                          .withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Description animation
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  currentSlideData['description']!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: _currentSlide == 0 ? 16 : 15,
                                    fontWeight: _currentSlide == 0
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: Colors.white,
                                    height: 1.6,
                                    letterSpacing:
                                        _currentSlide == 0 ? 0.8 : 0.3,
                                    fontStyle: _currentSlide == 0
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Skip button
                  Positioned(
                    top: 50,
                    right: 20,
                    child: InkWell(
                      onTap: () => Get.offAll(() => FirstScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: ColorRes.brightYellow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ColorRes.brightYellow),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Progress dots
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentSlide ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentSlide
                                ? ColorRes.brightYellow
                                : Colors.white30,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _textController.dispose();
    _logoController.dispose();
    super.dispose();
  }
}
