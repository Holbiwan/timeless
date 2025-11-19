// lib/screen/splashScreen/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/screen/first_page/first_screen.dart';
import 'package:timeless/utils/color_res.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final AnimationController _logoController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2500))
    ..repeat(reverse: true);

  late final AnimationController _particleController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4000))
    ..repeat();

  late final Animation<double> _logoScaleAnimation =
      Tween<double>(begin: 1.0, end: 1.05).animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeInOut));

  int _currentSlide = 0;
  Timer? _autoSlideTimer;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Welcome to',
      'subtitle': 'Timeless',
      'description': 'Bridging the Gap With Timeless Talent',
      'isLogo': true
    },
    {
      'title': 'Find Your',
      'subtitle': 'Dream Job',
      'description': 'Discover opportunities that match your profile',
      'isImage': true,
      'imagePath': 'assets/images/love_emoji.png'
    },
    {
      'title': 'Smart Jobs',
      'subtitle': 'Applications',
      'description': 'Apply to multiple offers',
      'isImage': true,
      'imagePath': 'assets/images/search_job.jpg'
    },
    {
      'title': 'Get Started',
      'subtitle': 'Now',
      'description': 'Join successful job seekers',
      'icon': '✨'
    },
  ];

  @override
  void initState() {
    super.initState();
    _masterController.forward();
    _startAutoSlideShow();
  }

  void _startAutoSlideShow() {
    _autoSlideTimer = Timer.periodic(
      Duration(milliseconds: _currentSlide == 0 ? 7000 : 7000),
      (_) => _nextSlide(),
    );
  }

  void _nextSlide() {
    if (_currentSlide < _slides.length - 1) {
      setState(() {
        _currentSlide++;
      });
    } else {
      _autoSlideTimer?.cancel();
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() async {
    await _masterController.reverse();
    Get.offAll(
      () => FirstScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _masterController,
        child: Container(
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
            child: Stack(
              children: [
                // Enhanced animated background particles
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return Stack(
                      children: List.generate(25, (index) {
                        final delay = index * 0.1;
                        final animValue =
                            (_particleController.value + delay) % 1.0;
                        return Positioned(
                          left: (index * 60 + animValue * 100) % w,
                          top: (index * 90 + sin(animValue * 2 * pi) * 50) % h,
                          child: Transform.scale(
                            scale: 0.5 + sin(animValue * pi) * 0.5,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: [
                                  ColorRes.brightYellow.withOpacity(0.4),
                                  ColorRes.orange.withOpacity(0.3),
                                  Colors.white.withOpacity(0.2),
                                ][index % 3],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                // Contenu avec image animée et texte fixe
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image qui change avec animation
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.8, end: 1.0)
                                    .animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut)),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            key: ValueKey(_currentSlide),
                            child:
                                _buildMainVisual(_slides[_currentSlide], 1.0),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Texte dynamique qui change avec les images
                        _buildDynamicText(),
                      ],
                    ),
                  ),
                ),

                // Enhanced Skip button
                Positioned(
                  top: 50,
                  right: 20,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _masterController,
                      curve: Curves.easeOutBack,
                    )),
                    child: GestureDetector(
                      onTap: () {
                        _autoSlideTimer?.cancel();
                        _navigateToNextScreen();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorRes.brightYellow,
                              ColorRes.orange,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border:
                              Border.all(color: ColorRes.darkGold, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: ColorRes.orange.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Skip',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Enhanced Progress dots with smooth animations
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _masterController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        return TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 400),
                          tween: Tween(
                            begin: 0.0,
                            end: index == _currentSlide ? 1.0 : 0.0,
                          ),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 8 + (16 * value),
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  Colors.white30,
                                  ColorRes.brightYellow,
                                  value,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: value > 0.5
                                    ? [
                                        BoxShadow(
                                          color: ColorRes.brightYellow
                                              .withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicText() {
    final currentSlide = _slides[_currentSlide];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Column(
        key: ValueKey(_currentSlide),
        children: [
          // Titre dynamique
          Text(
            currentSlide['title']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // Sous-titre dynamique
          Text(
            currentSlide['subtitle']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: ColorRes.brightYellow,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: ColorRes.brightYellow.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Description dynamique
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              currentSlide['description']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
                letterSpacing: 0.8,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSimpleContent(Map<String, dynamic> slideData) {
    return [
      // Visual principal
      _buildMainVisual(slideData, 1.0),

      const SizedBox(height: 20),

      // Titre
      Text(
        slideData['title']!,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _currentSlide == 0 ? ColorRes.brightYellow : Colors.white,
          letterSpacing: 0.5,
        ),
      ),

      const SizedBox(height: 12),

      // Sous-titre
      Text(
        slideData['subtitle']!,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: ColorRes.brightYellow,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: ColorRes.brightYellow.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),

      const SizedBox(height: 20),

      // Description
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          slideData['description']!,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: _currentSlide == 0 ? 16 : 15,
            fontWeight: _currentSlide == 0 ? FontWeight.w600 : FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            height: 1.6,
            letterSpacing: _currentSlide == 0 ? 0.8 : 0.3,
            fontStyle: _currentSlide == 0 ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildStaggeredContent(
      Map<String, dynamic> slideData, double animValue) {
    return [
      // Main visual with enhanced animation
      Transform.translate(
        offset: Offset(0, 50 * (1 - animValue)),
        child: _buildMainVisual(slideData, animValue),
      ),

      SizedBox(height: 20 + (10 * (1 - animValue))),

      // Title with stagger delay
      Transform.translate(
        offset: Offset(0, 30 * (1 - animValue.clamp(0.0, 1.0))),
        child: Opacity(
          opacity: (animValue - 0.2).clamp(0.0, 1.0),
          child: Text(
            slideData['title']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: _currentSlide == 0 ? ColorRes.brightYellow : Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),

      const SizedBox(height: 12),

      // Subtitle with more stagger delay
      Transform.translate(
        offset: Offset(0, 30 * (1 - (animValue - 0.3).clamp(0.0, 1.0))),
        child: Opacity(
          opacity: (animValue - 0.4).clamp(0.0, 1.0),
          child: Text(
            slideData['subtitle']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: ColorRes.brightYellow,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: ColorRes.brightYellow.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),

      const SizedBox(height: 20),

      // Description with final stagger delay
      Transform.translate(
        offset: Offset(0, 30 * (1 - (animValue - 0.5).clamp(0.0, 1.0))),
        child: Opacity(
          opacity: (animValue - 0.6).clamp(0.0, 1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              slideData['description']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: _currentSlide == 0 ? 16 : 15,
                fontWeight:
                    _currentSlide == 0 ? FontWeight.w600 : FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
                letterSpacing: _currentSlide == 0 ? 0.8 : 0.3,
                fontStyle:
                    _currentSlide == 0 ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildMainVisual(Map<String, dynamic> slideData, double animValue) {
    if (slideData['isLogo'] == true) {
      return ScaleTransition(
        scale: _logoScaleAnimation,
        child: Container(
          width: 380,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    if (slideData['isImage'] == true) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset(
            slideData['imagePath']!,
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.grey.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        slideData['icon']!,
        style: const TextStyle(fontSize: 80, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _masterController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}
