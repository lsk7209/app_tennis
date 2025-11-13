import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/async_value_widget.dart';
import '../../../widgets/main_navigation.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/request_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../features/auth/providers/auth_service_providers.dart';
import '../../../features/auth/services/kakao_auth_service.dart';
import '../../profile/providers/profile_providers.dart';
import '../widgets/request_list_item.dart';
import '../widgets/statistics_section.dart';
import '../widgets/match_history_section.dart';

/// 프로필 화면
/// 내정보: 프로필, 신청내역, 매칭이력, 통계, 설정
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final requestsAsync = ref.watch(userRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내정보'),
      ),
      bottomNavigationBar: MainNavigation(
        currentPath: GoRouterState.of(context).uri.path,
      ),
      body: AsyncValueWidget<UserModel?>(
        value: profileAsync,
        data: (user) {
          if (user == null) {
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 프로필 섹션
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue,
                        child: Text(
                          user.nickname.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.nickname,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'NTRP ${user.ntrp.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // 정보 섹션
                _InfoSection(user: user),
                const Divider(),
                // 통계 섹션
                const StatisticsSection(),
                const Divider(),
                // 신청 내역 섹션
                _RequestsSection(requestsAsync: requestsAsync),
                const Divider(),
                // 매칭 이력 섹션
                const MatchHistorySection(),
                const Divider(),
                // 설정 섹션
                _SettingsSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 정보 섹션
class _InfoSection extends StatelessWidget {
  final UserModel user;

  const _InfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '프로필 정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: '이름', value: user.name),
          _InfoRow(label: '이메일', value: user.email),
          _InfoRow(label: '전화번호', value: user.phone),
          const SizedBox(height: 8),
          _InfoRow(label: '집 지역', value: user.region.home),
          _InfoRow(label: '직장 지역', value: user.region.work),
        ],
      ),
    );
  }
}

/// 신청 내역 섹션
class _RequestsSection extends StatelessWidget {
  final AsyncValue<List<RequestModel>> requestsAsync;

  const _RequestsSection({required this.requestsAsync});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '신청 내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AsyncValueWidget<List<RequestModel>>(
            value: requestsAsync,
            data: (requests) {
              if (requests.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('신청 내역이 없습니다'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return RequestListItem(request: requests[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 설정 섹션
class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('알림 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/profile/notifications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () async {
              try {
                final kakaoAuth = ref.read(kakaoAuthServiceProvider);
                await kakaoAuth.signOut();
                if (context.mounted) {
                  context.go('/auth');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그아웃에 실패했습니다: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/// 정보 행 위젯
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

