import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_messaging.dart' as fcm;

/// 의존성 주입 초기화
Future<void> initializeDependencies() async {
  try {
    // Firebase가 초기화되었는지 확인
    final app = Firebase.apps.isNotEmpty ? Firebase.app() : null;
    if (app == null) {
      print('Firebase가 초기화되지 않아 일부 기능이 제한됩니다.');
      return;
    }
    
    // Firebase App Check 활성화 (웹에서는 제한적)
    if (!kIsWeb) {
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug, // 프로덕션에서는 playIntegrity
          appleProvider: AppleProvider.debug, // 프로덕션에서는 appAttest
        );
      } catch (e) {
        print('App Check 활성화 오류 (무시됨): $e');
      }
    }
    
    // FCM 백그라운드 핸들러 등록 (웹에서는 지원 안됨)
    if (!kIsWeb) {
      try {
        FirebaseMessaging.onBackgroundMessage(fcm.firebaseMessagingBackgroundHandler);
      } catch (e) {
        print('FCM 백그라운드 핸들러 등록 오류 (무시됨): $e');
      }
    }
  } catch (e) {
    print('의존성 초기화 오류 (Firebase 기능 제한): $e');
    // Firebase가 없어도 앱은 계속 실행
  }
  
  // 기타 초기화 작업
}

/// Firebase Auth 인스턴스
final firebaseAuth = FirebaseAuth.instance;

/// Firebase Messaging 인스턴스
final firebaseMessaging = FirebaseMessaging.instance;

