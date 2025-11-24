import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/match_model.dart';
import '../../../data/models/request_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/request_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/theme.dart';
import '../widgets/match_request_dialog.dart';

/// 매칭 상세 화면
class MatchDetailScreen extends ConsumerStatefulWidget {
  final String matchId;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  bool _isLoading = false;

  Future<void> _handleRequest() async {
    // 매칭 신청 다이얼로그 표시
    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MatchRequestDialog(
        onSubmit: (intro) async {
          setState(() {
            _isLoading = true;
          });

          try {
            final requestRepo = ref.read(requestRepositoryProvider);
            await requestRepo.createRequest(widget.matchId);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신청이 완료되었습니다')),
              );
              setState(() {});
            }
          } on AppException catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message)),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('신청에 실패했습니다: $e')),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final matchRepo = ref.watch(matchRepositoryProvider);
    final matchFuture = matchRepo.getMatch(widget.matchId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '매치 정보',
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<MatchModel?>(
        future: matchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('매칭을 찾을 수 없습니다'));
          }

          final match = snapshot.data!;
          final totalParticipants = match.users.length;
          final maxCapacity = AppConstants.maxMatchCapacity;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 매칭 정보 카드
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.borderRadius16),
                    border: Border.all(color: colorScheme.primary, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 매칭 제목 및 시간
                      Text(
                        match.region,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDateTimeRange(match.time.start, match.time.end),
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Divider(height: 32),
                      
                      // 호스트 섹션
                      Text(
                        '호스트',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                          letterSpacing: -0.015,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<UserModel?>(
                        future: ref.read(userRepositoryProvider).getUser(match.hostId),
                        builder: (context, hostSnapshot) {
                          final host = hostSnapshot.data;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade300,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        host?.nickname ?? '호스트',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onBackground,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        host != null
                                            ? 'NTRP ${host.ntrp.toStringAsFixed(1)}'
                                            : 'NTRP -',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (host != null && host.manner.score >= 36.5)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    '매너 호스트',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const Divider(height: 32),
                      
                      // 참가자 목록
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '참가자',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                              letterSpacing: -0.015,
                            ),
                          ),
                          Text(
                            '$totalParticipants/$maxCapacity명',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 참가자 목록 (호스트 제외)
                      FutureBuilder<List<UserModel>>(
                        future: _loadParticipants(match.users, match.hostId, ref),
                        builder: (context, participantsSnapshot) {
                          if (participantsSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 48,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          }
                          
                          final participants = participantsSnapshot.data ?? [];
                          if (participants.isEmpty) {
                            return Text(
                              '아직 참가자가 없습니다',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          }
                          
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: participants.map((user) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade300,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user.nickname,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onBackground,
                                          ),
                                        ),
                                        Text(
                                          'NTRP ${user.ntrp.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const Divider(height: 32),
                      
                      // 편의시설
                      Text(
                        '편의시설',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                          letterSpacing: -0.015,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                        children: [
                          _AmenityItem(
                            icon: Icons.local_parking,
                            label: '주차가능',
                            isAvailable: match.facilities.parking,
                          ),
                          _AmenityItem(
                            icon: Icons.shower,
                            label: '샤워실',
                            isAvailable: match.facilities.water,
                          ),
                          _AmenityItem(
                            icon: Icons.lock,
                            label: '라커룸',
                            isAvailable: match.facilities.racket,
                          ),
                          _AmenityItem(
                            icon: Icons.local_cafe,
                            label: '음료',
                            isAvailable: match.facilities.etc,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 하단 여백 (버튼 공간)
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      // 하단 고정 버튼
      bottomNavigationBar: FutureBuilder<MatchModel?>(
        future: matchFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          
          final match = snapshot.data!;
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final isHost = match.hostId == currentUserId;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              boxShadow: DesignTokens.shadow12,
            ),
            child: SafeArea(
              child: _buildBottomButton(
                match: match,
                currentUserId: currentUserId,
                isHost: isHost,
                context: context,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton({
    required MatchModel match,
    required String? currentUserId,
    required bool isHost,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (isHost) {
      return const SizedBox.shrink(); // 호스트는 버튼 없음
    }

    if (currentUserId == null) {
      return ElevatedButton(
        onPressed: () {
          // 로그인 필요
        },
        style: theme.elevatedButtonTheme.style,
        child: const Text(
          '이 매칭 신청하기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return FutureBuilder<RequestModel?>(
      future: ref.read(requestRepositoryProvider).getRequestByMatchAndUser(
        widget.matchId,
        currentUserId,
      ),
      builder: (context, snapshot) {
        final request = snapshot.data;
        final hasRequest = request != null &&
            request.status != RequestStatus.cancelled &&
            request.status != RequestStatus.rejected;

        if (hasRequest) {
          final status = request.status;
          if (status == RequestStatus.approved) {
            return ElevatedButton(
              onPressed: () {
                context.push('/chat/${widget.matchId}');
              },
              style: theme.elevatedButtonTheme.style,
              child: const Text(
                '채팅하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.onSurfaceVariant,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.borderRadius12),
              ),
              elevation: 0,
            ),
            child: Text(
              status == RequestStatus.requested
                  ? '승인 대기'
                  : status == RequestStatus.waitlisted
                      ? '대기중'
                      : '신청됨',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final isFull = match.users.length >= AppConstants.maxMatchCapacity;
        if (isFull) {
          return ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.onSurfaceVariant,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.borderRadius12),
              ),
              elevation: 0,
            ),
            child: const Text(
              '정원 마감',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return ElevatedButton(
          onPressed: _isLoading ? null : _handleRequest,
          style: theme.elevatedButtonTheme.style,
          child: Text(
            _isLoading ? '신청 중...' : '이 매칭 신청하기',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  /// 참가자 목록 로드 (호스트 제외) - 병렬 처리
  Future<List<UserModel>> _loadParticipants(
    List<String> userIds,
    String hostId,
    WidgetRef ref,
  ) async {
    final userRepo = ref.read(userRepositoryProvider);
    
    // 호스트를 제외한 사용자 ID 목록
    final participantIds = userIds.where((id) => id != hostId).toList();
    
    // 병렬로 모든 사용자 정보 로드
    final userFutures = participantIds.map((userId) => userRepo.getUser(userId));
    final users = await Future.wait(userFutures);
    
    // null이 아닌 사용자만 반환
    return users.whereType<UserModel>().toList();
  }

  String _formatDateTimeRange(DateTime start, DateTime end) {
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][start.weekday - 1];
    final startHour = start.hour;
    final startMinute = start.minute;
    final endHour = end.hour;
    final endMinute = end.minute;
    
    String startTimeStr;
    if (startHour < 12) {
      startTimeStr = '오전 $startHour:${startMinute.toString().padLeft(2, '0')}';
    } else if (startHour == 12) {
      startTimeStr = '오후 $startHour:${startMinute.toString().padLeft(2, '0')}';
    } else {
      startTimeStr = '오후 ${startHour - 12}:${startMinute.toString().padLeft(2, '0')}';
    }
    
    String endTimeStr;
    if (endHour < 12) {
      endTimeStr = '오전 $endHour:${endMinute.toString().padLeft(2, '0')}';
    } else if (endHour == 12) {
      endTimeStr = '오후 $endHour:${endMinute.toString().padLeft(2, '0')}';
    } else {
      endTimeStr = '오후 ${endHour - 12}:${endMinute.toString().padLeft(2, '0')}';
    }
    
    return '${start.year}년 ${start.month}월 ${start.day}일 ($weekday) $startTimeStr - $endTimeStr';
  }

}

/// 편의시설 아이템
class _AmenityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAvailable;

  const _AmenityItem({
    required this.icon,
    required this.label,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

