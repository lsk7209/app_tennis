import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/di.dart';
import 'core/services/fcm_service.dart';
// TODO: firebase_options.dart 파일 생성 후 주석 해제
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  // TODO: firebase_options.dart 파일 생성 후 주석 해제
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  // 임시: Firebase 초기화 (실제 프로젝트 설정 필요)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase 설정이 없을 경우 에러 처리
    print('Firebase 초기화 오류: $e');
    print('firebase_options.dart 파일을 생성해주세요.');
  }
  
  // 의존성 주입 초기화
  await initializeDependencies();
  
  runApp(
    const ProviderScope(
      child: TennisFriendsApp(),
    ),
  );
}

