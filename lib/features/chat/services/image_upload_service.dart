import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/app_exceptions.dart';

/// 이미지 업로드 서비스
class ImageUploadService {
  final FirebaseStorage _storage;
  final Uuid _uuid;

  ImageUploadService(this._storage, this._uuid);

  /// 이미지 업로드
  Future<String> uploadImage(File imageFile, String matchId) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('chats/$matchId/$fileName');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw NetworkException('이미지 업로드에 실패했습니다: $e');
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

