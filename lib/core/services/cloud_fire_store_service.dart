
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supper_admin/core/services/database_service.dart';

class FireStoreService implements DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Query<Map<String, dynamic>> _applyQueryModifiers(
    Query<Map<String, dynamic>> query,
    Map<String, dynamic>? queryParams,
  ) {
    if (queryParams == null) return query;
    if (queryParams['orderBy'] != null) {
      query = query.orderBy(
        queryParams['orderBy'],
        descending: queryParams['descending'] ?? false,
      );
    }
    if (queryParams['limit'] != null) {
      query = query.limit(queryParams['limit']);
    }
    return query;
  }

  @override
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    required String documentId, // سيتم استلام المعرف المدمج هنا
  }) async {
    // التعديل هنا لضمان عدم المسح: سيتم استخدام ID فريد لكل صيدلية
    await firestore.collection(path).doc(documentId).set(data);
  }

  @override
  Future<void> setData({
    required String path,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(path).doc(id).set(data, SetOptions(merge: true));
  }

  @override
  Future<bool> checkIfDataExists({
    required String documentId,
    required String path,
  }) async {
    final doc = await firestore.collection(path).doc(documentId).get();
    return doc.exists;
  }

  @override
  Future<List<Map<String, dynamic>>> getData({
    required String path,
    String? docuementId,
    Map<String, dynamic>? query,
  }) async {
    if (docuementId != null) {
      final doc = await firestore.collection(path).doc(docuementId).get();
      return doc.exists ? [doc.data()!] : [];
    }
    Query<Map<String, dynamic>> ref = firestore.collection(path);
    ref = _applyQueryModifiers(ref, query);
    final result = await ref.get();
    return result.docs.map((e) => e.data()).toList();
  }

  @override
  Stream<dynamic> getDataStream({
    required String path,
    Map<String, dynamic>? query,
  }) {
    // 1. نبدأ بالإشارة للكوليكشن الأساسي
    Query collection = firestore.collection(path);

    // 2. إذا تم إرسال query، نقوم بتطبيق الفلترة
    if (query != null) {
      // نفترض أن الـ query يحتوي على 'field' و 'value'
      collection = collection.where(query['field'], isEqualTo: query['value']);
    }

    // 3. نرجع الـ Stream مع تحويل الـ QuerySnapshot إلى List من البيانات
    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Future<void> updateOrder({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(path).doc(documentId).update(data);
  }

  @override
  Future<void> deleteData({
    required String path,
    required String documentId,
  }) async {
    await firestore.collection(path).doc(documentId).delete();
  }
}
