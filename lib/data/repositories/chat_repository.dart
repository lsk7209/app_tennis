import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/chat_model.dart';
import '../sources/firestore_source.dart';

/// 채팅 리포지토리
class ChatRepository {
  final FirestoreSource _source;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  ChatRepository(this._source, this._auth, this._uuid);

  /// 채팅 생성 (매칭 확정 시)
  Future<void> createChat({
    required String matchId,
    required List<String> members,
  }) async {
    final chat = ChatModel(
      matchId: matchId,
      members: members,
      state: ChatState.active,
      createdAt: DateTime.now(),
    );

    final json = chat.toJson();
    json.remove('matchId'); // 문서 ID로 사용

    await _source.createChat(matchId, json);
  }

  /// 채팅 메시지 목록 (스트림)
  Stream<List<ChatMessageModel>> getMessages(String matchId) {
    return _source.getChatMessages(matchId).map((docs) {
      return docs.map((doc) {
        final data = doc.data();
        return ChatMessageModel.fromJson({
          ...data,
          'msgId': doc.id,
        });
      }).toList();
    });
  }

  /// 메시지 전송
  Future<String> sendMessage({
    required String matchId,
    String? text,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('로그인이 필요합니다');
    }

    if (text == null && imageUrl == null) {
      throw ValidationException('메시지 내용이 없습니다');
    }

    final message = ChatMessageModel(
      msgId: _uuid.v4(),
      senderId: user.uid,
      text: text,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    final json = message.toJson();
    json.remove('msgId'); // 문서 ID로 사용

    return await _source.sendChatMessage(matchId, json);
  }

  /// 채팅 상태 업데이트
  Future<void> updateChatState(String matchId, ChatState state) async {
    await _source.updateMatch(matchId, {'state': state.name});
  }
}

/// ChatRepository 프로바이더
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    FirestoreSource(FirebaseFirestore.instance),
    FirebaseAuth.instance,
    const Uuid(),
  );
});

