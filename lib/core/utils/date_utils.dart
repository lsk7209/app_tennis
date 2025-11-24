import 'package:intl/intl.dart';

/// 날짜/시간 유틸리티
class AppDateUtils {
  AppDateUtils._();

  /// 날짜 포맷팅 (예: 2024년 1월 15일)
  static String formatDate(DateTime date) {
    return DateFormat('yyyy년 M월 d일', 'ko_KR').format(date);
  }

  /// 시간 포맷팅 (예: 오후 2시 30분)
  static String formatTime(DateTime time) {
    return DateFormat('a h시 m분', 'ko_KR').format(time);
  }

  /// 날짜+시간 포맷팅
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy년 M월 d일 a h시 m분', 'ko_KR').format(dateTime);
  }

  /// 상대 시간 (예: 2시간 전)
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// 시간 겹침 확인 (분 단위)
  static int getTimeOverlapMinutes(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    final overlapStart = start1.isAfter(start2) ? start1 : start2;
    final overlapEnd = end1.isBefore(end2) ? end1 : end2;

    if (overlapStart.isAfter(overlapEnd)) {
      return 0;
    }

    return overlapEnd.difference(overlapStart).inMinutes;
  }
}

