import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';
import '../core/services/fcm_service.dart';

/// Tennis Friends 메인 앱 위젯
class TennisFriendsApp extends ConsumerStatefulWidget {
  const TennisFriendsApp({super.key});

  @override
  ConsumerState<TennisFriendsApp> createState() => _TennisFriendsAppState();
}

class _TennisFriendsAppState extends ConsumerState<TennisFriendsApp> {
  bool _fcmInitialized = false;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    // FCM 초기화 (한 번만 실행)
    if (!_fcmInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_fcmInitialized) {
          try {
            final fcmService = ref.read(fcmServiceProvider);
            fcmService.initialize();
            _fcmInitialized = true;
          } catch (e) {
            // 웹에서는 FCM이 제한적이므로 에러 무시
            print('FCM 초기화 오류 (무시됨): $e');
          }
        }
      });
    }
    
    return MaterialApp.router(
      title: '테니스 프렌즈',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
      // 한국 로케일 설정
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
