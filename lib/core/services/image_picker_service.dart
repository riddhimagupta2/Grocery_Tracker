import 'package:image_picker/image_picker.dart';
import 'permission_service.dart';
import '../utils/app_logger.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();
  final PermissionService _permissionService = PermissionService();

  Future<XFile?> capturePhoto() async {
    final hasPermission = await _permissionService.requestCameraPermission();
    if (!hasPermission) {
      AppLogger.warning('Camera permission was denied by user.');
      return null;
    }
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to capture photo', e, stack);
      return null;
    }
  }

  Future<XFile?> selectImageFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to pick gallery image', e, stack);
      return null;
    }
  }

  Future<List<XFile>> selectMultipleImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
      return images;
    } catch (e, stack) {
      AppLogger.error('Failed to pick multi-images from gallery', e, stack);
      return [];
    }
  }
}
