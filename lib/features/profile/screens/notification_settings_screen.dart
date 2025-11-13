import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/utils/async_value_widget.dart';
import '../../profile/providers/profile_providers.dart';

/// 알림 설정 화면
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: AsyncValueWidget<UserModel?>(
        value: profileAsync,
        data: (user) {
          if (user == null) {
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('매칭 알림'),
                subtitle: const Text('신청, 승인, 거절 등 매칭 관련 알림'),
                value: user.preferences.notifications.match,
                onChanged: (value) {
                  _updateNotification(
                    ref,
                    user.preferences.notifications.copyWith(match: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('채팅 알림'),
                subtitle: const Text('채팅 메시지 수신 알림'),
                value: user.preferences.notifications.chat,
                onChanged: (value) {
                  _updateNotification(
                    ref,
                    user.preferences.notifications.copyWith(chat: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('시스템 알림'),
                subtitle: const Text('공지사항 및 시스템 알림'),
                value: user.preferences.notifications.system,
                onChanged: (value) {
                  _updateNotification(
                    ref,
                    user.preferences.notifications.copyWith(system: value),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateNotification(
    WidgetRef ref,
    NotificationPreferencesModel preferences,
  ) async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.updateNotificationPreferences(preferences);
    } catch (e) {
      // 에러 처리 (SnackBar는 호출한 화면에서 처리)
      print('알림 설정 업데이트 실패: $e');
    }
  }
}

