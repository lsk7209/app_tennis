import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_model.freezed.dart';
part 'match_model.g.dart';

/// 매칭 모델
@freezed
class MatchModel with _$MatchModel {
  const factory MatchModel({
    required String matchId,
    required String hostId,
    @Default([]) List<String> users,
    @Default([]) List<String> waitlist,
    required String region,
    String? geohashPrefix,
    required TimeModel time,
    required NtrpRangeModel ntrpRange,
    required FacilitiesModel facilities,
    @Default(MatchState.open) MatchState state,
    required DateTime createdAt,
  }) = _MatchModel;

  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);
}

/// 시간 모델
@freezed
class TimeModel with _$TimeModel {
  const factory TimeModel({
    required DateTime start,
    required DateTime end,
  }) = _TimeModel;

  factory TimeModel.fromJson(Map<String, dynamic> json) =>
      _$TimeModelFromJson(json);
}

/// NTRP 범위 모델
@freezed
class NtrpRangeModel with _$NtrpRangeModel {
  const factory NtrpRangeModel({
    required double min,
    required double max,
  }) = _NtrpRangeModel;

  factory NtrpRangeModel.fromJson(Map<String, dynamic> json) =>
      _$NtrpRangeModelFromJson(json);
}

/// 시설 모델
@freezed
class FacilitiesModel with _$FacilitiesModel {
  const factory FacilitiesModel({
    @Default(false) bool parking,
    @Default(false) bool balls,
    @Default(false) bool water,
    @Default(false) bool racket,
    @Default(false) bool etc,
  }) = _FacilitiesModel;

  factory FacilitiesModel.fromJson(Map<String, dynamic> json) =>
      _$FacilitiesModelFromJson(json);
}

/// 매칭 상태
enum MatchState {
  @JsonValue('open')
  open,
  @JsonValue('matched')
  matched,
  @JsonValue('completed')
  completed,
}

