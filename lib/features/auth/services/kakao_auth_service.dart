import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '../../../core/errors/app_exceptions.dart';

/// 카카오 인증 서비스
class KakaoAuthService {
  final FirebaseAuth _auth;
  // Firebase Functions는 discontinued이므로 주석 처리
  // final FirebaseFunctions _functions;

  KakaoAuthService(this._auth);

  /// 카카오 로그인
  Future<UserCredential> signInWithKakao() async {
    try {
      // 카카오 로그인
      await kakao.UserApi.instance.loginWithKakaoTalk();
      
      // 카카오 사용자 정보 가져오기
      kakao.User user = await kakao.UserApi.instance.me();
      
      if (user.kakaoAccount == null) {
        throw AuthException('카카오 계정 정보를 가져올 수 없습니다');
      }

      // TODO: Firebase 커스텀 토큰 생성 (Cloud Function 호출)
      // firebase_functions가 discontinued이므로 다른 방법 필요
      // 임시로 에러 발생
      throw AuthException('Firebase Functions 설정이 필요합니다. Firebase 프로젝트를 설정해주세요.');
      
      // Firebase 커스텀 토큰으로 로그인
      // return await _auth.signInWithCustomToken(customToken);
    } on kakao.KakaoException catch (e) {
      throw AuthException('카카오 로그인 오류: ${e.toString()}');
    } catch (e) {
      throw AuthException('로그인에 실패했습니다: $e');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await kakao.UserApi.instance.logout();
      await _auth.signOut();
    } catch (e) {
      throw AuthException('로그아웃에 실패했습니다: $e');
    }
  }
}

