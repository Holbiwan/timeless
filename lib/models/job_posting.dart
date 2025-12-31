import 'package:cloud_firestore/cloud_firestore.dart';

class JobPosting {
  final String id;
  final String title;
  final String company;
  final String category;
  final String apeCode;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final String jobType;
  final String location;
  final String salaryRange;
  final bool isRemote;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? companyLogo;
  final Map<String, dynamic>? benefits;

  JobPosting({
    required this.id,
    required this.title,
    required this.company,
    required this.category,
    required this.apeCode,
    required this.description,
    required this.responsibilities,
    required this.requirements,
    required this.jobType,
    required this.location,
    required this.salaryRange,
    required this.isRemote,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
    this.companyLogo,
    this.benefits,
  });

  factory JobPosting.fromMap(Map<String, dynamic> map, String documentId) {
    return JobPosting(
      id: documentId,
      title: map['Position'] ?? map['title'] ?? '',
      company: map['CompanyName'] ?? map['company'] ?? '',
      category: map['category'] ?? '',
      apeCode: map['apeCode'] ?? '',
      description: map['Description'] ?? map['description'] ?? '',
      responsibilities: List<String>.from(map['responsibilities'] ?? []),
      requirements: List<String>.from(map['requirements'] ?? []),
      jobType: map['jobType'] ?? 'CDI',
      location: map['location'] ?? '',
      salaryRange: map['salary'] ?? '',
      isRemote: map['isRemote'] ?? false,
      isVerified: map['isFromVerifiedEmployer'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      companyLogo: map['companyLogo'],
      benefits: map['benefits'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Position': title,
      'CompanyName': company,
      'category': category,
      'apeCode': apeCode,
      'Description': description,
      'responsibilities': responsibilities,
      'requirements': requirements,
      'jobType': jobType,
      'location': location,
      'salary': salaryRange,
      'isRemote': isRemote,
      'isFromVerifiedEmployer': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'companyLogo': companyLogo,
      'benefits': benefits,
    };
  }
}

class JobApplication {
  final String id;
  final String jobId;
  final String candidateId;
  final String candidateEmail;
  final String candidateName;
  final String status;
  final DateTime appliedAt;
  final String? coverLetter;
  final String? resumeUrl;
  final Map<String, dynamic>? additionalInfo;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.candidateEmail,
    required this.candidateName,
    required this.status,
    required this.appliedAt,
    this.coverLetter,
    this.resumeUrl,
    this.additionalInfo,
  });

  factory JobApplication.fromMap(Map<String, dynamic> map, String documentId) {
    return JobApplication(
      id: documentId,
      jobId: map['jobId'] ?? '',
      candidateId: map['candidateId'] ?? '',
      candidateEmail: map['candidateEmail'] ?? '',
      candidateName: map['candidateName'] ?? '',
      status: map['status'] ?? 'pending',
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      coverLetter: map['coverLetter'],
      resumeUrl: map['resumeUrl'],
      additionalInfo: map['additionalInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'candidateId': candidateId,
      'candidateEmail': candidateEmail,
      'candidateName': candidateName,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'coverLetter': coverLetter,
      'resumeUrl': resumeUrl,
      'additionalInfo': additionalInfo,
    };
  }
}