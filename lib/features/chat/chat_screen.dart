import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/chat_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../core/utils/async_value_widget.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../../core/errors/app_exceptions.dart';
import 'providers/chat_providers.dart';
import 'widgets/chat_message_item.dart';
import 'services/image_picker_service.dart';
import 'services/image_upload_service.dart';

/// 채팅 화면
/// 매칭 확정 그룹채팅
class ChatScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ChatScreen({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePickerService(ImagePicker());
  final _imageUpload = ImageUploadService(
    FirebaseStorage.instance,
    const Uuid(),
  );
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      await chatRepo.sendMessage(
        matchId: widget.matchId,
        text: text,
      );

      _messageController.clear();
      _scrollToBottom();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지 전송에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final imageFile = await _imagePicker.pickImage();
      if (imageFile == null) return;

      setState(() {
        _isUploading = true;
      });

      // 이미지 업로드
      final imageUrl = await _imageUpload.uploadImage(
        imageFile,
        widget.matchId,
      );

      // 메시지 전송
      final chatRepo = ref.read(chatRepositoryProvider);
      await chatRepo.sendMessage(
        matchId: widget.matchId,
        imageUrl: imageUrl,
      );

      _scrollToBottom();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 전송에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.matchId));
    final matchRepo = ref.watch(matchRepositoryProvider);
    final matchFuture = matchRepo.getMatch(widget.matchId);
    
    const backgroundColor = Color(0xFFF6F8F6);
    const primaryGreen = Color(0xFF30E837);
    const primaryAccent = Color(0xFF4CAF50);
    const textMain = Color(0xFF1F2937);
    const textSecondary = Color(0xFF6B7280);
    const surfaceSubtle = Color(0xFFE7F3E8);

    return FutureBuilder(
      future: matchFuture,
      builder: (context, matchSnapshot) {
        final match = matchSnapshot.data;
        final matchTitle = match?.region ?? '매칭 채팅';
        final matchTime = match != null
            ? _formatMatchTime(match.time.start)
            : '';

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(
              backgroundColor.red,
              backgroundColor.green,
              backgroundColor.blue,
              0.8,
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: textMain),
              onPressed: () => context.pop(),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  matchTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                    letterSpacing: -0.015,
                  ),
                ),
                if (matchTime.isNotEmpty)
                  Text(
                    matchTime,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
              ],
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () {
                  context.push('/match/${widget.matchId}');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromRGBO(
                    primaryGreen.red,
                    primaryGreen.green,
                    primaryGreen.blue,
                    0.2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: AsyncValueWidget<List<ChatMessageModel>>(
                  value: messagesAsync,
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '아직 메시지가 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '첫 메시지를 보내보세요!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // 날짜별로 그룹화
                    final groupedMessages = _groupMessagesByDate(messages);

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: groupedMessages.length,
                      itemBuilder: (context, index) {
                        final group = groupedMessages[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 날짜 표시
                            if (group['date'] != null)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    group['date'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            // 메시지들
                            ...(group['messages'] as List<ChatMessageModel>)
                                .map((message) => ChatMessageItem(
                                      message: message,
                                    ))
                                .toList(),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              // 메시지 입력 영역
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: const Border(
                    top: BorderSide(
                      color: Color.fromRGBO(238, 238, 238, 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // 추가 버튼
                      IconButton(
                        onPressed: _pickAndSendImage,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 28,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 입력 필드
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: surfaceSubtle,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Enter your message...',
                              hintStyle: const TextStyle(color: textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: textMain,
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 전송 버튼
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _sendMessage,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.sports_tennis,
                                  size: 20,
                                  color: Colors.white,
                                ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatMatchTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final matchDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (matchDate == today) {
      dateStr = '오늘';
    } else if (matchDate == today.add(const Duration(days: 1))) {
      dateStr = '내일';
    } else {
      dateStr = app_date.AppDateUtils.formatDate(dateTime);
    }
    
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    String timeStr;
    if (hour < 12) {
      timeStr = '오전 $hour:${minute.toString().padLeft(2, '0')}';
    } else if (hour == 12) {
      timeStr = '오후 $hour:${minute.toString().padLeft(2, '0')}';
    } else {
      timeStr = '오후 ${hour - 12}:${minute.toString().padLeft(2, '0')}';
    }
    
    return '$dateStr $timeStr';
  }

  List<Map<String, dynamic>> _groupMessagesByDate(
      List<ChatMessageModel> messages) {
    final grouped = <Map<String, dynamic>>[];
    String? currentDate;

    for (final message in messages.reversed) {
      final messageDate = _formatMessageDate(message.createdAt);
      if (messageDate != currentDate) {
        if (grouped.isNotEmpty) {
          grouped.last['date'] = currentDate;
        }
        grouped.add({
          'date': null,
          'messages': <ChatMessageModel>[],
        });
        currentDate = messageDate;
      }
      grouped.last['messages'].add(message);
    }

    if (grouped.isNotEmpty) {
      grouped.last['date'] = currentDate;
    }

    return grouped;
  }

  String _formatMessageDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '오늘';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '어제';
    } else {
      return app_date.AppDateUtils.formatDate(dateTime);
    }
  }
}
