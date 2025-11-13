/// 앱 커스텀 예외 클래스
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// 인증 예외
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// 네트워크 예외
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Firestore 예외
class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code});
}

/// 매칭 예외
class MatchException extends AppException {
  const MatchException(super.message, {super.code});
}

/// 유효성 검사 예외
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

