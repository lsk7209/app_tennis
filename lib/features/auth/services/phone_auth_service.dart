import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/app_exceptions.dart';

/// 전화번호 인증 서비스
class PhoneAuthService {
  final FirebaseAuth _auth;
  String? _verificationId;
  int? _resendToken;

  PhoneAuthService(this._auth);

  /// 전화번호 인증 코드 전송
  Future<void> sendVerificationCode(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // 자동 인증 완료 (Android)
        },
        verificationFailed: (FirebaseAuthException e) {
          throw AuthException('인증 코드 전송 실패: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw AuthException('인증 코드 전송에 실패했습니다: $e');
    }
  }

  /// 인증 코드 확인
  Future<void> verifyCode(String code) async {
    if (_verificationId == null) {
      throw AuthException('인증 코드를 먼저 전송해주세요');
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      await _auth.currentUser?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException('인증 코드 확인 실패: ${e.message}');
    } catch (e) {
      throw AuthException('인증에 실패했습니다: $e');
    }
  }

  /// 인증 코드 재전송
  Future<void> resendCode(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          throw AuthException('인증 코드 재전송 실패: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw AuthException('인증 코드 재전송에 실패했습니다: $e');
    }
  }
}

