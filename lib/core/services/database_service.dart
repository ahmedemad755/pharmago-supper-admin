import 'dart:core';

abstract class DatabaseService {
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    required String documentId,
  });

  Future<dynamic> getData({
    required String path,
    String? docuementId,
    Map<String, dynamic>? query,
  });


  Stream<dynamic> getDataStream({
    required String path,
    Map<String, dynamic>? query,
  });

  Future<void> setData({
    required String path,
    required String id,
    required Map<String, dynamic> data,
  });

  Future<bool> checkIfDataExists({
    required String documentId,
    required String path,
  });

  Future<void> updateOrder({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  });

  // أضف هذه الدالة في الـ Abstract class
Future<void> deleteData({
  required String path,
  required String documentId,
});
}
