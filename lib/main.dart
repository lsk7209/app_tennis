import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'app/app.dart';
import 'app/di.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 한국 로케일 설정
  Intl.defaultLocale = 'ko_KR';
  
  // Firebase 초기화
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    print('Firebase 초기화 성공');
  } catch (e, stackTrace) {
    // Firebase 초기화 실패 처리
    print('Firebase 초기화 오류: $e');
    print('스택 트레이스: $stackTrace');
    print('firebase_options.dart 파일의 Firebase 설정 값을 확인해주세요.');
    
    // 프로덕션 환경에서는 앱 실행 중단
    // 개발 환경에서는 경고만 출력하고 계속 진행
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      // 프로덕션에서는 Firebase 없이 앱 실행 불가
      print('프로덕션 환경에서 Firebase 초기화 실패 - 앱 종료');
      return;
    }
  }
  
  // 의존성 주입 초기화 (Firebase가 초기화된 경우에만)
  if (firebaseInitialized) {
    try {
      await initializeDependencies();
      print('의존성 초기화 완료');
    } catch (e, stackTrace) {
      print('의존성 초기화 오류: $e');
      print('스택 트레이스: $stackTrace');
      // 의존성 초기화 실패는 앱 실행을 막지 않음
    }
  } else {
    print('Firebase 미초기화로 인해 일부 의존성 초기화 건너뜀');
  }
  
  // 에러 핸들러 설정
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter 에러: ${details.exception}');
    print('스택: ${details.stack}');
  };
  
  runApp(
    const ProviderScope(
      child: TennisFriendsApp(),
    ),
  );
}

