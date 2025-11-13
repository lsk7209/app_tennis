import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/kakao_auth_service.dart';
import '../services/phone_auth_service.dart';

/// KakaoAuthService 프로바이더
final kakaoAuthServiceProvider = Provider<KakaoAuthService>((ref) {
  return KakaoAuthService(
    FirebaseAuth.instance,
  );
});

/// PhoneAuthService 프로바이더
final phoneAuthServiceProvider = Provider<PhoneAuthService>((ref) {
  return PhoneAuthService(FirebaseAuth.instance);
});

