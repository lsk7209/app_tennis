import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    // FCM 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fcmService = ref.read(fcmServiceProvider);
      fcmService.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Tennis Friends',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
    );
  }
}
