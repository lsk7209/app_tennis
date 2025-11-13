import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/repositories/chat_repository.dart';

/// 채팅 메시지 프로바이더
final chatMessagesProvider = StreamProvider.family<List<ChatMessageModel>, String>(
  (ref, matchId) {
    final chatRepo = ref.watch(chatRepositoryProvider);
    return chatRepo.getMessages(matchId);
  },
);

