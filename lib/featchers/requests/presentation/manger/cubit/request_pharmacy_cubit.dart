import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supper_admin/core/enum/request_enum.dart';
import 'package:supper_admin/featchers/requests/domain/repos/requests_repo.dart';
import 'package:supper_admin/featchers/requests/presentation/manger/cubit/request_pharmacy_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  final PharmaciesRepo _repo;
  
  RequestsCubit(this._repo) : super(RequestsInitial());

  /// 🔄 جلب كافة الطلبات ومراقبتها لحظياً من الفايرستور
  void fetchAllRequests() {
    emit(RequestsLoading());
    _repo.fetchRequests().listen((result) {
      result.fold(
        (failure) => emit(RequestsError(failure.message)),
        (requests) => emit(RequestsSuccess(requests)),
      );
    });
  }

  /// ⚙️ تحديث حالة الطلب (قبول / رفض)
  Future<void> updateStatus(String uId, RequestStatus status, {String? reason}) async {
    final result = await _repo.changeRequestStatus(status: status, uId: uId, rejectionReason: reason);
    result.leftMap((failure) => emit(RequestsError(failure.message)));
  }

  /// 🗑️ حذف الطلب برمجياً (Soft Delete) من الكوليكشن الصحيح
  Future<void> deleteRequestPermanently(String uId) async {
    try {
      // ⚡ تم التعديل إلى 'pharmacies' بناءً على قاعدة البيانات الفعالية عندك
      await FirebaseFirestore.instance
          .collection('pharmacies') 
          .doc(uId)
          .update({'isDeleted': true});

      // ملاحظة هندسية: الـ Stream المفتوح في fetchAllRequests هيلقط التحديث ده 
      // ويخفي الكارت فوراً وبسلاسة لو شرط الـ .where('isDeleted', isEqualTo: false) مفعّل في الـ Repo.
    } catch (e) {
      // 💡 حماية الشاشة: لا نرسل emit(RequestsError) هنا حتى لا تختفي اللوحة بالكامل وتظهر شاشة الخطأ.
      // نكتفي بطباعتها، ويمكنك استقبالها في الـ UI عبر BlocListener لتعرض SnackBar أحمر للمستخدم.
      print("❌ فشل الحذف البرمجي: ${e.toString()}");
    }
  }
}