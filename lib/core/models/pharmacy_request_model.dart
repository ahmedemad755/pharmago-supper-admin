import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyRequestModel {
  final String uId;
  final String pharmacyName;
  final String pharmacistName;
  final String email;
  final String phoneNumber;
  final String licenseNumber;
  final String licenseUrl;
  final String nationalId;
  final String address;
  final String status;
  final DateTime createdAt;

  PharmacyRequestModel({
    required this.uId, required this.pharmacyName, required this.pharmacistName,
    required this.email, required this.phoneNumber, required this.licenseNumber,
    required this.licenseUrl, required this.nationalId, required this.address,
    required this.status, required this.createdAt,
  });

  factory PharmacyRequestModel.fromFirestore(Map<String, dynamic> json) {
    return PharmacyRequestModel(
      uId: json['uId'] ?? '',
      pharmacyName: json['pharmacyName'] ?? '',
      pharmacistName: json['pharmacistName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      licenseUrl: json['licenseUrl'] ?? '',
      nationalId: json['nationalId'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}