import 'package:get_it/get_it.dart';
import 'package:supper_admin/core/services/cloud_fire_store_service.dart';
import 'package:supper_admin/core/services/database_service.dart';
import 'package:supper_admin/core/services/supabase_storge.dart'; // تأكد من صحة مسار الملف
import 'package:supper_admin/featchers/banners/manger/cubit/banners_cubit.dart';
import 'package:supper_admin/featchers/banners/repos/banners_repo.dart';
import 'package:supper_admin/featchers/banners/repos/banners_repo_impl.dart';
import 'package:supper_admin/featchers/requests/data/repos/requests_repo_impl.dart';
import 'package:supper_admin/featchers/requests/domain/repos/requests_repo.dart';
import 'package:supper_admin/featchers/requests/presentation/manger/cubit/request_pharmacy_cubit.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  // 1️⃣ Services
  getIt.registerSingleton<DatabaseService>(FireStoreService());
  
  // 🔥 السطر المضاف الذي كان يسبب المشكلة:
  getIt.registerSingleton<SupabaseStorgeService>(SupabaseStorgeService());

  // 2️⃣ Repos
  getIt.registerSingleton<PharmaciesRepo>(
    PharmaciesRepoImpl(getIt<DatabaseService>()),
  );

  // 3️⃣ Banners Registration
  getIt.registerLazySingleton<BannersRepo>(
    () => BannersRepoImpl(
      databaseService: getIt<DatabaseService>(),
      storgeService: getIt<SupabaseStorgeService>(), 
    ),
  );

  // 4️⃣ Cubits
  getIt.registerFactory(() => RequestsCubit(getIt<PharmaciesRepo>()));
  
  getIt.registerFactory<BannersCubit>(
    () => BannersCubit(getIt<BannersRepo>()),
  );
}