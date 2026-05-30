import 'package:supper_admin/featchers/banners/entity/BannerEntity.dart';

class BannerModel extends BannerEntity {
  BannerModel({
    required super.id,
    required super.imageUrl,
    super.targetId,
    required super.linkType,
    required super.isActive,
    required super.createdAt,
  });

  // تحويل البيانات من JSON إلى Model
  factory BannerModel.fromJson(Map<String, dynamic> json, String documentId) {
    return BannerModel(
      // نأخذ الـ ID من الحقل المخزن في الـ Json، وإذا لم يوجد نستخدم documentId الممرر
      id: json['id']?.toString() ?? documentId,
      imageUrl: json['image_url'] ?? '',
      targetId: json['target_id'],
      linkType: json['link_type'] ?? 'none',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? (json['created_at'] is String
                ? DateTime.parse(json['created_at'])
                : json['created_at'].toDate())
          : DateTime.now(),
    );
  }

  // تحويل الـ Entity إلى JSON لحفظه
  Map<String, dynamic> toJson() {
    return {
      'id': id, // مهم جداً حفظ الـ ID داخل الوثيقة لسهولة استرجاعه
      'image_url': imageUrl,
      'target_id': targetId,
      'link_type': linkType,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  factory BannerModel.fromEntity(BannerEntity entity) {
    return BannerModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      targetId: entity.targetId,
      linkType: entity.linkType,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
