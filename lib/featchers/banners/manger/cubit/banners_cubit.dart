import 'package:bloc/bloc.dart';

import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:supper_admin/featchers/banners/entity/BannerEntity.dart';
import 'package:supper_admin/featchers/banners/repos/banners_repo.dart';

part 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  BannersCubit(this.bannersRepo) : super(BannersInitial());

  final BannersRepo bannersRepo;
  
  // تغيير النوع من File ليكون XFile ليدعم الويب والموبايل
  XFile? selectedImage;

  // 1. اختيار صورة من الاستوديو
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // نأخذ الـ XFile مباشرة دون تحويله لـ File(path)
      selectedImage = pickedFile;
      
      // تأكد أن حالة BannerImageSelected تستقبل XFile في ملف الـ state
      emit(BannerImageSelected(selectedImage!));
    }
  }

  // 2. جلب كل العروض
  Future<void> getBanners() async {
    emit(GetBannersLoading());
    final result = await bannersRepo.getBanners();

    result.fold(
      (failure) => emit(GetBannersFailure(failure.message)),
      (banners) => emit(GetBannersSuccess(banners)),
    );
  }

  // 3. إضافة عرض جديد
  Future<void> addBanner({
    required String linkType,
    String? targetId,
    required bool isActive,
  }) async {
    if (selectedImage == null) {
      emit(AddBannerFailure('يرجى اختيار صورة أولاً'));
      return;
    }

    emit(AddBannerLoading());

    final banner = BannerEntity(
      id: '',
      imageUrl: '',
      linkType: linkType,
      targetId: targetId,
      isActive: isActive,
      createdAt: DateTime.now(),
    );

    // الآن سيتم تمرير XFile ليتوافق مع الـ Repo المعدل
    final result = await bannersRepo.addBanner(banner, selectedImage!);

    result.fold(
      (failure) => emit(AddBannerFailure(failure.message)),
      (success) {
        selectedImage = null;
        emit(AddBannerSuccess());
        getBanners();
      },
    );
  }

  // 4. حذف عرض
  Future<void> deleteBanner(BannerEntity banner) async {
    final currentState = state;
    List<BannerEntity> oldBanners = [];
    if (currentState is GetBannersSuccess) {
      oldBanners = currentState.banners;
    }

    emit(GetBannersLoading());

    var result = await bannersRepo.deleteBanner(banner);

    result.fold(
      (failure) {
        emit(GetBannersFailure(failure.message));
        if (oldBanners.isNotEmpty) {
          emit(GetBannersSuccess(oldBanners));
        }
      },
      (success) {
        getBanners();
      },
    );
  }
}