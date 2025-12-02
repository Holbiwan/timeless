import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  pending,
  viewed,
  shortlisted,
  interview,
  rejected,
  hired,
  withdrawn,
  accepted,
}

class ApplicationModel {
  final String id;
  final String jobId;
  final String candidateId;
  final String employerId;
  final String candidateName;
  final String candidateEmail;
  final String? candidatePhone;
  final String cvUrl;
  final String cvFileName;
  final String? coverLetter;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final Map<String, dynamic>? candidateProfile;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.employerId,
    required this.candidateName,
    required this.candidateEmail,
    this.candidatePhone,
    required this.cvUrl,
    required this.cvFileName,
    this.coverLetter,
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
    this.reviewedAt,
    this.reviewNotes,
    this.candidateProfile,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      candidateId: data['candidateId'] ?? '',
      employerId: data['employerId'] ?? '',
      candidateName: data['candidateName'] ?? '',
      candidateEmail: data['candidateEmail'] ?? '',
      candidatePhone: data['candidatePhone'],
      cvUrl: data['cvUrl'] ?? '',
      cvFileName: data['cvFileName'] ?? '',
      coverLetter: data['coverLetter'],
      status: _parseApplicationStatus(data['status']),
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null ? (data['reviewedAt'] as Timestamp).toDate() : null,
      reviewNotes: data['reviewNotes'],
      candidateProfile: data['candidateProfile'],
    );
  }

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      candidateId: json['candidateId'] ?? '',
      employerId: json['employerId'] ?? '',
      candidateName: json['candidateName'] ?? '',
      candidateEmail: json['candidateEmail'] ?? '',
      candidatePhone: json['candidatePhone'],
      cvUrl: json['cvUrl'] ?? '',
      cvFileName: json['cvFileName'] ?? '',
      coverLetter: json['coverLetter'],
      status: _parseApplicationStatus(json['status']),
      appliedAt: json['appliedAt'] is Timestamp 
          ? (json['appliedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['appliedAt'] ?? '') ?? DateTime.now(),
      reviewedAt: json['reviewedAt'] is Timestamp 
          ? (json['reviewedAt'] as Timestamp).toDate()
          : json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt']) : null,
      reviewNotes: json['reviewNotes'],
      candidateProfile: json['candidateProfile'] is Map<String, dynamic> 
          ? json['candidateProfile'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'candidateId': candidateId,
      'employerId': employerId,
      'candidateName': candidateName,
      'candidateEmail': candidateEmail,
      'candidatePhone': candidatePhone,
      'cvUrl': cvUrl,
      'cvFileName': cvFileName,
      'coverLetter': coverLetter,
      'status': _statusToString(status),
      'appliedAt': Timestamp.fromDate(appliedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewNotes': reviewNotes,
      'candidateProfile': candidateProfile,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'candidateId': candidateId,
      'employerId': employerId,
      'candidateName': candidateName,
      'candidateEmail': candidateEmail,
      'candidatePhone': candidatePhone,
      'cvUrl': cvUrl,
      'cvFileName': cvFileName,
      'coverLetter': coverLetter,
      'status': _statusToString(status),
      'appliedAt': appliedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
      'candidateProfile': candidateProfile,
    };
  }

  static ApplicationStatus _parseApplicationStatus(String? status) {
    switch (status) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'viewed':
        return ApplicationStatus.viewed;
      case 'shortlisted':
        return ApplicationStatus.shortlisted;
      case 'interview':
        return ApplicationStatus.interview;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'hired':
        return ApplicationStatus.hired;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      case 'accepted':
        return ApplicationStatus.accepted;
      default:
        return ApplicationStatus.pending;
    }
  }

  static String _statusToString(ApplicationStatus status) {
    return status.toString().split('.').last;
  }

  String get statusDisplay {
    switch (status) {
      case ApplicationStatus.pending:
        return 'En attente';
      case ApplicationStatus.viewed:
        return 'Vue';
      case ApplicationStatus.shortlisted:
        return 'Présélectionnée';
      case ApplicationStatus.interview:
        return 'Entretien';
      case ApplicationStatus.rejected:
        return 'Refusée';
      case ApplicationStatus.hired:
        return 'Embauchée';
      case ApplicationStatus.withdrawn:
        return 'Retirée';
      case ApplicationStatus.accepted:
        return 'Acceptée';
    }
  }

  bool get isPending => status == ApplicationStatus.pending;
  bool get isViewed => status == ApplicationStatus.viewed;
  bool get isShortlisted => status == ApplicationStatus.shortlisted;
  bool get isInterviewStage => status == ApplicationStatus.interview;
  bool get isRejected => status == ApplicationStatus.rejected;
  bool get isHired => status == ApplicationStatus.hired;

  ApplicationModel copyWith({
    String? id,
    String? jobId,
    String? candidateId,
    String? employerId,
    String? candidateName,
    String? candidateEmail,
    String? candidatePhone,
    String? cvUrl,
    String? cvFileName,
    String? coverLetter,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? reviewNotes,
    Map<String, dynamic>? candidateProfile,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      candidateId: candidateId ?? this.candidateId,
      employerId: employerId ?? this.employerId,
      candidateName: candidateName ?? this.candidateName,
      candidateEmail: candidateEmail ?? this.candidateEmail,
      candidatePhone: candidatePhone ?? this.candidatePhone,
      cvUrl: cvUrl ?? this.cvUrl,
      cvFileName: cvFileName ?? this.cvFileName,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      candidateProfile: candidateProfile ?? this.candidateProfile,
    );
  }
}