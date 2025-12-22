import 'package:cloud_firestore/cloud_firestore.dart';

// All possible states of a job application in the app
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

// Main model used to represent a job application
class ApplicationModel {
  // Firestore document ID
  final String id;

  // Related job offer ID
  final String jobId;

  // ID of the candidate who applied
  final String candidateId;

  // ID of the employer who owns the job offer
  final String employerId;

  // Candidate full name
  final String candidateName;

  // Candidate email address
  final String candidateEmail;

  // Candidate phone number (optional)
  final String? candidatePhone;

  // URL of the uploaded CV file
  final String cvUrl;

  // Original CV file name
  final String cvFileName;

  // Optional cover letter text
  final String? coverLetter;

  // Current status of the application
  final ApplicationStatus status;

  // Date when the application was submitted
  final DateTime appliedAt;

  // Date when the application was reviewed by the employer
  final DateTime? reviewedAt;

  // Optional notes written by the employer
  final String? reviewNotes;

  // Optional extra data about the candidate profile
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

  // Build an ApplicationModel from a Firestore document
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
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewNotes: data['reviewNotes'],
      candidateProfile: data['candidateProfile'],
    );
  }

  // Build an ApplicationModel from a JSON object (API or local usage)
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
          : json['reviewedAt'] != null
              ? DateTime.tryParse(json['reviewedAt'])
              : null,
      reviewNotes: json['reviewNotes'],
      candidateProfile: json['candidateProfile'] is Map<String, dynamic>
          ? json['candidateProfile'] as Map<String, dynamic>
          : null,
    );
  }

  // Convert the model into a Firestore-friendly map
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

  // Convert the model into JSON format
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

  // Convert a string value into an ApplicationStatus enum
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

  // Convert an enum status to a string
  static String _statusToString(ApplicationStatus status) {
    return status.toString().split('.').last;
  }

  // Human-readable status label (used in the UI)
  String get statusDisplay {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.viewed:
        return 'Viewed';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
      case ApplicationStatus.accepted:
        return 'Accepted';
    }
  }

  // Helper getters for cleaner UI conditions
  bool get isPending => status == ApplicationStatus.pending;
  bool get isViewed => status == ApplicationStatus.viewed;
  bool get isShortlisted => status == ApplicationStatus.shortlisted;
  bool get isInterviewInternship => status == ApplicationStatus.interview;
  bool get isRejected => status == ApplicationStatus.rejected;
  bool get isHired => status == ApplicationStatus.hired;

  // Create a copy of the application with updated values
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
