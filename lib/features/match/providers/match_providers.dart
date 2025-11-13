import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/match_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/utils/match_filter_utils.dart';

/// 매칭 목록 프로바이더
final matchesProvider = StreamProvider.family<List<MatchModel>, MatchFilter>(
  (ref, filter) {
    final matchRepo = ref.watch(matchRepositoryProvider);
    return matchRepo.getMatches(
      region: filter.region,
      startAfter: filter.startAfter,
      limit: filter.limit,
    );
  },
);

/// 매칭 필터 모델
class MatchFilter {
  final String? region;
  final DateTime? startAfter;
  final int? limit;

  const MatchFilter({
    this.region,
    this.startAfter,
    this.limit = 20,
  });
}

/// 추천 매칭 프로바이더 (홈 화면용)
/// Fallback 알고리즘 적용
final recommendedMatchesProvider = StreamProvider<List<MatchModel>>((ref) async* {
  final matchRepo = ref.watch(matchRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  
  // 사용자 정보 가져오기
  final user = await userRepo.getCurrentUser();
  if (user == null) {
    yield [];
    return;
  }

  // 오늘부터 시작하는 매칭만
  final today = DateTime.now();
  final allMatches = await matchRepo.getMatches(
    startAfter: today,
    limit: 50,
  ).first;

  // Fallback 알고리즘 적용
  final userRegion = user.region.home; // 집 지역 기준
  final filtered = MatchFilterUtils.filterWithFallback(
    matches: allMatches,
    user: user,
    userRegion: userRegion,
    userPreferredTime: today,
  );

  yield filtered.take(10).toList();
});

