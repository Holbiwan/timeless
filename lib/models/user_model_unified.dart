// This file defines the unified user model used across the app for authentication, profile data, and activity tracking.
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // Basic identifiers
  final String uid;
  final String email;

  // Personal information
  final String firstName;
  final String lastName;
  final String fullName;
  final String? phoneNumber;
  final String? photoURL;

  // Professional information
  final String title;
  final String bio;
  final String experience;
  final String city;

  // User activity
  final List<String> savedJobs;
  final List<String> appliedJobs;

  // Metadata and status
  final String provider;
  final String role;
  final bool profileCompleted;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.phoneNumber,
    this.photoURL,
    required this.title,
    required this.bio,
    required this.experience,
    required this.city,
    required this.savedJobs,
    required this.appliedJobs,
    required this.provider,
    required this.role,
    required this.profileCompleted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  // Build a user model from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      title: data['title'] ?? '',
      bio: data['bio'] ?? '',
      experience: data['experience'] ?? 'junior',
      city: data['city'] ?? '',
      savedJobs: List<String>.from(data['savedJobs'] ?? []),
      appliedJobs: List<String>.from(data['appliedJobs'] ?? []),
      provider: data['provider'] ?? 'email',
      role: data['role'] ?? 'user',
      profileCompleted: data['profileCompleted'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      lastLogin: _parseTimestamp(data['lastLogin']),
    );
  }

  // Convert the user model to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'title': title,
      'bio': bio,
      'experience': experience,
      'city': city,
      'savedJobs': savedJobs,
      'appliedJobs': appliedJobs,
      'provider': provider,
      'role': role,
      'profileCompleted': profileCompleted,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  // Safely parse Firestore timestamps or strings
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String)
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    return DateTime.now();
  }

  // Create a copy with updated values
  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phoneNumber,
    String? photoURL,
    String? title,
    String? bio,
    String? experience,
    String? city,
    List<String>? savedJobs,
    List<String>? appliedJobs,
    String? provider,
    String? role,
    bool? profileCompleted,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      city: city ?? this.city,
      savedJobs: savedJobs ?? this.savedJobs,
      appliedJobs: appliedJobs ?? this.appliedJobs,
      provider: provider ?? this.provider,
      role: role ?? this.role,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Full name displayed in the UI
  String get displayName =>
      fullName.isNotEmpty ? fullName : '$firstName $lastName'.trim();

  // Human-readable experience label
  String get experienceLabel {
    switch (experience) {
      case 'internship':
        return 'Internship / Apprenticeship';
      case 'junior':
        return 'Junior (0-2 years)';
      case 'mid':
        return 'Mid-level (3-5 years)';
      case 'senior':
        return 'Senior (5-10 years)';
      case 'expert':
        return 'Expert (10+ years)';
      default:
        return experience;
    }
  }
}
