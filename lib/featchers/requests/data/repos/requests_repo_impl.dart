import 'package:dartz/dartz.dart';
import '../../../../core/backend/backend_points.dart';
import '../../../../core/enum/request_enum.dart';
import '../../../../core/errors/faliur.dart';
import '../../../../core/services/database_service.dart';
import '../../domain/entities/pharmacy_request_entity.dart';
import '../../domain/repos/requests_repo.dart';
// تأكد من عمل Import للـ PharmacyRequestModel عشان الفلترة الذكية
import '../../data/models/pharmacy_request_model.dart'; 

class PharmaciesRepoImpl implements PharmaciesRepo {
  final DatabaseService _dataService;
  PharmaciesRepoImpl(this._dataService);

  @override
  Stream<Either<Faliur, List<PharmacyRequestEntity>>> fetchRequests() {
    return _dataService.getDataStream(
      path: BackendPoints.pharmacies, 
    ).map((snapshot) {
      try {
        final List<dynamic> data = snapshot as List<dynamic>;
        
        final List<PharmacyRequestEntity> requests = data
            .map((e) {
              // 1️⃣ تحويل الداتا أولاً باستخدام الـ Model اللي بيدعم حقل isDeleted
              return PharmacyRequestModel.fromJson(Map<String, dynamic>.from(e));
            })
            // 2️⃣ 🔥 الفلترة السحرية: استبعاد أي صيدلية حقل isDeleted فيها بيساوي true
            .where((request) => request.isDeleted == false) 
            .toList();

        return Right(requests);
      } catch (e) {
        return Left(ServerFaliur('حدث خطأ أثناء معالجة البيانات: $e'));
      }
    });
  }

  @override
  Future<Either<Faliur, void>> changeRequestStatus({
    required RequestStatus status,
    required String uId,
    String? rejectionReason,
  }) async {
    try {
      await _dataService.updateOrder(
        path: BackendPoints.pharmacies,
        documentId: uId,
        data: {
          'status': status.name,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFaliur('فشل في تحديث حالة الطلب'));
    }
  }
}