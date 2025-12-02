import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerModel {
  final String id;
  final String email;
  final String companyName;
  final String siretCode;
  final String apeCode;
  final String address;
  final String postalCode;
  final String country;
  final String? phoneNumber;
  final String? contactPerson;
  final DateTime createdAt;
  final bool isVerified;

  EmployerModel({
    required this.id,
    required this.email,
    required this.companyName,
    required this.siretCode,
    required this.apeCode,
    required this.address,
    required this.postalCode,
    required this.country,
    this.phoneNumber,
    this.contactPerson,
    required this.createdAt,
    this.isVerified = false,
  });

  factory EmployerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EmployerModel(
      id: doc.id,
      email: data['email'] ?? '',
      companyName: data['companyName'] ?? '',
      siretCode: data['siretCode'] ?? '',
      apeCode: data['apeCode'] ?? '',
      address: data['address'] ?? '',
      postalCode: data['postalCode'] ?? '',
      country: data['country'] ?? '',
      phoneNumber: data['phoneNumber'],
      contactPerson: data['contactPerson'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'companyName': companyName,
      'siretCode': siretCode,
      'apeCode': apeCode,
      'address': address,
      'postalCode': postalCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'contactPerson': contactPerson,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
      'userType': 'employer',
    };
  }

  EmployerModel copyWith({
    String? id,
    String? email,
    String? companyName,
    String? siretCode,
    String? apeCode,
    String? address,
    String? postalCode,
    String? country,
    String? phoneNumber,
    String? contactPerson,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return EmployerModel(
      id: id ?? this.id,
      email: email ?? this.email,
      companyName: companyName ?? this.companyName,
      siretCode: siretCode ?? this.siretCode,
      apeCode: apeCode ?? this.apeCode,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactPerson: contactPerson ?? this.contactPerson,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}