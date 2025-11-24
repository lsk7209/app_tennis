import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/constants/app_constants.dart';

/// 이미지 업로드 서비스
class ImageUploadService {
  final FirebaseStorage _storage;
  final Uuid _uuid;

  ImageUploadService(this._storage, this._uuid);

  /// 허용된 이미지 확장자
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

  /// 이미지 파일 타입 검증
  void _validateImageFile(File imageFile) {
    final fileName = imageFile.path.toLowerCase();
    final extension = fileName.split('.').last;
    
    if (!_allowedExtensions.contains(extension)) {
      throw ValidationException(
        '지원하지 않는 이미지 형식입니다. (지원 형식: ${_allowedExtensions.join(', ')})',
      );
    }
  }

  /// 이미지 크기 검증 (MB 단위)
  void _validateImageSize(File imageFile) {
    final fileSizeInBytes = imageFile.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    
    if (fileSizeInMB > AppConstants.maxImageSizeMB) {
      throw ValidationException(
        '이미지 크기가 ${AppConstants.maxImageSizeMB}MB를 초과합니다. '
        '현재 크기: ${fileSizeInMB.toStringAsFixed(2)}MB',
      );
    }
  }

  /// 이미지 업로드
  Future<String> uploadImage(File imageFile, String matchId) async {
    try {
      // 파일 타입 검증
      _validateImageFile(imageFile);
      
      // 파일 크기 검증 (업로드 전)
      _validateImageSize(imageFile);
      
      // 확장자 추출
      final extension = imageFile.path.split('.').last.toLowerCase();
      final fileName = '${_uuid.v4()}.$extension';
      final ref = _storage.ref().child('chats/$matchId/$fileName');

      // Content-Type 결정
      final contentType = _getContentType(extension);

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: contentType,
          cacheControl: 'public, max-age=31536000',
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw NetworkException('이미지 업로드에 실패했습니다: $e');
    }
  }

  /// 확장자에 따른 Content-Type 반환
  String _getContentType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// 이미지 삭제
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // 삭제 실패는 무시 (이미 삭제되었을 수 있음)
      print('이미지 삭제 실패: $e');
    }
  }
}

