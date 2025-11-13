import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_model.freezed.dart';
part 'request_model.g.dart';

/// 신청 모델
@freezed
class RequestModel with _$RequestModel {
  const factory RequestModel({
    required String reqId,
    required String matchId,
    required String applicantId,
    @Default(RequestStatus.requested) RequestStatus status,
    String? rejectCode,
    required DateTime createdAt,
  }) = _RequestModel;

  factory RequestModel.fromJson(Map<String, dynamic> json) =>
      _$RequestModelFromJson(json);
}

/// 신청 상태
enum RequestStatus {
  @JsonValue('requested')
  requested,
  @JsonValue('waitlisted')
  waitlisted,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
}

