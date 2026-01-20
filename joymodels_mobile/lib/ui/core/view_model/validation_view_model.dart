import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

class ValidationViewModel {
  static Future<String?> validateUserPicture(File? userPicture) async {
    const int allowedSizeInBytes = 10485760;
    const int minWidth = 256;
    const int minHeight = 256;
    const int maxWidth = 1024;
    const int maxHeight = 1024;
    const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

    if (userPicture == null) {
      return "User profile picture is required.";
    }

    final int fileSize = await userPicture.length();
    if (fileSize > allowedSizeInBytes) {
      return "Picture too large. Maximum size limit is 10MB";
    }

    final String filePath = userPicture.path.toLowerCase();
    final String ext = filePath.split('.').last;
    if (!allowedExtensions.contains(ext)) {
      return "Unsupported picture format. Allowed: .jpg, .jpeg, .png";
    }

    final Uint8List bytes = await userPicture.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      return "Unsupported or corrupted image.";
    }

    if (decodedImage.width < minWidth ||
        decodedImage.width > maxWidth ||
        decodedImage.height < minHeight ||
        decodedImage.height > maxHeight) {
      return "Image error: ${decodedImage.width}x${decodedImage.height}. Allowed: width between $minWidth-$maxWidth px and height between $minHeight-$maxHeight px.";
    }

    return null;
  }

  static Future<String?> validateUserPictureOptional(File? userPicture) async {
    if (userPicture == null) {
      return null;
    }

    const int allowedSizeInBytes = 10485760;
    const int minWidth = 256;
    const int minHeight = 256;
    const int maxWidth = 1024;
    const int maxHeight = 1024;
    const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

    final int fileSize = await userPicture.length();
    if (fileSize > allowedSizeInBytes) {
      return "Picture too large. Maximum size limit is 10MB";
    }

    final String filePath = userPicture.path.toLowerCase();
    final String ext = filePath.split('.').last;
    if (!allowedExtensions.contains(ext)) {
      return "Unsupported picture format. Allowed: .jpg, .jpeg, .png";
    }

    final Uint8List bytes = await userPicture.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      return "Unsupported or corrupted image.";
    }

    if (decodedImage.width < minWidth ||
        decodedImage.width > maxWidth ||
        decodedImage.height < minHeight ||
        decodedImage.height > maxHeight) {
      return "Image error: ${decodedImage.width}x${decodedImage.height}. Allowed: width between $minWidth-$maxWidth px and height between $minHeight-$maxHeight px.";
    }

    return null;
  }

  static String? validateModelFile(PlatformFile file) {
    const int maxModelSizeInBytes = 30 * 1024 * 1024;
    const List<String> allowedModelFormats = [
      '.glb',
      '.gltf',
      '.fbx',
      '.obj',
      '.stl',
      '. blend',
      '. max',
      '. ma',
      '. mb',
    ];

    if (file.size > maxModelSizeInBytes) {
      return 'Model too large. Maximum size limit is 30MB';
    }

    final fileName = file.name;
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1) {
      return 'Model has no format!';
    }

    final format = fileName.substring(dotIndex).toLowerCase();

    if (format.isEmpty) {
      return 'Model has no format!';
    }

    if (!allowedModelFormats.contains(format)) {
      return 'Unsupported model format. Allowed: . glb, .gltf, .fbx, . obj, .stl, .blend, . max, .ma, .mb';
    }

    return null;
  }

  static Future<String?> validateModelAndCommunityPostPicture(
    Uint8List fileBytes,
    String fileName,
  ) async {
    const int minWidth = 512;
    const int minHeight = 512;
    const int maxWidth = 10000;
    const int maxHeight = 10000;
    const int maxImageSizeInBytes = 10 * 1024 * 1024;
    const allowedImageExtensions = ['jpg', 'jpeg', 'png'];

    if (fileBytes.length > maxImageSizeInBytes) {
      return 'Image too large. Maximum size limit is ${maxImageSizeInBytes ~/ (1024 * 1024)}MB';
    }

    final fileExtension = fileName.split('.').last.toLowerCase();
    if (!allowedImageExtensions.contains(fileExtension)) {
      return 'Unsupported image format. Allowed: .jpg, .jpeg, .png';
    }

    final image = img.decodeImage(fileBytes);
    if (image == null) {
      return 'Unsupported or corrupted image.';
    }

    if (image.width < minWidth ||
        image.width > maxWidth ||
        image.height < minHeight ||
        image.height > maxHeight) {
      return 'Image error: ${image.width}x${image.height}. Allowed: width between $minWidth-$maxWidth px and height between $minHeight-$maxHeight px.';
    }

    return null;
  }
}
