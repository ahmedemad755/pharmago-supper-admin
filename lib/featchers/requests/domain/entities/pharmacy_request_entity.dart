import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supper_admin/core/enum/request_enum.dart';

class PharmacyRequestEntity {
  final String uId;
  final String pharmacyName;
  final String email;
  final String phoneNumber;
  final String address;
  final String licenseUrl;
  final RequestStatus status;
  final String role;
  final DateTime createdAt;
  // الحقول الجديدة
  final String pharmacistName;
  final String pharmacistId;
  final String licenseNumber;
  final String nationalId;
  final String? rejectionReason;
  final bool isDeleted;

  PharmacyRequestEntity({
    required this.uId,
    required this.pharmacyName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.licenseUrl,
    required this.status,
    required this.role,
    required this.createdAt,
    required this.pharmacistName,
    required this.pharmacistId,
    required this.licenseNumber,
    required this.nationalId,
    this.rejectionReason,
    this.isDeleted = false,
  });
  // إضافة هذه الدالة لتحويل البيانات من Firestore
  factory PharmacyRequestEntity.fromJson(Map<String, dynamic> json) {
    return PharmacyRequestEntity(
      uId: json['uId'] ?? '',
      pharmacyName: json['pharmacyName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      licenseUrl: json['licenseUrl'] ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => RequestStatus.pending,
      ),
      role: json['role'] ?? 'pharmacy',
      // تحويل Timestamp الخاص بفايربيز إلى DateTime
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      pharmacistName: json['pharmacistName'] ?? '',
      pharmacistId: json['pharmacistId'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      nationalId: json['nationalId'] ?? '',
      rejectionReason: json['rejectionReason'],
    );
  }
}
