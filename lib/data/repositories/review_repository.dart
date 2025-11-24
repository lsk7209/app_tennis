import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_exceptions.dart';
import '../sources/firestore_source.dart';

/// 리뷰 리포지토리
/// MVP에서는 내부 저장만, UI 비노출
class ReviewRepository {
  final FirestoreSource _source;
  final FirebaseAuth _auth;

  ReviewRepository(this._source, this._auth);

  /// 리뷰 저장 (내부 저장)
  /// matchId: 매칭 ID
  /// targetUserId: 리뷰 대상 사용자 ID
  /// rating: 평점 (1-5)
  /// comment: 코멘트 (선택)
  Future<void> saveReview({
    required String matchId,
    required String targetUserId,
    required int rating,
    String? comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('로그인이 필요합니다');
    }

    if (rating < 1 || rating > 5) {
      throw ValidationException('평점은 1-5 사이여야 합니다');
    }

    try {
      // 내부 저장: users_private/{uid}/reviews/{reviewId}
      final reviewData = {
        'matchId': matchId,
        'targetUserId': targetUserId,
        'reviewerId': user.uid,
        'rating': rating,
        if (comment != null) 'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // users 문서에 reviews 배열로 저장
      final userData = await _source.getUser(user.uid);
      final existingReviews = userData?['reviews'] as List<dynamic>? ?? [];
      
      await _source.setUser(
        user.uid,
        {
          'reviews': [...existingReviews, reviewData],
        },
      );

      // 매너온도 업데이트 (간단한 평균 계산)
      await _updateMannerScore(targetUserId);
    } catch (e) {
      throw FirestoreException('리뷰 저장에 실패했습니다: $e');
    }
  }

  /// 매너온도 업데이트
  Future<void> _updateMannerScore(String userId) async {
    try {
      // 해당 사용자의 모든 리뷰 가져오기
      final userData = await _source.getUser(userId);
      if (userData == null) return;

      final reviews = userData['reviews'] as List<dynamic>?;
      if (reviews == null || reviews.isEmpty) return;

      // 평균 평점 계산
      final ratings = reviews
          .map((r) => r['rating'] as int)
          .toList();

      if (ratings.isEmpty) return;

      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      // 매너온도는 36.5 + (평균평점 - 3) * 0.5 (예시)
      final mannerScore = 36.5 + (averageRating - 3) * 0.5;

      await _source.setUser(
        userId,
        {
          'manner': {
            'score': mannerScore.clamp(30.0, 50.0), // 30-50 범위
            'hidden': true,
          },
        },
      );
    } catch (e) {
      // 매너온도 업데이트 실패는 무시
      print('매너온도 업데이트 실패: $e');
    }
  }

  /// 리뷰 조회 (내부용)
  Future<List<Map<String, dynamic>>> getReviews(String userId) async {
    final userData = await _source.getUser(userId);
    if (userData == null) return [];

    final reviews = userData['reviews'] as List<dynamic>?;
    if (reviews == null) return [];

    return reviews.cast<Map<String, dynamic>>();
  }
}

/// ReviewRepository 프로바이더
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(
    FirestoreSource(FirebaseFirestore.instance),
    FirebaseAuth.instance,
  );
});

