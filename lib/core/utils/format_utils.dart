import 'package:intl/intl.dart';

/// 한국 포맷팅 유틸리티
class FormatUtils {
  FormatUtils._();

  /// 전화번호 포맷팅 (010-1234-5678)
  static String formatPhoneNumber(String phoneNumber) {
    // 숫자만 추출
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 11) {
      // 010-1234-5678 형식
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      // 02-1234-5678 형식 (서울 지역번호)
      if (digits.startsWith('02')) {
        return '${digits.substring(0, 2)}-${digits.substring(2, 6)}-${digits.substring(6)}';
      } else {
        // 031-123-4567 형식
        return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
      }
    }
    return phoneNumber; // 포맷팅 실패 시 원본 반환
  }
  
  /// Firebase용 전화번호 포맷팅 (+82-10-1234-5678)
  /// 한국 국가 코드 추가
  static String formatPhoneNumberForFirebase(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.startsWith('0')) {
      // 0으로 시작하면 0 제거하고 +82 추가
      return '+82${digits.substring(1)}';
    } else if (digits.startsWith('82')) {
      // 82로 시작하면 + 추가
      return '+$digits';
    } else {
      // 그 외는 +82 추가
      return '+82$digits';
    }
  }

  /// 숫자 포맷팅 (천 단위 구분자)
  /// 예: 1000 -> 1,000
  static String formatNumber(int number) {
    return NumberFormat('#,###', 'ko_KR').format(number);
  }

  /// 금액 포맷팅 (원화)
  /// 예: 1000 -> 1,000원
  static String formatCurrency(int amount) {
    return '${formatNumber(amount)}원';
  }

  /// 거리 포맷팅 (km)
  /// 예: 1.5 -> 1.5km
  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }

  /// 시간 포맷팅 (한국 형식)
  /// 예: 14:30 -> 오후 2:30
  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    
    if (hour < 12) {
      return '오전 $hour:${minute.toString().padLeft(2, '0')}';
    } else if (hour == 12) {
      return '오후 $hour:${minute.toString().padLeft(2, '0')}';
    } else {
      return '오후 ${hour - 12}:${minute.toString().padLeft(2, '0')}';
    }
  }

  /// 날짜 포맷팅 (한국 형식)
  /// 예: 2024년 1월 15일
  static String formatDate(DateTime date) {
    return DateFormat('yyyy년 M월 d일', 'ko_KR').format(date);
  }

  /// 날짜+시간 포맷팅 (한국 형식)
  /// 예: 2024년 1월 15일 오후 2시 30분
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy년 M월 d일 a h시 m분', 'ko_KR').format(dateTime);
  }
}

