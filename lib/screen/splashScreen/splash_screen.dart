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
  late final AnimationController _slideController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late final AnimationController _textController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  late final AnimationController _logoController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
        ..repeat(reverse: true);
  
  late final Animation<Offset> _slideAnimation =
      Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
  
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
      'description': 'Your journey to the perfect job starts here',
      'isLogo': true
    },
    {
      'title': 'Find Your',
      'subtitle': 'Dream Job',
      'description': 'Discover opportunities that match your skills',
      'isImage': true,
      'imagePath': 'assets/images/love_emoji.png'
    },
    {
      'title': 'Smart Job',
      'subtitle': 'Applications',
      'description': 'Apply matching offers with a single click',
      'isImage': true,
      'imagePath': 'assets/images/search_job.jpg'
    },
    {
      'title': 'Get Started',
      'subtitle': 'Now',
      'description': 'Join thousands of successful job seekers',
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
        final duration = i == 0 ? 6500 : 3500; // 6.5s pour première slide, 3.5s pour les autres
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
      body: Container(
        width: w,
        height: h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorRes.backgroundColor,
              Color(0xFFB2EBF2),
              ColorRes.darkBlue,
            ],
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
                                    width: 320,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          ColorRes.darkBlue,
                                          ColorRes.darkBlue.withOpacity(0.9),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColorRes.brightYellow.withOpacity(0.4),
                                          blurRadius: 25,
                                          spreadRadius: 5,
                                          offset: const Offset(0, 5),
                                        ),
                                        BoxShadow(
                                          color: ColorRes.darkBlue.withOpacity(0.2),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: ColorRes.brightYellow.withOpacity(0.6),
                                        width: 3,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
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
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: ColorRes.brightYellow.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: ColorRes.brightYellow,
                                        width: 3,
                                      ),
                                    ),
                                    child: Center(
                                      child: currentSlideData['isImage'] == true
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.asset(
                                                currentSlideData['imagePath']!,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Text(
                                              currentSlideData['icon']!,
                                              style: const TextStyle(fontSize: 40),
                                            ),
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
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: ColorRes.textPrimary,
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
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: ColorRes.brightYellow,
                              shadows: [
                                Shadow(
                                  color: ColorRes.brightYellow.withOpacity(0.5),
                                  blurRadius: 10,
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
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              currentSlideData['description']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: ColorRes.textSecondary,
                                height: 1.5,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.poppins(
                            color: ColorRes.textPrimary,
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
