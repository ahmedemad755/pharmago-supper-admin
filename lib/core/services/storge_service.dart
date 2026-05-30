
import 'package:image_picker/image_picker.dart';

abstract class StorgeService {
  Future<String?> uploadImage(XFile file, String path);
  Future<void> deleteFile(String path);
}
