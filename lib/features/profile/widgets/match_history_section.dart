import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../core/utils/async_value_widget.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../features/auth/providers/auth_providers.dart';

/// 매칭 이력 섹션
class MatchHistorySection extends ConsumerWidget {
  const MatchHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchRepo = ref.watch(matchRepositoryProvider);
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.uid;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    // 사용자가 참가한 매칭 조회 (간단한 구현)
    // 실제로는 사용자별 매칭 이력을 조회하는 쿼리가 필요
    return FutureBuilder<List<MatchModel>>(
      future: _loadUserMatches(matchRepo, currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('매칭 이력이 없습니다'),
          );
        }

        final matches = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '매칭 이력',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(match.region),
                    subtitle: Text(
                      app_date.AppDateUtils.formatDateTime(match.time.start),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStateColor(match.state).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStateText(match.state),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStateColor(match.state),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<MatchModel>> _loadUserMatches(
    MatchRepository matchRepo,
    String userId,
  ) async {
    // 간단한 구현: 모든 매칭을 가져와서 필터링
    // 실제로는 Firestore 쿼리로 최적화 필요
    final allMatches = await matchRepo.getMatches(limit: 100).first;
    return allMatches
        .where((match) =>
            match.hostId == userId || match.users.contains(userId))
        .take(10)
        .toList();
  }

  Color _getStateColor(MatchState state) {
    switch (state) {
      case MatchState.open:
        return Colors.green;
      case MatchState.matched:
        return Colors.blue;
      case MatchState.completed:
        return Colors.grey;
    }
  }

  String _getStateText(MatchState state) {
    switch (state) {
      case MatchState.open:
        return '모집중';
      case MatchState.matched:
        return '확정';
      case MatchState.completed:
        return '완료';
    }
  }
}


