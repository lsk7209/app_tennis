import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 사용자 모델
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String nickname,
    required RegionModel region,
    required double ntrp,
    required MannerModel manner,
    @Default([]) List<String> fcmTokens,
    required PreferencesModel preferences,
    required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// 지역 모델 (집/직장)
@freezed
class RegionModel with _$RegionModel {
  const factory RegionModel({
    required String home,
    required String work,
  }) = _RegionModel;

  factory RegionModel.fromJson(Map<String, dynamic> json) =>
      _$RegionModelFromJson(json);
}

/// 매너온도 모델
@freezed
class MannerModel with _$MannerModel {
  const factory MannerModel({
    @Default(36.5) double score,
    @Default(true) bool hidden,
  }) = _MannerModel;

  factory MannerModel.fromJson(Map<String, dynamic> json) =>
      _$MannerModelFromJson(json);
}

/// 사용자 설정 모델
@freezed
class PreferencesModel with _$PreferencesModel {
  const factory PreferencesModel({
    required NotificationPreferencesModel notifications,
  }) = _PreferencesModel;

  factory PreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$PreferencesModelFromJson(json);
}

/// 알림 설정 모델
@freezed
class NotificationPreferencesModel with _$NotificationPreferencesModel {
  const factory NotificationPreferencesModel({
    @Default(true) bool match,
    @Default(true) bool chat,
    @Default(true) bool system,
  }) = _NotificationPreferencesModel;

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesModelFromJson(json);
}

