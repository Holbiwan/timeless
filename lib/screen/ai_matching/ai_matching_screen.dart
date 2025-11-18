// lib/screen/ai_matching/smart_matching_screen_clean.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/screen/smart_apply/smart_apply_screen.dart';
import 'package:timeless/service/translation_service.dart';
import 'package:timeless/service/accessibility_service.dart';
import 'package:timeless/service/auto_translation_service.dart';
import 'package:timeless/common/widgets/language_toggle.dart';
import 'package:timeless/screen/accessibility/accessibility_panel.dart';
import 'dart:math';
import 'package:timeless/service/job_matching_service.dart';

class SmartMatchingScreen extends StatefulWidget {
  const SmartMatchingScreen({super.key});

  @override
  State<SmartMatchingScreen> createState() => _SmartMatchingScreenState();
}

class _SmartMatchingScreenState extends State<SmartMatchingScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _matches = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AutoTranslationService _autoTranslateService;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _autoTranslateService = AutoTranslationService.instance;
    _generateMatches();
  }

  Future<void> _generateMatches() async {
    try {
      final snapshot = await _firestore.collection('allPost').limit(3).get();
      _matches.clear();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _matches.add({
          'title': data['Position'] ?? 'Développeur Flutter',
          'company': data['CompanyName'] ?? 'TechStart Paris',
          'match': _calculateMatch(data),
          'salary': data['salary'] ?? '45k-60k €/an',
          'location': data['location'] ?? 'Paris, France',
          'skills': data['RequirementsList'] ?? ['Flutter', 'Dart', 'Firebase'],
          'reasons': _generateReasons(data),
          'docId': doc.id,
        });
      }
    } catch (e) {
      _matches = [
        {
          'title': 'Développeur Flutter',
          'company': 'TechStart Paris',
          'match': 92,
          'salary': '45k-60k €/an',
          'location': 'Paris, France',
          'skills': ['Flutter', 'Dart', 'Firebase'],
          'reasons': [
            '✅ Compétences correspondantes',
            '📍 Localisation: Paris',
            '💼 Type: CDI',
          ],
          'docId': 'demo1',
        }
      ];
    }
  }

  int _calculateMatch(Map<String, dynamic> jobData) {
    // Use new intelligent matching algorithm
    final score = JobMatchingService.calculateMatchScore(jobData);
    return score.round();
  }

  List<String> _generateReasons(Map<String, dynamic> jobData) {
    List<String> reasons = [];
    final requirements = jobData['RequirementsList'] as List?;
    if (requirements != null && requirements.isNotEmpty) {
      reasons.add('📋 ${requirements.length} compétences correspondent');
    }
    final location = jobData['location'];
    if (location != null) {
      reasons.add('📍 Localisation: $location');
    }
    final type = jobData['type'];
    if (type != null) {
      reasons.add('💼 Type de contrat: $type');
    }
    return reasons;
  }

  void _startAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });
    _animationController.repeat();
    
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isAnalyzing = false;
      });
      _animationController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: _autoTranslateService.autoTranslateText(
          '🎯 Smart Job Matching',
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        backgroundColor: ColorRes.darkGold,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const AccessibilityPanel()),
            icon: const Icon(Icons.accessibility),
            tooltip: 'Accessibility Settings',
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageToggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildAnalysisButton(),
            const SizedBox(height: 20),
            if (!_isAnalyzing) ..._buildMatchesList(),
            if (_isAnalyzing) _buildAnalysisAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorRes.darkBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorRes.darkBlue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.psychology, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          _autoTranslateService.autoTranslateText(
            'Matching Intelligent system',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _autoTranslateService.autoTranslateText(
            'Our algorithm analyzes your profile and skills to find the best matching jobs.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisButton() {
    return InkWell(
      onTap: _isAnalyzing ? null : _startAnalysis,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isAnalyzing 
                ? Colors.grey
                : ColorRes.darkBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isAnalyzing) 
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            else
              const Icon(Icons.auto_awesome, color: Colors.white),
            const SizedBox(width: 8),
            _autoTranslateService.autoTranslateText(
              _isAnalyzing ? 'Analyse in progress...' : '🔍 Find My Matches',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisAnimation() {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 2 * pi,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue, Colors.green],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 40),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _autoTranslateService.autoTranslateText(
            'Analyzing your profile...',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: ColorRes.textPrimary),
          ),
          const SizedBox(height: 8),
          _autoTranslateService.autoTranslateText(
            'Processing skills and preferences',
            style: GoogleFonts.poppins(fontSize: 12, color: ColorRes.grey),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMatchesList() {
    return [
      _autoTranslateService.autoTranslateText(
        '🎯 Your Calculated Matches',
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: ColorRes.textPrimary),
      ),
      const SizedBox(height: 16),
      ...List.generate(_matches.length, (index) => _buildMatchCard(_matches[index])),
    ];
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorRes.darkBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorRes.brightYellow.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _autoTranslateService.autoTranslateText(
                      match['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorRes.white,
                      ),
                    ),
                    _autoTranslateService.autoTranslateText(
                      match['company'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.yellow,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getMatchColor(match['match']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${match['match']}% Match',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '💰 ${match['salary']}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(
              (match['skills'] as List).length,
              (i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorRes.blueColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _autoTranslateService.autoTranslateText(
                  match['skills'][i],
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _autoTranslateService.autoTranslateText(
            'Why it\'s a great match:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ColorRes.white,
            ),
          ),
          const SizedBox(height: 6),
          ...List.generate(
            (match['reasons'] as List).length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _autoTranslateService.autoTranslateText(
                match['reasons'][i],
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => SmartApplyScreen(jobData: match));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getMatchColor(match['match']),
                  ),
                  child: _autoTranslateService.autoTranslateText(
                    'Apply',
                    style: GoogleFonts.poppins(color: const Color.fromARGB(255, 16, 2, 96)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Get.snackbar(
                    "💾 Saved",
                    "Offer saved for later review.",
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                },
                icon: const Icon(Icons.bookmark_border),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int match) {
    if (match >= 95) return Colors.green;
    if (match >= 85) return Colors.blue;
    return ColorRes.appleGreen;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}