
import 'package:dartz/dartz.dart';

import 'package:image_picker/image_picker.dart';
import 'package:supper_admin/core/backend/backend_points.dart';
import 'package:supper_admin/core/errors/faliur.dart';
import 'package:supper_admin/core/services/database_service.dart';
import 'package:supper_admin/core/services/storge_service.dart';
import 'package:supper_admin/featchers/banners/BannerModel.dart';
import 'package:supper_admin/featchers/banners/entity/BannerEntity.dart';
import 'package:supper_admin/featchers/banners/repos/banners_repo.dart';

class BannersRepoImpl implements BannersRepo {
  final DatabaseService databaseService;
  final StorgeService storgeService;

  BannersRepoImpl({required this.databaseService, required this.storgeService});

  @override
  Future<Either<Faliur, void>> addBanner(
    BannerEntity banner,
    XFile image,
  ) async {
    try {
      // 1. رفع الصورة إلى Storage
      String? imageUrl = await storgeService.uploadImage(
        image,
        BackendPoints.bannersImages,
      );

      if (imageUrl == null) {
        return Left(ServerFaliur('فشل في رفع الصورة، يرجى المحاولة لاحقاً'));
      }

      // 2. توليد ID فريد للمستند (Timestamp بالملي ثانية لضمان التفرد)
      String docId = DateTime.now().millisecondsSinceEpoch.toString();

      final bannerModel = BannerModel(
        id: docId,
        imageUrl: imageUrl,
        targetId: banner.targetId,
        linkType: banner.linkType,
        isActive: banner.isActive,
        createdAt: banner.createdAt,
      );

      // 3. حفظ البيانات في قاعدة البيانات مع الـ ID المولد
      await databaseService.addData(
        path: BackendPoints.banners,
        data: bannerModel.toJson(),
        documentId: docId,
      );

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFaliur('عذراً، حدث خطأ أثناء إضافة العرض: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Faliur, List<BannerEntity>>> getBanners() async {
    try {
      final data =
          await databaseService.getData(path: BackendPoints.banners)
              as List<Map<String, dynamic>>;

      // تحويل البيانات القادمة إلى List من BannerEntity
      final banners = data.map((e) {
        // نأخذ الـ ID المخزن في الحقل 'id' داخل المستند
        String fetchedId =
            e['id']?.toString() ?? e['documentId']?.toString() ?? '';
        return BannerModel.fromJson(e, fetchedId);
      }).toList();

      // ترتيب العروض بحيث تظهر الأحدث أولاً
      banners.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Right(banners);
    } catch (e) {
      return Left(ServerFaliur('فشل في جلب العروض: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Faliur, void>> deleteBanner(BannerEntity banner) async {
    try {
      // التحقق الأمني من الـ ID
      if (banner.id.isEmpty) {
        return Left(ServerFaliur('لا يمكن إتمام الحذف: معرف العرض مفقود'));
      }

      // 1. حذف المستند من قاعدة البيانات (الأولوية للبيانات)
      await databaseService.deleteData(
        path: BackendPoints.banners,
        documentId: banner.id,
      );

      // 2. محاولة حذف الملف من Storage (اختياري)
      try {
        await storgeService.deleteFile(banner.imageUrl);
      } catch (storageError) {
        // لا نعيد Failure هنا لأن البيانات حُذفت بالفعل من قاعدة البيانات
        print("Storage deletion warning: $storageError");
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFaliur('حدث خطأ أثناء محاولة الحذف من السيرفر'));
    }
  }

  @override
  Future<Either<Faliur, void>> updateBannerStatus(
    String id,
    bool isActive,
  ) async {
    try {
      await databaseService.setData(
        path: BackendPoints.banners,
        id: id,
        data: {'is_active': isActive},
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFaliur('فشل في تحديث حالة العرض'));
    }
  }
}
