import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import '../sources/firestore_source.dart';

/// 사용자 리포지토리
class UserRepository {
  final FirestoreSource _source;
  final FirebaseAuth _auth;

  UserRepository(this._source, this._auth);

  /// 현재 사용자 정보 가져오기
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final data = await _source.getUser(user.uid);
    if (data == null) return null;

    return UserModel.fromJson({
      ...data,
      'uid': user.uid,
    });
  }

  /// 사용자 정보 조회 (UID로)
  Future<UserModel?> getUser(String uid) async {
    final data = await _source.getUser(uid);
    if (data == null) return null;

    return UserModel.fromJson({
      ...data,
      'uid': uid,
    });
  }

  /// 사용자 정보 저장
  Future<void> saveUser(UserModel user) async {
    final json = user.toJson();
    // uid는 문서 ID로 사용하므로 제거
    json.remove('uid');
    await _source.setUser(user.uid, json);
  }

  /// 온보딩 정보 저장
  Future<void> saveOnboarding({
    required String nickname,
    required RegionModel region,
    required double ntrp,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('로그인이 필요합니다');
    }

    final userModel = UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      nickname: nickname,
      region: region,
      ntrp: ntrp,
      manner: const MannerModel(),
      preferences: PreferencesModel(
        notifications: const NotificationPreferencesModel(),
      ),
      createdAt: DateTime.now(),
    );

    await saveUser(userModel);
  }

  /// FCM 토큰 추가
  Future<void> addFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final currentData = await _source.getUser(user.uid);
    if (currentData == null) return;

    final tokens = List<String>.from(currentData['fcmTokens'] ?? []);
    if (!tokens.contains(token)) {
      tokens.add(token);
      await _source.setUser(user.uid, {'fcmTokens': tokens});
    }
  }

  /// 알림 설정 업데이트
  Future<void> updateNotificationPreferences(
    NotificationPreferencesModel preferences,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('로그인이 필요합니다');
    }

    await _source.setUser(
      user.uid,
      {
        'preferences': {
          'notifications': preferences.toJson(),
        },
      },
    );
  }
}

/// UserRepository 프로바이더
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    FirestoreSource(FirebaseFirestore.instance),
    FirebaseAuth.instance,
  );
});

