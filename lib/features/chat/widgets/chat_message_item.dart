import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/chat_model.dart';

/// 채팅 메시지 아이템 위젯
class ChatMessageItem extends StatelessWidget {
  final ChatMessageModel message;
  final String? senderName;

  const ChatMessageItem({
    super.key,
    required this.message,
    this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isMe = message.senderId == currentUserId;
    
    const textMain = Color(0xFF1F2937);
    const textSecondary = Color(0xFF6B7280);
    const surfaceLight = Colors.white;
    const surfaceSubtle = Color(0xFFE7F3E8);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
              child: const Icon(
                Icons.person,
                size: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      senderName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? surfaceLight : surfaceSubtle,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                    boxShadow: isMe
                        ? [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: message.imageUrl != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                message.imageUrl!,
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image),
                                  );
                                },
                              ),
                            ),
                            if (message.text != null && message.text!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  message.text!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: textMain,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Text(
                          message.text ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: textMain,
                            height: 1.4,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    
    if (hour < 12) {
      return '오전 $hour:${minute.toString().padLeft(2, '0')}';
    } else if (hour == 12) {
      return '오후 $hour:${minute.toString().padLeft(2, '0')}';
    } else {
      return '오후 ${hour - 12}:${minute.toString().padLeft(2, '0')}';
    }
  }
}

