part of 'banners_cubit.dart';

@immutable
abstract class BannersState {}

class BannersInitial extends BannersState {}

// حالات جلب العروض
class GetBannersLoading extends BannersState {}
class GetBannersSuccess extends BannersState {
  final List<BannerEntity> banners;
  GetBannersSuccess(this.banners);
}
class GetBannersFailure extends BannersState {
  final String errMessage;
  GetBannersFailure(this.errMessage);
}

// حالات إضافة عرض جديد
class AddBannerLoading extends BannersState {}
class AddBannerSuccess extends BannersState {}
class AddBannerFailure extends BannersState {
  final String errMessage;
  AddBannerFailure(this.errMessage);
}

// حالة تغيير الصورة محلياً (قبل الرفع)
class BannerImageSelected extends BannersState {
  final XFile image;
  BannerImageSelected(this.image);
}