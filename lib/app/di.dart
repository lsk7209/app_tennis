import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../core/services/fcm_service.dart';
import 'firebase_messaging.dart' as fcm;

/// 의존성 주입 초기화
Future<void> initializeDependencies() async {
  // Firebase App Check 활성화
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // 프로덕션에서는 playIntegrity
    appleProvider: AppleProvider.debug, // 프로덕션에서는 appAttest
  );
  
  // FCM 백그라운드 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(fcm.firebaseMessagingBackgroundHandler);
  
  // 기타 초기화 작업
}

/// Firebase Auth 인스턴스
final firebaseAuth = FirebaseAuth.instance;

/// Firebase Messaging 인스턴스
final firebaseMessaging = FirebaseMessaging.instance;

