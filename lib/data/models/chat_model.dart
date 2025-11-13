import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

/// 채팅 모델
@freezed
class ChatModel with _$ChatModel {
  const factory ChatModel({
    required String matchId,
    @Default([]) List<String> members,
    @Default(ChatState.active) ChatState state,
    required DateTime createdAt,
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);
}

/// 채팅 메시지 모델
@freezed
class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String msgId,
    required String senderId,
    String? text,
    String? imageUrl,
    required DateTime createdAt,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}

/// 채팅 상태
enum ChatState {
  @JsonValue('active')
  active,
  @JsonValue('ended')
  ended,
  @JsonValue('readonly')
  readonly,
  @JsonValue('archived')
  archived,
}

