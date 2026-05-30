// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supper_admin/core/const/const.dart';
import 'package:supper_admin/core/di/injection.dart';
import 'package:supper_admin/core/routs/rout.dart';
import 'package:supper_admin/core/services/custom_bloc_observer.dart';
import 'package:supper_admin/core/services/supabase_storge.dart';
import 'package:supper_admin/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تأكد من تهيئة فايربيز وسيرفس جيت إت
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  // 3️⃣ تهيئة Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // تأكد من وجود البوكيت (Bucket) لرفع صور الأدوية
  final storageService = SupabaseStorgeService();
  await storageService.ensureBucketExists(supabaseBucketName);
  setupGetIt();

   // 5️⃣ مراقب الـ Bloc
  Bloc.observer = CustomBlocObserver();
  
  runApp(const SuperAdminApp());
}

class SuperAdminApp extends StatelessWidget {
  const SuperAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Admin Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      // نحدد الدالة المسؤولة عن الروتس
      onGenerateRoute: onGenerateRoute,
      // نحدد الصفحة الأولى التي ستبدأ عند تشغيل التطبيق
      initialRoute: AppRoutes.adminHome,
    );
  }
}