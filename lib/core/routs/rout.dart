// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supper_admin/core/di/injection.dart';
import 'package:supper_admin/featchers/banners/manger/cubit/banners_cubit.dart';
import 'package:supper_admin/featchers/banners/presentation/views/BannersManagementView.dart';
import 'package:supper_admin/featchers/global_products/presentation/views/global_products_upload_view.dart';
import 'package:supper_admin/featchers/requests/presentation/manger/cubit/request_pharmacy_cubit.dart';
import '../../featchers/requests/presentation/views/admin_home_view.dart';
// استورد أي صفحات أخرى هنا

class AppRoutes {
  static const String adminHome = 'adminHome';
  static const String requestDetails = 'requestDetails'; // مثال لصفحة تفاصيل الطلب
  static const String bannersManagement = 'bannersManagement';
  static const String globalProductsUpload = 'globalProductsUpload';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
 case AppRoutes.adminHome:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          // هنا نقوم بإنشاء الكيوبيت واستدعاء الدالة فوراً
          create: (context) => getIt<RequestsCubit>()..fetchAllRequests(),
          child: const AdminHomeView(),
        ),
      );

    // مثال لكيفية تمرير بيانات لصفحة التفاصيل
    /*
    case AppRoutes.requestDetails:
      final request = settings.arguments as PharmacyRequestEntity;
      return MaterialPageRoute(
        builder: (context) => RequestDetailsView(request: request),
      );
    */

        case AppRoutes.bannersManagement:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt.get<BannersCubit>()..getBanners(),
          child: const BannersManagementView(),
        ),
      );

    case AppRoutes.globalProductsUpload:
      return MaterialPageRoute(
        builder: (context) => const GlobalProductsUploadView(),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('No route defined')),
        ),
      );
  }
}
