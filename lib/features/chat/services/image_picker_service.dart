import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/constants/app_constants.dart';

/// 이미지 선택 서비스
class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService(this._picker);

  /// 이미지 선택 (갤러리 또는 카메라)
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      final file = File(image.path);
      
      // 파일 크기 체크 (2MB)
      final fileSize = await file.length();
      final maxSize = AppConstants.maxImageSizeMB * 1024 * 1024;
      
      if (fileSize > maxSize) {
        throw ValidationException(
          '이미지 크기는 ${AppConstants.maxImageSizeMB}MB 이하여야 합니다',
        );
      }

      return file;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw NetworkException('이미지 선택에 실패했습니다: $e');
    }
  }

  /// 이미지 선택 다이얼로그
  Future<File?> pickImageWithDialog() async {
    // 다이얼로그는 UI에서 처리
    return null;
  }
}

