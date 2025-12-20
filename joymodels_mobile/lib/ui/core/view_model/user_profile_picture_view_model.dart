import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class UserProfilePictureValidationViewModel {
  static const int _allowedSizeInBytes = 10485760;
  static const int _minWidth = 256;
  static const int _minHeight = 256;
  static const int _maxWidth = 1024;
  static const int _maxHeight = 1024;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png'];

  static Future<String?> validateUserPicture(File? userPicture) async {
    if (userPicture == null) {
      return "User profile picture is required.";
    }

    final int fileSize = await userPicture.length();
    if (fileSize > _allowedSizeInBytes) {
      return "Picture too large. Maximum size limit is 10MB";
    }

    final String filePath = userPicture.path.toLowerCase();
    final String ext = filePath.split('.').last;
    if (!_allowedExtensions.contains(ext)) {
      return "Unsupported picture format. Allowed: .jpg, .jpeg, .png";
    }

    final Uint8List bytes = await userPicture.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      return "Unsupported or corrupted image.";
    }

    if (decodedImage.width < _minWidth ||
        decodedImage.width > _maxWidth ||
        decodedImage.height < _minHeight ||
        decodedImage.height > _maxHeight) {
      return "Image error: ${decodedImage.width}x${decodedImage.height}. Allowed: width between $_minWidth-$_maxWidth px and height between $_minHeight-$_maxHeight px.";
    }

    return null;
  }
}
