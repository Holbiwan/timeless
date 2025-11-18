// ==================================================================
// JOB MATCHING SERVICE / SERVICE DE CORRESPONDANCE D'EMPLOIS
// ==================================================================

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

/// EN: Job matching service with multi-criteria scoring algorithm
/// FR: Service de matching d'emplois avec algorithme de scoring multicritères
class JobMatchingService {
  /// Enhanced job matching algorithm that uses user profile data
  static double calculateMatchScore(Map<String, dynamic> jobData) {
    if (kDebugMode) {
      print('🔍 Calculating match score for: ${jobData['Position']} at ${jobData['CompanyName']}');
    }
    
    double totalScore = 0.0;
    int weightSum = 0;
    
    // Get user preferences
    final userSkills = _getUserSkills();
    final userExperience = PrefService.getString(PrefKeys.experienceLevel);
    final userJobTypes = _getUserJobTypes();
    final userSalaryMin = _getUserSalaryMin();
    final userSalaryMax = _getUserSalaryMax();
    final userLocation = PrefService.getString(PrefKeys.city);
    final userIndustries = _getUserIndustries();
    
    // 1. SKILLS MATCHING (40% weight)
    final skillsScore = _calculateSkillsMatch(userSkills, jobData);
    totalScore += skillsScore * 40;
    weightSum += 40;
    if (kDebugMode) print('📚 Skills Score: ${skillsScore.toStringAsFixed(2)} (weight: 40)');
    
    // 2. EXPERIENCE LEVEL MATCHING (20% weight)
    final experienceScore = _calculateExperienceMatch(userExperience, jobData);
    totalScore += experienceScore * 20;
    weightSum += 20;
    if (kDebugMode) print('⭐ Experience Score: ${experienceScore.toStringAsFixed(2)} (weight: 20)');
    
    // 3. SALARY MATCHING
    final salaryScore = _calculateSalaryMatch(userSalaryMin, userSalaryMax, jobData);
    totalScore += salaryScore * 15;
    weightSum += 15;
    if (kDebugMode) print('💰 Salary Score: ${salaryScore.toStringAsFixed(2)} (weight: 15)');
    
    // 4. LOCATION MATCHING
    final locationScore = _calculateLocationMatch(userLocation, jobData);
    totalScore += locationScore * 10;
    weightSum += 10;
    if (kDebugMode) print('📍 Location Score: ${locationScore.toStringAsFixed(2)} (weight: 10)');
    
    // 5. JOB TYPE MATCHING 
    final jobTypeScore = _calculateJobTypeMatch(userJobTypes, jobData);
    totalScore += jobTypeScore * 10;
    weightSum += 10;
    if (kDebugMode) print('💼 Job Type Score: ${jobTypeScore.toStringAsFixed(2)} (weight: 10)');
    
    // 6. INDUSTRY MATCHING 
    final industryScore = _calculateIndustryMatch(userIndustries, jobData);
    totalScore += industryScore * 5;
    weightSum += 5;
    if (kDebugMode) print('🏢 Industry Score: ${industryScore.toStringAsFixed(2)} (weight: 5)');
    
    // Calculate final weighted score
    final finalScore = weightSum > 0 ? (totalScore / weightSum) : 0.0;
    
    // Convert to percentage
    final percentageScore = min(100.0, max(0.0, finalScore * 100));
    
    if (kDebugMode) {
      print('🎯 Final Match Score: ${percentageScore.toStringAsFixed(1)}%');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
    
    return percentageScore;
  }
  
  /// Calculate skills matching score
  static double _calculateSkillsMatch(List<String> userSkills, Map<String, dynamic> jobData) {
    if (userSkills.isEmpty) {
      // Fallback
      return _legacySkillsMatch(jobData);
    }
    
    // Get job requirements
    final requirements = _getJobRequirements(jobData);
    if (requirements.isEmpty) return 0.5; // Neutral score if no requirements
    
    int matches = 0;
    int totalRequirements = requirements.length;
    
    for (String requirement in requirements) {
      for (String userSkill in userSkills) {
        if (_isSkillMatch(userSkill, requirement)) {
          matches++;
          break; // Count each requirement only once
        }
      }
    }
    
    // Calculate score with bonus for high match rate
    double baseScore = matches / totalRequirements;
    
    // Bonus for high match rates
    if (baseScore >= 0.8) {
      baseScore += 0.1;
    } else if (baseScore >= 0.6) baseScore += 0.05;
    
    return min(1.0, baseScore);
  }
  
  /// Legacy skills matching (fallback)
  static double _legacySkillsMatch(Map<String, dynamic> jobData) {
    final requirements = _getJobRequirements(jobData);
    if (requirements.isEmpty) return 0.7; // Default score
    
    double score = 0.7; // Base score
    final requirementsText = requirements.join(' ').toLowerCase();
    
    // Legacy keyword matching
    if (requirementsText.contains('flutter')) score += 0.15;
    if (requirementsText.contains('dart')) score += 0.10;
    if (requirementsText.contains('firebase')) score += 0.08;
    if (requirementsText.contains('api')) score += 0.05;
    if (requirementsText.contains('react')) score += 0.10;
    if (requirementsText.contains('javascript')) score += 0.08;
    if (requirementsText.contains('python')) score += 0.10;
    if (requirementsText.contains('java')) score += 0.08;
    
    return min(1.0, score);
  }
  
  /// Calculate experience level matching
  static double _calculateExperienceMatch(String userExperience, Map<String, dynamic> jobData) {
    if (userExperience.isEmpty) return 0.5; // Neutral if not set
    
    // Extract experience level from job data
    final jobTitle = (jobData['Position'] ?? '').toLowerCase();
    final jobDescription = _getJobRequirements(jobData).join(' ').toLowerCase();
    final combinedText = '$jobTitle $jobDescription';
    
    // Map user experience to job level requirements
    final Map<String, double> experienceMap = {
      'entry level': 0.0,
      'junior': 0.2,
      'mid-level': 0.5,
      'senior': 0.8,
      'lead': 0.9,
      'executive': 1.0,
    };
    
    final userLevel = experienceMap[userExperience.toLowerCase()] ?? 0.5;
    
    // Detect job level requirements
    double jobLevel = 0.5; // Default mid-level
    
    if (combinedText.contains('entry') || combinedText.contains('intern') || 
        combinedText.contains('graduate') || combinedText.contains('junior')) {
      jobLevel = 0.2;
    } else if (combinedText.contains('senior') || combinedText.contains('lead')) {
      jobLevel = 0.8;
    } else if (combinedText.contains('director') || combinedText.contains('head') || 
               combinedText.contains('chief') || combinedText.contains('executive')) {
      jobLevel = 1.0;
    }
    
    // Calculate match (closer levels = higher score)
    final levelDifference = (userLevel - jobLevel).abs();
    return max(0.0, 1.0 - (levelDifference * 2)); // Penalize large differences
  }
  
  /// Calculate salary matching
  static double _calculateSalaryMatch(double userSalaryMin, double userSalaryMax, Map<String, dynamic> jobData) {
    if (userSalaryMin == 0 && userSalaryMax == 0) return 0.5; // Neutral if not set
    
    // Extract salary from job data
    final jobSalary = _parseJobSalary(jobData);
    if (jobSalary == 0) return 0.5; // Neutral if no salary info
    
    // Check if job salary falls within user range
    if (jobSalary >= userSalaryMin && jobSalary <= userSalaryMax) {
      return 1.0; // Perfect match
    }
    
    // Calculate how far off the salary is
    double distance = 0;
    if (jobSalary < userSalaryMin) {
      distance = (userSalaryMin - jobSalary) / userSalaryMin;
    } else {
      distance = (jobSalary - userSalaryMax) / userSalaryMax;
    }
    
    // Return score based on distance (closer = higher score)
    return max(0.0, 1.0 - distance);
  }
  
  /// Calculate location matching
  static double _calculateLocationMatch(String userLocation, Map<String, dynamic> jobData) {
    if (userLocation.isEmpty) return 0.5; // Neutral if not set
    
    final jobLocation = (jobData['location'] ?? jobData['Location'] ?? '').toString().toLowerCase();
    final userLocationLower = userLocation.toLowerCase();
    
    // Check for remote work
    if (jobLocation.contains('remote') || jobLocation.contains('anywhere')) {
      return 1.0; // Perfect for any location
    }
    
    // Exact city match
    if (jobLocation.contains(userLocationLower)) {
      return 1.0;
    }
    
    // Same country/state match (basic)
    final userCountry = PrefService.getString(PrefKeys.country).toLowerCase();
    final userState = PrefService.getString(PrefKeys.state).toLowerCase();
    
    if (userCountry.isNotEmpty && jobLocation.contains(userCountry)) {
      return 0.8; // Good match for same country
    }
    
    if (userState.isNotEmpty && jobLocation.contains(userState)) {
      return 0.9; // Better match for same state
    }
    
    return 0.3; // Lower score for different locations
  }
  
  /// Calculate job type matching
  static double _calculateJobTypeMatch(List<String> userJobTypes, Map<String, dynamic> jobData) {
    if (userJobTypes.isEmpty) return 0.5; // Neutral if not set
    
    final jobType = (jobData['type'] ?? jobData['Type'] ?? '').toString().toLowerCase();
    final jobTitle = (jobData['Position'] ?? '').toString().toLowerCase();
    
    for (String userType in userJobTypes) {
      final userTypeLower = userType.toLowerCase();
      
      // Direct match
      if (jobType.contains(userTypeLower)) {
        return 1.0;
      }
      
      // Match in job title
      if (jobTitle.contains(userTypeLower)) {
        return 0.9;
      }
      
      // Special cases
      if (userTypeLower == 'remote' && (jobType.contains('remote') || jobTitle.contains('remote'))) {
        return 1.0;
      }
    }
    
    return 0.2; // Low match if no job type match
  }
  
  /// Calculate industry matching
  static double _calculateIndustryMatch(List<String> userIndustries, Map<String, dynamic> jobData) {
    if (userIndustries.isEmpty) return 0.5; // Neutral if not set
    
    final companyName = (jobData['CompanyName'] ?? '').toString().toLowerCase();
    final jobTitle = (jobData['Position'] ?? '').toString().toLowerCase();
    
    for (String industry in userIndustries) {
      final industryLower = industry.toLowerCase();
      
      // Match in company name or job title
      if (companyName.contains(industryLower) || jobTitle.contains(industryLower)) {
        return 1.0;
      }
      
      // Technology industry matching
      if (industryLower == 'technology') {
        if (jobTitle.contains('developer') || jobTitle.contains('engineer') || 
            jobTitle.contains('programmer') || jobTitle.contains('software')) {
          return 0.9;
        }
      }
    }
    
    return 0.4; // Moderate match if no clear industry match
  }
  
  // Helper methods
  static List<String> _getUserSkills() {
    final skillsJson = PrefService.getString(PrefKeys.skillsList);
    if (skillsJson.isEmpty) return [];
    
    try {
      return List<String>.from(jsonDecode(skillsJson));
    } catch (e) {
      return [];
    }
  }
  
  static List<String> _getUserJobTypes() {
    final jobTypesJson = PrefService.getString(PrefKeys.jobTypes);
    if (jobTypesJson.isEmpty) return [];
    
    try {
      return List<String>.from(jsonDecode(jobTypesJson));
    } catch (e) {
      return [];
    }
  }
  
  static List<String> _getUserIndustries() {
    final industriesJson = PrefService.getString(PrefKeys.industryPreferences);
    if (industriesJson.isEmpty) return [];
    
    try {
      return List<String>.from(jsonDecode(industriesJson));
    } catch (e) {
      return [];
    }
  }
  
  static double _getUserSalaryMin() {
    return double.tryParse(PrefService.getString(PrefKeys.salaryRangeMin)) ?? 0;
  }
  
  static double _getUserSalaryMax() {
    return double.tryParse(PrefService.getString(PrefKeys.salaryRangeMax)) ?? 0;
  }
  
  static List<String> _getJobRequirements(Map<String, dynamic> jobData) {
    final requirements = jobData['RequirementsList'];
    if (requirements is List) {
      return requirements.map((e) => e.toString()).toList();
    }
    
    // Fallback: try to get requirements from other fields
    final fallbackText = '${jobData['Position'] ?? ''} ${jobData['Description'] ?? ''}'.trim();
    return fallbackText.isNotEmpty ? [fallbackText] : [];
  }
  
  static bool _isSkillMatch(String userSkill, String requirement) {
    final userSkillLower = userSkill.toLowerCase();
    final requirementLower = requirement.toLowerCase();
    
    // Direct match
    if (requirementLower.contains(userSkillLower) || userSkillLower.contains(requirementLower)) {
      return true;
    }
    
    // Synonym matching
    final synonyms = {
      'javascript': ['js', 'node', 'react', 'angular', 'vue'],
      'python': ['django', 'flask', 'fastapi'],
      'java': ['spring', 'android'],
      'flutter': ['dart', 'mobile'],
      'react': ['javascript', 'js', 'frontend'],
      'angular': ['javascript', 'js', 'typescript'],
      'vue': ['javascript', 'js', 'vuejs'],
    };
    
    for (String synonym in synonyms[userSkillLower] ?? []) {
      if (requirementLower.contains(synonym)) {
        return true;
      }
    }
    
    return false;
  }
  
  static double _parseJobSalary(Map<String, dynamic> jobData) {
    final salaryStr = (jobData['salary'] ?? jobData['Salary'] ?? '').toString();
    
    // Extract numbers from salary string
    final regex = RegExp(r'[\d,]+');
    final matches = regex.allMatches(salaryStr);
    
    if (matches.isNotEmpty) {
      final salaryText = matches.first.group(0) ?? '';
      final salary = double.tryParse(salaryText.replaceAll(',', '')) ?? 0;
      
      // Convert to annual salary if it looks like monthly/hourly
      if (salary < 1000) {
        return salary * 40 * 52; // Hourly to annual
      } else if (salary < 50000) {
        return salary * 12; // Monthly to annual
      }
      
      return salary;
    }
    
    return 0;
  }
}