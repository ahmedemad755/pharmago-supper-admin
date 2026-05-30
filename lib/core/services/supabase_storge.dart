// lib/core/services/supabase_storage_service.dart
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as b;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supper_admin/core/const/const.dart';
import 'package:supper_admin/core/services/storge_service.dart';

class SupabaseStorgeService implements StorgeService {
  static Future<void> initSupabase() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  Future<void> ensureBucketExists(String bucketName) async {
    final client = Supabase.instance.client;
    try {
      final buckets = await client.storage.listBuckets();
      final exists = buckets.any((bucket) => bucket.name == bucketName);

      if (!exists) {
        await client.storage.createBucket(bucketName);
        print('✅ Bucket $bucketName created successfully');
      } else {
        print('ℹ️ Bucket $bucketName already exists, skipping creation');
      }
    } catch (e) {
      print('❌ Error checking/creating bucket: $e');
    }
  }

  @override
  Future<String?> uploadImage(XFile file, String path) async {
    try {
      // 1. توليد اسم ملف فريد
      final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = b.basename(file.path);
      final filePath = '$path/${uniqueId}_$fileName';

      // 2. استخراج الامتداد بشكل صحيح لتحديد الـ Content-Type ديناميكياً
      final String extension = b.extension(file.path).replaceAll('.', '').toLowerCase();
      final String contentType = 'image/${extension.isEmpty ? 'jpeg' : extension}';

      // 3. التحويل إلى Bytes لضمان استقرار الرفع على جميع المنصات
      final bytes = await file.readAsBytes();

      // 4. عملية الرفع باستخدام uploadBinary
      await Supabase.instance.client.storage
          .from(supabaseBucketName)
          .uploadBinary(
            filePath, 
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: contentType, // 👈 تم استبدال 'image/jpeg' بالمتغير الديناميكي
            ),
          );

      // 5. الحصول على الرابط المباشر
      final String publicUrl = Supabase.instance.client.storage
          .from(supabaseBucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } on StorageException catch (e) {
      print('🔥 Supabase Storage Error: ${e.message}');
      return null;
    } catch (e) {
      print('🚀 Unexpected Error during upload: $e');
      return null;
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      final String relativePath = _extractRelativePath(path);
      
      await Supabase.instance.client.storage
          .from(supabaseBucketName)
          .remove([relativePath]);
          
      print('✅ File deleted successfully: $relativePath');
    } catch (e) {
      print('❌ Error deleting file from Supabase: $e');
    }
  }

  String _extractRelativePath(String fullUrl) {
    if (fullUrl.contains(supabaseBucketName)) {
      // نأخذ الجزء الأخير بعد اسم البوكيت للحصول على المسار داخل السحاب
      return fullUrl.split('$supabaseBucketName/').last;
    }
    return fullUrl;
  }
}