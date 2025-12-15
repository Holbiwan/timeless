import 'package:cloud_firestore/cloud_firestore.dart';

enum JobType {
  fullTime,
  partTime,
  contract,
  internship,
  freelance,
}

enum ExperienceLevel {
  entry,
  junior,
  mid,
  senior,
  lead,
  executive,
}

class JobOfferModel {
  final String id;
  final String employerId;
  final String companyName;
  final String title;
  final String description;
  final List<String> requirements;
  final String location;
  final JobType jobType;
  final ExperienceLevel experienceLevel;
  final double? salaryMin;
  final double? salaryMax;
  final List<String> skills;
  final String industry;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isActive;
  final int applicationsCount;

  JobOfferModel({
    required this.id,
    required this.employerId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.jobType,
    required this.experienceLevel,
    this.salaryMin,
    this.salaryMax,
    required this.skills,
    required this.industry,
    required this.createdAt,
    this.deadline,
    this.isActive = true,
    this.applicationsCount = 0,
  });

  factory JobOfferModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse salary from string format "min-max"
    double? salaryMinParsed;
    double? salaryMaxParsed;
    String? salaryStr = data['salary'];
    if (salaryStr != null && salaryStr.isNotEmpty) {
      List<String> salaryParts = salaryStr.split('-');
      if (salaryParts.length == 2) {
        salaryMinParsed = double.tryParse(salaryParts[0].trim());
        salaryMaxParsed = double.tryParse(salaryParts[1].trim());
      }
    }
    
    return JobOfferModel(
      id: doc.id,
      employerId: data['EmployerId'] ?? '',
      companyName: data['CompanyName'] ?? '',
      title: data['Position'] ?? '',
      description: data['description'] ?? '',
      requirements: [], // Not stored in current structure
      location: data['location'] ?? '',
      jobType: _parseJobTypeFromString(data['jobType']),
      experienceLevel: ExperienceLevel.mid, // Default for now
      salaryMin: salaryMinParsed ?? double.tryParse(data['salaryMin']?.toString() ?? '0'),
      salaryMax: salaryMaxParsed ?? double.tryParse(data['salaryMax']?.toString() ?? '0'),
      skills: [], // Not stored in current structure  
      industry: data['category'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      deadline: data['deadline'] != null ? (data['deadline'] as Timestamp).toDate() : null,
      isActive: data['isActive'] ?? true,
      applicationsCount: data['applicationsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employerId': employerId,
      'companyName': companyName,
      'title': title,
      'description': description,
      'requirements': requirements,
      'location': location,
      'jobType': _jobTypeToString(jobType),
      'experienceLevel': _experienceLevelToString(experienceLevel),
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'skills': skills,
      'industry': industry,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'isActive': isActive,
      'applicationsCount': applicationsCount,
    };
  }

  // Helper methods for enum conversion
  static JobType _parseJobType(String? type) {
    switch (type) {
      case 'fullTime':
        return JobType.fullTime;
      case 'partTime':
        return JobType.partTime;
      case 'contract':
        return JobType.contract;
      case 'internship':
        return JobType.internship;
      case 'freelance':
        return JobType.freelance;
      default:
        return JobType.fullTime;
    }
  }
  
  static JobType _parseJobTypeFromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'full-time':
        return JobType.fullTime;
      case 'part-time':
        return JobType.partTime;
      case 'contract':
        return JobType.contract;
      case 'internship':
        return JobType.internship;
      case 'freelance':
        return JobType.freelance;
      case 'temporary':
        return JobType.contract;
      default:
        return JobType.fullTime;
    }
  }

  static ExperienceLevel _parseExperienceLevel(String? level) {
    switch (level) {
      case 'entry':
        return ExperienceLevel.entry;
      case 'junior':
        return ExperienceLevel.junior;
      case 'mid':
        return ExperienceLevel.mid;
      case 'senior':
        return ExperienceLevel.senior;
      case 'lead':
        return ExperienceLevel.lead;
      case 'executive':
        return ExperienceLevel.executive;
      default:
        return ExperienceLevel.entry;
    }
  }

  static String _jobTypeToString(JobType type) {
    return type.toString().split('.').last;
  }

  static String _experienceLevelToString(ExperienceLevel level) {
    return level.toString().split('.').last;
  }

  // Getters for display
  String get jobTypeDisplay {
    switch (jobType) {
      case JobType.fullTime:
        return 'Temps plein';
      case JobType.partTime:
        return 'Temps partiel';
      case JobType.contract:
        return 'Contrat';
      case JobType.internship:
        return 'Stage';
      case JobType.freelance:
        return 'Freelance';
    }
  }

  String get experienceLevelDisplay {
    switch (experienceLevel) {
      case ExperienceLevel.entry:
        return 'Débutant';
      case ExperienceLevel.junior:
        return 'Junior';
      case ExperienceLevel.mid:
        return 'Confirmé';
      case ExperienceLevel.senior:
        return 'Senior';
      case ExperienceLevel.lead:
        return 'Lead';
      case ExperienceLevel.executive:
        return 'Direction';
    }
  }

  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) {
      return 'Salaire non spécifié';
    } else if (salaryMin != null && salaryMax != null) {
      return '${salaryMin!.toStringAsFixed(0)}€ - ${salaryMax!.toStringAsFixed(0)}€';
    } else if (salaryMin != null) {
      return 'À partir de ${salaryMin!.toStringAsFixed(0)}€';
    } else {
      return 'Jusqu\'à ${salaryMax!.toStringAsFixed(0)}€';
    }
  }

  JobOfferModel copyWith({
    String? id,
    String? employerId,
    String? companyName,
    String? title,
    String? description,
    List<String>? requirements,
    String? location,
    JobType? jobType,
    ExperienceLevel? experienceLevel,
    double? salaryMin,
    double? salaryMax,
    List<String>? skills,
    String? industry,
    DateTime? createdAt,
    DateTime? deadline,
    bool? isActive,
    int? applicationsCount,
  }) {
    return JobOfferModel(
      id: id ?? this.id,
      employerId: employerId ?? this.employerId,
      companyName: companyName ?? this.companyName,
      title: title ?? this.title,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      skills: skills ?? this.skills,
      industry: industry ?? this.industry,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      isActive: isActive ?? this.isActive,
      applicationsCount: applicationsCount ?? this.applicationsCount,
    );
  }
}