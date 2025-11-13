import '../../data/models/match_model.dart';
import '../../data/models/user_model.dart';
import '../constants/app_constants.dart';
import 'date_utils.dart' as app_date;

/// 매칭 필터링 유틸리티
/// Fallback 매칭 알고리즘 (3단계)
class MatchFilterUtils {
  MatchFilterUtils._();

  /// 매칭 점수 계산
  /// score = 0.5*distance + 0.3*timeOverlap + 0.2*ntrpDiff
  static double calculateScore({
    required MatchModel match,
    required UserModel user,
    required String userRegion,
    double distance = 0,
    int timeOverlap = 0,
    double ntrpDiff = 0,
  }) {
    final distanceScore = distance * 0.5;
    final timeScore = (timeOverlap / 60.0) * 0.3; // 분을 시간으로 변환
    final ntrpScore = ntrpDiff * 0.2;

    return distanceScore + timeScore + ntrpScore;
  }

  /// 거리 계산 (간단한 문자열 매칭, 추후 좌표 기반으로 확장)
  static double calculateDistance(String region1, String region2) {
    // 현재는 간단한 문자열 비교
    // 추후 geohash나 실제 좌표 기반으로 확장
    if (region1 == region2) return 0;
    
    // 같은 구/시면 5km
    final parts1 = region1.split(' ');
    final parts2 = region2.split(' ');
    if (parts1.length > 1 && parts2.length > 1) {
      if (parts1[1] == parts2[1]) return 5.0;
    }
    
    // 같은 시면 10km
    if (parts1.isNotEmpty && parts2.isNotEmpty) {
      if (parts1[0] == parts2[0]) return 10.0;
    }
    
    return 20.0; // 기본값
  }

  /// 시간 겹침 계산 (분 단위)
  static int calculateTimeOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return app_date.AppDateUtils.getTimeOverlapMinutes(start1, end1, start2, end2);
  }

  /// NTRP 차이 계산
  static double calculateNtrpDiff(
    double userNtrp,
    double minNtrp,
    double maxNtrp,
  ) {
    if (userNtrp >= minNtrp && userNtrp <= maxNtrp) {
      return 0; // 범위 내
    }
    
    if (userNtrp < minNtrp) {
      return minNtrp - userNtrp;
    }
    
    return userNtrp - maxNtrp;
  }

  /// 1단계 필터: 거리 +5km / 시간겹침 15분
  static bool passesStep1({
    required MatchModel match,
    required UserModel user,
    required String userRegion,
    required DateTime userPreferredTime,
  }) {
    final distance = calculateDistance(userRegion, match.region);
    if (distance > AppConstants.distanceStep1) return false;

    final timeOverlap = calculateTimeOverlap(
      match.time.start,
      match.time.end,
      userPreferredTime,
      userPreferredTime.add(const Duration(hours: 2)),
    );
    if (timeOverlap < AppConstants.timeOverlapMinutes) return false;

    return true;
  }

  /// 2단계 필터: 거리 +10km / NTRP ±0.8
  static bool passesStep2({
    required MatchModel match,
    required UserModel user,
    required String userRegion,
  }) {
    final distance = calculateDistance(userRegion, match.region);
    if (distance > AppConstants.distanceStep2) return false;

    final ntrpDiff = calculateNtrpDiff(
      user.ntrp,
      match.ntrpRange.min,
      match.ntrpRange.max,
    );
    if (ntrpDiff > AppConstants.ntrpTolerance) return false;

    return true;
  }

  /// 3단계 필터: 거리 +15km / 동일요일
  static bool passesStep3({
    required MatchModel match,
    required UserModel user,
    required String userRegion,
    required DateTime userPreferredDate,
  }) {
    final distance = calculateDistance(userRegion, match.region);
    if (distance > AppConstants.distanceStep3) return false;

    // 동일 요일 체크
    if (match.time.start.weekday != userPreferredDate.weekday) {
      return false;
    }

    return true;
  }

  /// Fallback 매칭 필터링
  /// 3단계로 점진적으로 완화하여 매칭 추천
  static List<MatchModel> filterWithFallback({
    required List<MatchModel> matches,
    required UserModel user,
    required String userRegion,
    DateTime? userPreferredTime,
  }) {
    final preferredTime = userPreferredTime ?? DateTime.now();
    final filtered = <MatchModel>[];

    // 1단계: 엄격한 필터
    final step1Matches = matches.where((match) {
      return passesStep1(
        match: match,
        user: user,
        userRegion: userRegion,
        userPreferredTime: preferredTime,
      );
    }).toList();

    if (step1Matches.isNotEmpty) {
      filtered.addAll(step1Matches);
      return _sortByScore(filtered, user, userRegion, preferredTime);
    }

    // 2단계: 거리·실력 완화
    final step2Matches = matches.where((match) {
      return passesStep2(
        match: match,
        user: user,
        userRegion: userRegion,
      );
    }).toList();

    if (step2Matches.isNotEmpty) {
      filtered.addAll(step2Matches);
      return _sortByScore(filtered, user, userRegion, preferredTime);
    }

    // 3단계: 익일 대체 추천
    final step3Matches = matches.where((match) {
      return passesStep3(
        match: match,
        user: user,
        userRegion: userRegion,
        userPreferredDate: preferredTime,
      );
    }).toList();

    filtered.addAll(step3Matches);
    return _sortByScore(filtered, user, userRegion, preferredTime);
  }

  /// 점수 기준 정렬
  static List<MatchModel> _sortByScore(
    List<MatchModel> matches,
    UserModel user,
    String userRegion,
    DateTime preferredTime,
  ) {
    matches.sort((a, b) {
      final scoreA = _calculateMatchScore(a, user, userRegion, preferredTime);
      final scoreB = _calculateMatchScore(b, user, userRegion, preferredTime);
      return scoreA.compareTo(scoreB); // 낮은 점수가 좋음
    });
    return matches;
  }

  /// 매칭 점수 계산 (낮을수록 좋음)
  static double _calculateMatchScore(
    MatchModel match,
    UserModel user,
    String userRegion,
    DateTime preferredTime,
  ) {
    final distance = calculateDistance(userRegion, match.region);
    final timeOverlap = calculateTimeOverlap(
      match.time.start,
      match.time.end,
      preferredTime,
      preferredTime.add(const Duration(hours: 2)),
    );
    final ntrpDiff = calculateNtrpDiff(
      user.ntrp,
      match.ntrpRange.min,
      match.ntrpRange.max,
    );

    return calculateScore(
      match: match,
      user: user,
      userRegion: userRegion,
      distance: distance,
      timeOverlap: timeOverlap,
      ntrpDiff: ntrpDiff,
    );
  }
}

