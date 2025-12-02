// Modèle utilisateur pour Firestore
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String role; // 'candidate' ou 'recruiter'
  final DateTime createdAt;
  final Map<String, dynamic>? profile;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.role,
    required this.createdAt,
    this.profile,
  });

  // Conversion depuis Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      role: json['role'] ?? 'candidate',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      profile: json['profile'],
    );
  }

  // Conversion vers Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'profile': profile ?? {},
    };
  }

  // Copie avec modifications
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? role,
    DateTime? createdAt,
    Map<String, dynamic>? profile,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      profile: profile ?? this.profile,
    );
  }
}