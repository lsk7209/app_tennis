import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/chat_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../core/utils/async_value_widget.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
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

                // 메시지를 역순으로 표시 (최신이 위)
                final reversedMessages = messages.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: reversedMessages.length,
                  itemBuilder: (context, index) {
                    final message = reversedMessages[index];
                    return ChatMessageItem(message: message);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
