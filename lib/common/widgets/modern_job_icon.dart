import 'package:flutter/material.dart';

class ModernJobIcon extends StatelessWidget {
  final String jobTitle;
  final String? category;
  final double size;

  const ModernJobIcon({
    Key? key,
    required this.jobTitle,
    this.category,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconData = _getJobIcon(jobTitle, category);
    final colors = _getJobColors(jobTitle, category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  IconData _getJobIcon(String jobTitle, String? category) {
    final title = jobTitle.toLowerCase();
    final cat = category?.toLowerCase() ?? '';

    // Development & Programming
    if (title.contains('développeur') || 
        title.contains('developer') || 
        title.contains('programmeur') ||
        title.contains('frontend') ||
        title.contains('backend') ||
        title.contains('fullstack') ||
        title.contains('full-stack') ||
        cat.contains('development') ||
        cat.contains('développement')) {
      return Icons.code;
    }

    // UX/UI Design
    if (title.contains('ux') ||
        title.contains('ui') ||
        title.contains('design') ||
        title.contains('designer') ||
        cat.contains('ux') ||
        cat.contains('ui') ||
        cat.contains('design')) {
      return Icons.palette;
    }

    // Data Science & Analytics
    if (title.contains('data') || 
        title.contains('analyste') || 
        title.contains('scientist') ||
        title.contains('analytics') ||
        title.contains('big data') ||
        cat.contains('data') ||
        cat.contains('analytics')) {
      return Icons.analytics;
    }

    // Security & Cybersecurity
    if (title.contains('security') || 
        title.contains('cybersecurity') || 
        title.contains('cyber') ||
        title.contains('sécurité') ||
        title.contains('pentest') ||
        cat.contains('security') ||
        cat.contains('cybersecurity')) {
      return Icons.security;
    }

    // DevOps & Cloud
    if (title.contains('devops') || 
        title.contains('cloud') || 
        title.contains('infrastructure') ||
        title.contains('aws') ||
        title.contains('azure') ||
        title.contains('kubernetes') ||
        cat.contains('devops') ||
        cat.contains('cloud')) {
      return Icons.cloud;
    }

    // Digital Marketing
    if (title.contains('marketing') && (title.contains('digital') || title.contains('numérique')) || 
        title.contains('seo') || 
        title.contains('sem') ||
        title.contains('social media') ||
        cat.contains('digital marketing') ||
        cat.contains('marketing digital')) {
      return Icons.trending_up;
    }

    // Project Management (Tech)
    if ((title.contains('manager') || title.contains('chef') || title.contains('responsable')) &&
        (title.contains('projet') || title.contains('product') || title.contains('tech') || title.contains('it')) ||
        cat.contains('project management') ||
        cat.contains('product management')) {
      return Icons.assignment_ind;
    }

    // Quality Assurance & Testing
    if (title.contains('qa') || 
        title.contains('test') || 
        title.contains('quality') ||
        title.contains('qualité') ||
        cat.contains('qa') ||
        cat.contains('testing')) {
      return Icons.verified;
    }

    // Par défaut : icône tech
    return Icons.computer;
  }

  List<Color> _getJobColors(String jobTitle, String? category) {
    final title = jobTitle.toLowerCase();
    final cat = category?.toLowerCase() ?? '';

    // Brand Colors Only: Bleu foncé (#000647), Orange foncé (#E67E22), Noir
    
    // Development & Programming - Bleu foncé
    if (title.contains('développeur') || title.contains('developer') || 
        title.contains('programmeur') || title.contains('frontend') ||
        title.contains('backend') || title.contains('fullstack') ||
        cat.contains('development') || cat.contains('développement')) {
      return [const Color(0xFF000647), const Color(0xFF000647).withOpacity(0.8)];
    }

    // UX/UI Design - Orange foncé
    if (title.contains('ux') || title.contains('ui') ||
        title.contains('design') || title.contains('designer') ||
        cat.contains('ux') || cat.contains('ui') || cat.contains('design')) {
      return [const Color(0xFFE67E22), const Color(0xFFE67E22).withOpacity(0.8)];
    }

    // Data Science & Analytics - Bleu foncé
    if (title.contains('data') || title.contains('analyste') || 
        title.contains('scientist') || title.contains('analytics') ||
        cat.contains('data') || cat.contains('analytics')) {
      return [const Color(0xFF000647), const Color(0xFF000647).withOpacity(0.8)];
    }

    // Security & Cybersecurity - Noir
    if (title.contains('security') || title.contains('cybersecurity') ||
        title.contains('cyber') || title.contains('sécurité') ||
        cat.contains('security') || cat.contains('cybersecurity')) {
      return [Colors.black, Colors.black.withOpacity(0.8)];
    }

    // DevOps & Cloud - Orange foncé
    if (title.contains('devops') || title.contains('cloud') ||
        title.contains('infrastructure') || title.contains('aws') ||
        cat.contains('devops') || cat.contains('cloud')) {
      return [const Color(0xFFE67E22), const Color(0xFFE67E22).withOpacity(0.8)];
    }

    // Digital Marketing - Orange foncé
    if ((title.contains('marketing') && title.contains('digital')) ||
        title.contains('seo') || title.contains('sem') ||
        cat.contains('digital marketing')) {
      return [const Color(0xFFE67E22), const Color(0xFFE67E22).withOpacity(0.8)];
    }

    // Project Management (Tech) - Noir
    if ((title.contains('manager') || title.contains('chef')) &&
        (title.contains('projet') || title.contains('product') || title.contains('tech')) ||
        cat.contains('project management')) {
      return [Colors.black, Colors.black.withOpacity(0.8)];
    }

    // Quality Assurance - Bleu foncé
    if (title.contains('qa') || title.contains('test') ||
        title.contains('quality') || cat.contains('qa')) {
      return [const Color(0xFF000647), const Color(0xFF000647).withOpacity(0.8)];
    }

    // Par défaut - Bleu foncé brand
    return [const Color(0xFF000647), const Color(0xFF000647).withOpacity(0.8)];
  }
}