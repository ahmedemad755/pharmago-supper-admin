import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supper_admin/core/enum/request_enum.dart';
import 'package:supper_admin/featchers/requests/domain/entities/pharmacy_request_entity.dart';

class PharmacyRequestModel extends PharmacyRequestEntity {
  PharmacyRequestModel({
    required super.uId,
    required super.pharmacyName,
    required super.email,
    required super.phoneNumber,
    required super.address,
    required super.licenseUrl,
    required super.status,
    required super.role,
    required super.createdAt,
    required super.pharmacistName,
    required super.pharmacistId,
    required super.licenseNumber,
    required super.nationalId,
    super.rejectionReason,
  });

  factory PharmacyRequestModel.fromJson(Map<String, dynamic> json) {
    return PharmacyRequestModel(
      uId: json['uId'] ?? '',
      pharmacyName: json['pharmacyName'] ?? '',
      rejectionReason: json['rejectionReason'] as String?,
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      licenseUrl: json['licenseUrl'] ?? '',
      status: RequestStatus.values.firstWhere(
  // نقوم بمقارنة اسم الـ Enum مع النص القادم من قاعدة البيانات
  (e) => e.name == (json['status']?.toString() ?? 'pending'),
  // في حال كانت القيمة في قاعدة البيانات غير معروفة، نضعها pending كافتراضي
  orElse: () => RequestStatus.pending,
),
      role: json['role'] ?? 'pharmacy',
      pharmacistName: json['pharmacistName'] ?? '',
      pharmacistId: json['pharmacistId'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      nationalId: json['nationalId'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'pharmacyName': pharmacyName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'licenseUrl': licenseUrl,
      'status': status.name, // نحفظ اسم الـ Enum في قاعدة البيانات
      'role': role,
      'pharmacistName': pharmacistName,
      'pharmacistId': pharmacistId,
      'licenseNumber': licenseNumber,
      'createdAt': createdAt,
      'nationalId': nationalId,
      'rejectionReason': rejectionReason,
    };
  }

  factory PharmacyRequestModel.fromEntity(PharmacyRequestEntity entity) {
    return PharmacyRequestModel(
      uId: entity.uId,
      pharmacyName: entity.pharmacyName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      licenseUrl: entity.licenseUrl,
      status: entity.status,
      role: entity.role,
      createdAt: entity.createdAt,
      pharmacistName: entity.pharmacistName,
      pharmacistId: entity.pharmacistId,
      licenseNumber: entity.licenseNumber,
      nationalId: entity.nationalId,
      rejectionReason: entity.rejectionReason,
    );
  }
}
