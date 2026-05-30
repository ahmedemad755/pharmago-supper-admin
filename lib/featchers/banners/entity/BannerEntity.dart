class BannerEntity {
  final String id; // معرف الوثيقة في Firestore
  final String imageUrl; // رابط الصورة
  final String? targetId; // ID المنتج أو القسم المرتبط (اختياري)
  final String linkType; // نوع الرابط (product, category, none)
  final bool isActive; // حالة العرض (نشط أم لا)
  final DateTime createdAt; // تاريخ الإضافة للترتيب

  BannerEntity({
    required this.id,
    required this.imageUrl,
    this.targetId,
    required this.linkType,
    required this.isActive,
    required this.createdAt,
  });
}
