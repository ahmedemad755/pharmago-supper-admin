import 'package:dartz/dartz.dart';
import '../../../../core/enum/request_enum.dart';
import '../../../../core/errors/faliur.dart';
import '../entities/pharmacy_request_entity.dart';

abstract class PharmaciesRepo {
  // جلب كل طلبات انضمام الصيدليات
  Stream<Either<Faliur, List<PharmacyRequestEntity>>> fetchRequests();

  // تغيير حالة الطلب (قبول/رفض/تحت المراجعة)
  Future<Either<Faliur, void>> changeRequestStatus({
    required RequestStatus status,
    required String uId,
    String? rejectionReason,
  });
}