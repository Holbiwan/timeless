// Modèle de profil candidat complet
import 'package:cloud_firestore/cloud_firestore.dart';
import 'application_model.dart';

class CandidateProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? location;
  final String? photoURL;
  final String? bio;
  final List<String> skills;
  final List<WorkExperience> experience;
  final List<Education> education;
  final List<String> languages;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? websiteUrl;
  final String? currentCVId;
  final ProfileStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> preferences;

  CandidateProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.location,
    this.photoURL,
    this.bio,
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.languages = const [],
    this.portfolioUrl,
    this.linkedinUrl,
    this.githubUrl,
    this.websiteUrl,
    this.currentCVId,
    this.status = ProfileStatus.incomplete,
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const {},
  });

  // Conversion depuis Firestore
  factory CandidateProfileModel.fromJson(Map<String, dynamic> json) {
    return CandidateProfileModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      location: json['location'],
      photoURL: json['photoURL'],
      bio: json['bio'],
      skills: List<String>.from(json['skills'] ?? []),
      experience: (json['experience'] as List<dynamic>?)
          ?.map((e) => WorkExperience.fromJson(e))
          .toList() ?? [],
      education: (json['education'] as List<dynamic>?)
          ?.map((e) => Education.fromJson(e))
          .toList() ?? [],
      languages: List<String>.from(json['languages'] ?? []),
      portfolioUrl: json['portfolioUrl'],
      linkedinUrl: json['linkedinUrl'],
      githubUrl: json['githubUrl'],
      websiteUrl: json['websiteUrl'],
      currentCVId: json['currentCVId'],
      status: ProfileStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProfileStatus.incomplete,
      ),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  // Conversion vers Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'location': location,
      'photoURL': photoURL,
      'bio': bio,
      'skills': skills,
      'experience': experience.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'languages': languages,
      'portfolioUrl': portfolioUrl,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'websiteUrl': websiteUrl,
      'currentCVId': currentCVId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'preferences': preferences,
    };
  }

  // Copie avec modifications
  CandidateProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? location,
    String? photoURL,
    String? bio,
    List<String>? skills,
    List<WorkExperience>? experience,
    List<Education>? education,
    List<String>? languages,
    String? portfolioUrl,
    String? linkedinUrl,
    String? githubUrl,
    String? websiteUrl,
    String? currentCVId,
    ProfileStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return CandidateProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      languages: languages ?? this.languages,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      currentCVId: currentCVId ?? this.currentCVId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      preferences: preferences ?? this.preferences,
    );
  }

  // Validation du profil
  bool get isComplete {
    return fullName.isNotEmpty &&
           email.isNotEmpty &&
           bio != null &&
           bio!.isNotEmpty &&
           skills.isNotEmpty &&
           currentCVId != null;
  }

  // Calcul du score de profil (0-100)
  int get profileCompletionScore {
    int score = 0;
    
    // Informations de base (40 points)
    if (fullName.isNotEmpty) score += 10;
    if (email.isNotEmpty) score += 10;
    if (phone?.isNotEmpty == true) score += 5;
    if (location?.isNotEmpty == true) score += 5;
    if (bio?.isNotEmpty == true) score += 10;
    
    // Compétences et expérience (40 points)
    if (skills.isNotEmpty) score += 15;
    if (experience.isNotEmpty) score += 15;
    if (education.isNotEmpty) score += 10;
    
    // CV et liens (20 points)
    if (currentCVId != null) score += 10;
    if (linkedinUrl?.isNotEmpty == true) score += 3;
    if (githubUrl?.isNotEmpty == true) score += 3;
    if (portfolioUrl?.isNotEmpty == true) score += 2;
    if (websiteUrl?.isNotEmpty == true) score += 2;
    
    return score.clamp(0, 100);
  }
}

// Modèle d'expérience professionnelle
class WorkExperience {
  final String id;
  final String company;
  final String position;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool current;
  final String? location;

  WorkExperience({
    required this.id,
    required this.company,
    required this.position,
    this.description,
    required this.startDate,
    this.endDate,
    this.current = false,
    this.location,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['id'] ?? '',
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      description: json['description'],
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate(),
      current: json['current'] ?? false,
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'current': current,
      'location': location,
    };
  }
}

// Modèle d'éducation
class Education {
  final String id;
  final String institution;
  final String degree;
  final String? field;
  final DateTime startDate;
  final DateTime? endDate;
  final String? grade;
  final String? description;

  Education({
    required this.id,
    required this.institution,
    required this.degree,
    this.field,
    required this.startDate,
    this.endDate,
    this.grade,
    this.description,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] ?? '',
      institution: json['institution'] ?? '',
      degree: json['degree'] ?? '',
      field: json['field'],
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate(),
      grade: json['grade'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution': institution,
      'degree': degree,
      'field': field,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'grade': grade,
      'description': description,
    };
  }
}

// Statut du profil
enum ProfileStatus {
  incomplete,
  complete,
  verified,
  suspended
}

// Modèle de CV
class CVModel {
  final String id;
  final String candidateId;
  final String fileName;
  final String downloadUrl;
  final int fileSize;
  final String contentType;
  final DateTime uploadedAt;
  final String? extractedText;
  final Map<String, dynamic> metadata;

  CVModel({
    required this.id,
    required this.candidateId,
    required this.fileName,
    required this.downloadUrl,
    required this.fileSize,
    required this.contentType,
    required this.uploadedAt,
    this.extractedText,
    this.metadata = const {},
  });

  factory CVModel.fromJson(Map<String, dynamic> json) {
    return CVModel(
      id: json['id'] ?? '',
      candidateId: json['candidateId'] ?? '',
      fileName: json['fileName'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      contentType: json['contentType'] ?? '',
      uploadedAt: (json['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      extractedText: json['extractedText'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidateId': candidateId,
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'contentType': contentType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'extractedText': extractedText,
      'metadata': metadata,
    };
  }
}

