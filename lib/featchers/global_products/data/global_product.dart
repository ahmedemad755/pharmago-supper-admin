import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalProduct {
  final String barcode;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final bool isPrescriptionRequired;

  const GlobalProduct({
    required this.barcode,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.isPrescriptionRequired,
  });

  factory GlobalProduct.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return GlobalProduct.fromMap({
      ...data,
      'barcode': data['barcode'] ?? snapshot.id,
    });
  }

  factory GlobalProduct.fromMap(Map<String, dynamic> data) {
    return GlobalProduct(
      barcode:
          (data['barcode'] ?? data['code'])?.toString().trim() ?? '',
      name: data['name']?.toString().trim() ?? '',
      category: data['category']?.toString().trim() ?? '',
      description: data['description']?.toString().trim() ?? '',
      imageUrl:
          (data['image_url'] ?? data['imageurl'])?.toString().trim() ?? '',
      isPrescriptionRequired: _parseBool(
        data['is_prescription_required'] ?? data['isPrescriptionRequired'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'code': barcode,
      'name': name,
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'imageurl': imageUrl,
      'is_prescription_required': isPrescriptionRequired,
      'isPrescriptionRequired': isPrescriptionRequired,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'y' ||
        normalized == '1' ||
        normalized == 'required';
  }
}

class PharmacyProductDraft {
  final String barcode;
  GlobalProduct? globalProduct;
  String name;
  String category;
  String description;
  String imageUrl;
  bool isPrescriptionRequired;
  double? price;
  double? cost;
  int? unitAmount;
  int stockOut;
  int expirationDate;
  double discountPercentage;
  bool hasDiscount;
  bool isAvailable;

  PharmacyProductDraft({
    required this.barcode,
    this.globalProduct,
    this.name = '',
    this.category = '',
    this.description = '',
    this.imageUrl = '',
    this.isPrescriptionRequired = false,
    this.price,
    this.cost,
    this.unitAmount,
    this.stockOut = 0,
    this.expirationDate = 0,
    this.discountPercentage = 0,
    this.hasDiscount = false,
    this.isAvailable = true,
  });

  bool get isMatched => globalProduct != null;
  bool get isReadyForSubmit =>
      barcode.isNotEmpty &&
      name.trim().isNotEmpty &&
      category.trim().isNotEmpty &&
      price != null &&
      price! >= 0 &&
      unitAmount != null &&
      unitAmount! >= 0;

  void applyGlobalProduct(GlobalProduct product) {
    globalProduct = product;
    name = product.name;
    category = product.category;
    description = product.description;
    imageUrl = product.imageUrl;
    isPrescriptionRequired = product.isPrescriptionRequired;
  }

  Map<String, dynamic> toPharmacyInventoryMap() {
    return {
      'averageRating': 0,
      'code': barcode,
      'name': name.trim(),
      'category': category.trim(),
      'description': description.trim(),
      'imageurl': imageUrl.trim(),
      'isPrescriptionRequired': isPrescriptionRequired,
      'cost': cost ?? price ?? 0,
      'discountPercentage': discountPercentage,
      'expirationDate': expirationDate,
      'hasDiscount': hasDiscount,
      'isAvailable': isAvailable,
      'price': price,
      'ratingcount': 0,
      'reviews': <Map<String, dynamic>>[],
      'sellingcount': 0,
      'stockOut': stockOut,
      'unitAmount': unitAmount,
      'globalProductRef': barcode,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
