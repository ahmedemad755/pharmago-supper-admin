import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // تأكد من استيرادها
import 'package:path/path.dart' as b;
import 'package:supper_admin/core/services/storge_service.dart';

class FireStorge implements StorgeService {
  final storageReference = FirebaseStorage.instance.ref();

  @override
  Future<String?> uploadImage(XFile file, String path) async {
    try {
      // 1. توليد اسم فريد للملف
      String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = b.basename(file.path);
      String filePath = '$path/${uniqueId}_$fileName';
      String extension = b.extension(file.path).replaceAll('.', '');

      var imageReference = storageReference.child(filePath);

      // 2. التحويل إلى Bytes لضمان التوافق (خاصة للويب)
      final bytes = await file.readAsBytes();

      // 3. رفع البيانات بصيغة Data (أكثر استقراراً مع XFile)
      // نستخدم putData بدلاً من putFile لأنها تقبل Uint8List (Bytes)
      SettableMetadata metadata = SettableMetadata(contentType: 'image/${extension.isEmpty ? 'jpeg' : extension}',);
      
      UploadTask uploadTask = imageReference.putData(bytes, metadata);

      // 4. الحصول على الرابط بعد اكتمال الرفع
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('🔥 Firebase Storage Error: $e');
      return null;
    }
  }

  @override
  Future<void> deleteFile(String url) async {
    try {
      // Firebase Storage يحتاج لمرجع الملف (Ref) ليتمكن من حذفه
      // إذا كان المدخل URL، نستخدم الـ Reference المباشر منه
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
      print('✅ File deleted successfully from Firebase');
    } catch (e) {
      print('❌ Error deleting file from Firebase Storage: $e');
    }
  }
}