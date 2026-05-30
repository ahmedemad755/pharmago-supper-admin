// import 'package:fruitesdashboard/core/services/database_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseDatabaseService implements DatabaseService {
//   final SupabaseClient supabase;

//   SupabaseDatabaseService(this.supabase);

//   // ----------------------------------------------------------
//   // Helper: بناء query أساسي
//   // ----------------------------------------------------------
//   PostgrestFilterBuilder _baseSelect(String path) {
//     return supabase.from(path).select();
//   }

//   // ----------------------------------------------------------
//   // Add Data
//   // ----------------------------------------------------------
//   @override
//   Future<void> addData({
//     required String path,
//     required Map<String, dynamic> data,
//     required String documentId, // غير مستخدم — نفس الـ interface
//   }) async {
//     try {
//       await supabase.from(path).insert(data);
//     } catch (e) {
//       throw Exception('AddData error: $e');
//     }
//   }

//   // ----------------------------------------------------------
//   // Get Data (Single Doc)
//   // ----------------------------------------------------------
//   @override
//   Future<dynamic> getData({
//     required String path,
//     String? docuementId,
//     Map<String, dynamic>? query,
//   }) async {
//     try {
//       if (docuementId == null) {
//         // حفاظًا على نفس الـ logic القديم
//         return {};
//       }

//       final response = await _baseSelect(
//         path,
//       ).eq('id', docuementId as Object).maybeSingle();

//       return response ?? {};
//     } catch (e) {
//       throw Exception('GetData error: $e');
//     }
//   }

//   // ----------------------------------------------------------
//   // Update / SetData
//   // ----------------------------------------------------------
//   @override
//   Future<void> setData({
//     required String path,
//     required String id,
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       await supabase.from(path).update(data).eq('id', id);
//     } catch (e) {
//       throw Exception('SetData error: $e');
//     }
//   }

//   // ----------------------------------------------------------
//   // Check If Exists
//   // ----------------------------------------------------------
//   @override
//   Future<bool> checkIfDataExists({
//     required String path,
//     required String documentId,
//   }) async {
//     try {
//       final response = await _baseSelect(
//         path,
//       ).eq('id', documentId).maybeSingle();

//       return response != null;
//     } catch (e) {
//       throw Exception('CheckIfDataExists error: $e');
//     }
//   }

//   // ----------------------------------------------------------
//   // Stream (بس من غير real-time — نفس منطقك)
//   // ----------------------------------------------------------
//   @override
//   Stream getDataStream({
//     required String path,
//     Map<String, dynamic>? query,
//   }) async* {
//     try {
//       final response = await _baseSelect(path).maybeSingle();
//       yield response ?? {};
//     } catch (e) {
//       throw Exception('GetData error: $e');
//     }
//   }

//   @override
//   Future<void> updateData({
//     required String path,
//     required String documentId,
//     required Map<String, dynamic> data,
//   }) {
//     // TODO: implement updateData
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> updateOrder({
//     required String path,
//     required String documentId,
//     required Map<String, dynamic> data,
//   }) {
//     // TODO: implement updateOrder
//     throw UnimplementedError();
//   }
// }
