import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../features/auth/providers/auth_providers.dart';

/// 통계 섹션
/// 매칭 수, 완료율, 리뷰율
class StatisticsSection extends ConsumerWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.valueOrNull?.uid;

    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Statistics>(
      future: _calculateStatistics(ref, currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '통계',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: '매칭 수',
                      value: stats.totalMatches.toString(),
                      icon: Icons.sports_tennis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      title: '완료율',
                      value: '${stats.completionRate.toStringAsFixed(0)}%',
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      title: '리뷰율',
                      value: '${stats.reviewRate.toStringAsFixed(0)}%',
                      icon: Icons.rate_review,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Statistics> _calculateStatistics(
    WidgetRef ref,
    String userId,
  ) async {
    final matchRepo = ref.read(matchRepositoryProvider);

    // 사용자가 참가한 매칭 조회
    final allMatches = await matchRepo.getMatches(limit: 100).first;
    final userMatches = allMatches
        .where((match) =>
            match.hostId == userId || match.users.contains(userId))
        .toList();

    final totalMatches = userMatches.length;
    final completedMatches = userMatches
        .where((match) => match.state == MatchState.completed)
        .length;
    final completionRate =
        totalMatches > 0 ? (completedMatches / totalMatches) * 100 : 0.0;

    // 리뷰율 계산 (내부 저장된 리뷰 기준)
    // MVP에서는 리뷰 데이터가 없으므로 0으로 설정
    final reviewRate = 0.0;

    return Statistics(
      totalMatches: totalMatches,
      completionRate: completionRate,
      reviewRate: reviewRate,
    );
  }
}

/// 통계 데이터 모델
class Statistics {
  final int totalMatches;
  final double completionRate;
  final double reviewRate;

  Statistics({
    required this.totalMatches,
    required this.completionRate,
    required this.reviewRate,
  });
}

/// 통계 카드 위젯
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

