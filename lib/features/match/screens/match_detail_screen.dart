import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/match_model.dart';
import '../../../data/models/request_model.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/request_repository.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../core/utils/async_value_widget.dart';
import '../../../core/errors/app_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/host_request_manager.dart';
import '../widgets/match_complete_dialog.dart';
import '../widgets/participant_list.dart';

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
  }

  Future<void> _handleCancelRequest(String reqId) async {
    try {
      final requestRepo = ref.read(requestRepositoryProvider);
      await requestRepo.cancelRequest(reqId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신청이 취소되었습니다')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('취소에 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchRepo = ref.watch(matchRepositoryProvider);
    final matchFuture = matchRepo.getMatch(widget.matchId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 상세'),
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
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final isHost = match.hostId == currentUserId;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.region,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.access_time,
                  label: '시간',
                  value: '${app_date.AppDateUtils.formatDateTime(match.time.start)} ~ ${app_date.AppDateUtils.formatTime(match.time.end)}',
                ),
                const SizedBox(height: 16),
                // 참가자 목록
                ParticipantList(
                  match: match,
                  currentUserId: currentUserId,
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.sports_tennis,
                  label: 'NTRP 범위',
                  value: '${match.ntrpRange.min.toStringAsFixed(1)} ~ ${match.ntrpRange.max.toStringAsFixed(1)}',
                ),
                const SizedBox(height: 16),
                const Text(
                  '시설',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (match.facilities.parking)
                      Chip(label: const Text('주차 가능')),
                    if (match.facilities.balls)
                      Chip(label: const Text('공 제공')),
                    if (match.facilities.water)
                      Chip(label: const Text('물 제공')),
                    if (match.facilities.racket)
                      Chip(label: const Text('라켓 대여')),
                    if (match.facilities.etc)
                      Chip(label: const Text('기타')),
                  ],
                ),
                const SizedBox(height: 32),
                // 매칭 확정 시 채팅 버튼 표시
                if (match.state == MatchState.matched &&
                    (isHost || match.users.contains(currentUserId))) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/chat/${widget.matchId}');
                    },
                    icon: const Icon(Icons.chat_bubble),
                    label: const Text('채팅하기'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 호스트만 매칭 완료 처리 가능
                  if (isHost)
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => MatchCompleteDialog(match: match),
                        );
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('매칭 완료'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                if (isHost) ...[
                  HostRequestManager(matchId: widget.matchId),
                  const SizedBox(height: 16),
                ],
                if (!isHost && currentUserId != null) ...[
                  FutureBuilder<RequestModel?>(
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
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _getStatusColor(request!.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '신청 상태: ${_getStatusText(request.status)}',
                                    style: TextStyle(
                                      color: _getStatusColor(request.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (request.status == RequestStatus.requested ||
                                      request.status == RequestStatus.waitlisted)
                                    TextButton(
                                      onPressed: () => _handleCancelRequest(request.reqId),
                                      child: const Text('취소'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return ElevatedButton(
                        onPressed: _isLoading ? null : _handleRequest,
                        child: Text(_isLoading ? '신청 중...' : '신청하기'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.requested:
        return Colors.orange;
      case RequestStatus.waitlisted:
        return Colors.blue;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.requested:
        return '신청됨';
      case RequestStatus.waitlisted:
        return '대기중';
      case RequestStatus.approved:
        return '승인됨';
      case RequestStatus.rejected:
        return '거부됨';
      case RequestStatus.cancelled:
        return '취소됨';
    }
  }
}

/// 상세 정보 행 위젯
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

