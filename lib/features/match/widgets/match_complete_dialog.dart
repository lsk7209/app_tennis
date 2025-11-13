import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 매칭 완료 다이얼로그
/// 리뷰 작성 (내부 저장)
class MatchCompleteDialog extends ConsumerStatefulWidget {
  final MatchModel match;

  const MatchCompleteDialog({
    super.key,
    required this.match,
  });

  @override
  ConsumerState<MatchCompleteDialog> createState() =>
      _MatchCompleteDialogState();
}

class _MatchCompleteDialogState
    extends ConsumerState<MatchCompleteDialog> {
  final Map<String, int> _ratings = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 모든 참가자에 대해 기본 평점 3 설정
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    for (final userId in widget.match.users) {
      if (userId != currentUserId) {
        _ratings[userId] = 3;
      }
    }
    if (widget.match.hostId != currentUserId) {
      _ratings[widget.match.hostId] = 3;
    }
  }

  Future<void> _handleComplete() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewRepo = ref.read(reviewRepositoryProvider);
      final matchRepo = ref.read(matchRepositoryProvider);

      // 모든 리뷰 저장
      for (final entry in _ratings.entries) {
        await reviewRepo.saveReview(
          matchId: widget.match.matchId,
          targetUserId: entry.key,
          rating: entry.value,
        );
      }

      // 매칭 상태를 완료로 변경
      await matchRepo.updateMatchState(
        widget.match.matchId,
        MatchState.completed,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('매칭이 완료되었습니다')),
        );
        context.pop(); // 매칭 상세 화면 닫기
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
          SnackBar(content: Text('완료 처리에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('매칭 완료'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('참가자들에게 평점을 주세요 (1-5점)'),
            const SizedBox(height: 16),
            ..._ratings.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('사용자: ${entry.key.substring(0, 8)}...'),
                    Row(
                      children: List.generate(5, (index) {
                        final rating = index + 1;
                        return IconButton(
                          icon: Icon(
                            rating <= entry.value
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              _ratings[entry.key] = rating;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleComplete,
          child: Text(_isSubmitting ? '처리 중...' : '완료'),
        ),
      ],
    );
  }
}

