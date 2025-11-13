/// 유효성 검사 유틸리티
class ValidationUtils {
  ValidationUtils._();

  /// 전화번호 형식 검증
  static bool isValidPhoneNumber(String phone) {
    // 간단한 검증: 숫자만 포함하고 10-11자리
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 11;
  }

  /// 이메일 형식 검증
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 닉네임 검증 (2-20자)
  static bool isValidNickname(String nickname) {
    final trimmed = nickname.trim();
    return trimmed.length >= 2 && trimmed.length <= 20;
  }

  /// NTRP 범위 검증 (1.0-7.0)
  static bool isValidNtrp(double ntrp) {
    return ntrp >= 1.0 && ntrp <= 7.0;
  }

  /// 지역 검증 (비어있지 않음)
  static bool isValidRegion(String region) {
    return region.trim().isNotEmpty;
  }
}

