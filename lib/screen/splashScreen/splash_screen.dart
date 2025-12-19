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
  late PageController _pageController;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': '',
      'subtitle': '',
      'description': '',
      'isLogo': true
    },
    {
      'title': 'A new app for',
      'subtitle': 'jobs seekers',
      'description': 'Apply to multiple offers',
      'isImage': true,
      'imagePath': 'assets/images/search_job.jpg'
    },
    {
      'title': 'Ready to',
      'subtitle': 'Join now ?',
      'description': 'Join our job seekers',
      'icon': '✨'
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _masterController.forward();
    _startAutoSlideShow();
  }

  void _startAutoSlideShow() {
    _autoSlideTimer = Timer.periodic(
      Duration(milliseconds: _currentSlide == 0 ? 6000 : 5000),
      (_) => _nextSlide(),
    );
  }

  void _nextSlide() {
    if (_currentSlide < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
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
      extendBodyBehindAppBar: true,
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
                                  ColorRes.royalBlue.withOpacity(0.4),
                                  ColorRes.royalBlue.withOpacity(0.3),
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

                // Contenu avec PageView pour transitions naturelles
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentSlide = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image de la page courante
                            _buildMainVisual(_slides[index], 1.0),
                            
                            const SizedBox(height: 20),
                            
                            // Texte de la page courante
                            _buildPageText(_slides[index]),
                          ],
                        ),
                      ),
                    );
                  },
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
                          color: ColorRes.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: ColorRes.royalBlue.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
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
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(
                            begin: 0.0,
                            end: index == _currentSlide ? 1.0 : 0.0,
                          ),
                          curve: Curves.easeInOutCubic,
                          builder: (context, value, child) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 8 + (16 * value),
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  Colors.white.withOpacity(0.3),
                                  Colors.white,
                                  value,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: value > 0.5
                                    ? [
                                        BoxShadow(
                                          color: Colors.white
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

  Widget _buildMainVisual(Map<String, dynamic> slideData, double animValue) {
    if (slideData['isLogo'] == true) {
      return ScaleTransition(
        scale: _logoScaleAnimation,
        child: SizedBox(
          width: 600,
          height: 400,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
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

  Widget _buildPageText(Map<String, dynamic> slideData) {
    return Column(
      children: [
        // Titre seulement si il n'est pas vide
        if (slideData['title']!.isNotEmpty) ...[
          Text(
            slideData['title']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
        // Sous-titre seulement si il n'est pas vide
        if (slideData['subtitle']!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            slideData['subtitle']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.orange,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ],
        // Description seulement si ce n'est pas la première slide avec le logo et si elle n'est pas vide
        if (slideData['isLogo'] != true && slideData['description']!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              slideData['description']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
                letterSpacing: 0.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _masterController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}
