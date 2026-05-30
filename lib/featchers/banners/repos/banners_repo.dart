
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supper_admin/core/errors/faliur.dart';
import 'package:supper_admin/featchers/banners/entity/BannerEntity.dart' show BannerEntity;


abstract class BannersRepo {
  // إضافة عرض جديد (تشمل رفع الصورة ثم حفظ البيانات)
  Future<Either<Faliur, void>> addBanner(BannerEntity banner, XFile image);
  
  // جلب كل العروض لعرضها في جدول أو قائمة بالداش بورد
  Future<Either<Faliur, List<BannerEntity>>> getBanners();
  
  // حذف عرض (حذف الصورة من الـ Storage والبيانات من Firestore)
  Future<Either<Faliur, void>> deleteBanner(BannerEntity banner);
  
  // تعديل حالة العرض (نشط / غير نشط)
  Future<Either<Faliur, void>> updateBannerStatus(String id, bool isActive);
}