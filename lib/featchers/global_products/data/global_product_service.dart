import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supper_admin/featchers/global_products/data/global_product.dart';

class GlobalProductUploadResult {
  final int totalRows;
  final int uploadedRows;
  final List<String> errors;

  const GlobalProductUploadResult({
    required this.totalRows,
    required this.uploadedRows,
    required this.errors,
  });
}

class GlobalProductService {
  static const String collectionPath = 'global_products';

  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  GlobalProductService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      firestore.collection(collectionPath);

  Future<GlobalProduct?> findByBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) return null;

    final snapshot = await _products.doc(normalizedBarcode).get();
    if (!snapshot.exists) return null;
    return GlobalProduct.fromFirestore(snapshot);
  }

  Future<List<PharmacyProductDraft>> matchExcelRows(
    PlatformFile excelFile,
  ) async {
    final rows = _readRows(excelFile);
    final drafts = <PharmacyProductDraft>[];

    for (final row in rows) {
      final barcode = row['barcode'] ?? row['gtin'] ?? row['code'] ?? '';
      if (barcode.isEmpty) continue;

      final draft = PharmacyProductDraft(
        barcode: barcode,
        price: _parseDouble(row['price']),
        cost: _parseDouble(row['cost']),
        unitAmount: _parseInt(row['quantity'] ?? row['unitamount']),
        stockOut: _parseInt(row['stockout']) ?? 0,
        expirationDate: _parseInt(row['expirationdate']) ?? 0,
        discountPercentage: _parseDouble(row['discountpercentage']) ?? 0,
        hasDiscount: _parseBool(row['hasdiscount']),
        isAvailable: !_hasValue(row['isavailable']) ||
            _parseBool(row['isavailable']),
      );

      final globalProduct = await findByBarcode(barcode);
      if (globalProduct != null) {
        draft.applyGlobalProduct(globalProduct);
      } else {
        draft
          ..name = row['name'] ?? ''
          ..category = row['category'] ?? ''
          ..description = row['description'] ?? ''
          ..imageUrl = row['image_url'] ?? row['imageurl'] ?? ''
          ..isPrescriptionRequired = _parsePrescriptionRequired(row);
      }

      drafts.add(draft);
    }

    return drafts;
  }

  Future<void> applyBarcodeToDraft(PharmacyProductDraft draft) async {
    final product = await findByBarcode(draft.barcode);
    if (product != null) {
      draft.applyGlobalProduct(product);
    }
  }

  Future<GlobalProductUploadResult> uploadGlobalProductsExcel(
    PlatformFile excelFile,
  ) async {
    final rows = _readRows(excelFile);
    var uploadedRows = 0;
    final errors = <String>[];
    var batch = firestore.batch();
    var pendingWrites = 0;

    for (var index = 0; index < rows.length; index++) {
      final rowNumber = index + 2;
      final row = rows[index];
      final barcode = (row['barcode'] ?? row['gtin'] ?? row['code'] ?? '').trim();
      final name = (row['name'] ?? row['international_name'] ?? '').trim();

      if (barcode.isEmpty || name.isEmpty) {
        errors.add('Row $rowNumber skipped: barcode and name are required.');
        continue;
      }

      final product = GlobalProduct(
        barcode: barcode,
        name: name,
        category: row['category'] ?? '',
        description: row['description'] ?? '',
        imageUrl: row['image_url'] ?? row['imageurl'] ?? '',
        isPrescriptionRequired: _parsePrescriptionRequired(row),
      );

      batch.set(_products.doc(barcode), product.toMap(), SetOptions(merge: true));
      uploadedRows++;
      pendingWrites++;

      if (pendingWrites == 450) {
        await batch.commit();
        batch = firestore.batch();
        pendingWrites = 0;
      }
    }

    if (pendingWrites > 0) {
      await batch.commit();
    }

    return GlobalProductUploadResult(
      totalRows: rows.length,
      uploadedRows: uploadedRows,
      errors: errors,
    );
  }

  Future<String> uploadProductImage({
    required String barcode,
    required Uint8List bytes,
    String extension = 'jpg',
  }) async {
    final normalizedExtension = extension.replaceAll('.', '').toLowerCase();
    final ref = storage.ref('global_products/$barcode.$normalizedExtension');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/$normalizedExtension'),
    );
    return ref.getDownloadURL();
  }

  Future<void> batchWritePharmacyInventory({
    required String pharmacyId,
    required List<PharmacyProductDraft> drafts,
  }) async {
    final invalidRows = drafts.where((draft) => !draft.isReadyForSubmit);
    if (invalidRows.isNotEmpty) {
      throw StateError('Please complete all required product rows first.');
    }

    var batch = firestore.batch();
    var pendingWrites = 0;

    for (final draft in drafts) {
      final doc = firestore.collection('products').doc(draft.barcode);

      batch.set(
        doc,
        {
          ...draft.toPharmacyInventoryMap(),
          'pharmacyId': pharmacyId,
        },
        SetOptions(merge: true),
      );
      pendingWrites++;

      if (pendingWrites == 450) {
        await batch.commit();
        batch = firestore.batch();
        pendingWrites = 0;
      }
    }

    if (pendingWrites > 0) {
      await batch.commit();
    }
  }

  List<Map<String, String>> _readRows(PlatformFile file) {
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('Pick the Excel file with bytes enabled.');
    }

    final excel = Excel.decodeBytes(bytes);
    final table = excel.tables.values.firstOrNull;
    if (table == null || table.rows.length < 2) return [];

    final headers = table.rows.first
        .map((cell) => _normalizeHeader(cell?.value?.toString() ?? ''))
        .toList();

    return table.rows.skip(1).map((row) {
      final mappedRow = <String, String>{};
      for (var index = 0; index < headers.length; index++) {
        final header = headers[index];
        if (header.isEmpty) continue;
        mappedRow[header] = index < row.length
            ? (row[index]?.value?.toString().trim() ?? '')
            : '';
      }
      return mappedRow;
    }).toList();
  }

  String _normalizeHeader(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
  }

  static bool _parseBool(String? value) {
    final normalized = value?.trim().toLowerCase();
    return normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'y' ||
        normalized == '1' ||
        normalized == 'required';
  }

  static bool _parsePrescriptionRequired(Map<String, String> row) {
    return _parseBool(
      row['is_prescription_required'] ??
          row['is_prescription'] ??
          row['isprescriptionrequired'] ??
          row['isprescription'] ??
          row['prescription_required'] ??
          row['prescription'] ??
          row['rx'],
    );
  }

  static double? _parseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  static int? _parseInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }

  static bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
