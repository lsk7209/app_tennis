import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/constants/app_constants.dart';

/// FCM 서비스
class FcmService {
  final FirebaseMessaging _messaging;
  final UserRepository _userRepository;

  FcmService(this._messaging, this._userRepository);

  /// FCM 초기화
  Future<void> initialize() async {
    // 권한 요청
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // FCM 토큰 가져오기
      final token = await _messaging.getToken();
      if (token != null) {
        await _userRepository.addFcmToken(token);
      }

      // 토큰 갱신 리스너
      _messaging.onTokenRefresh.listen((newToken) async {
        await _userRepository.addFcmToken(newToken);
      });
    }

    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드 메시지 핸들러 (앱이 종료된 상태)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    // 포그라운드에서 알림을 표시하려면 flutter_local_notifications 필요
    // 여기서는 기본 처리만
    print('포그라운드 메시지: ${message.notification?.title}');
  }

  /// 백그라운드 메시지 처리 (앱이 열린 상태에서 알림 클릭)
  void _handleBackgroundMessage(RemoteMessage message) {
    print('백그라운드 메시지: ${message.notification?.title}');
    // 딥링크 처리
    final data = message.data;
    if (data.containsKey('route')) {
      // 라우터로 이동 (전역 네비게이터 필요)
    }
  }

  /// 채팅 토픽 구독
  Future<void> subscribeToChat(String matchId) async {
    final topic = AppConstants.chatTopic(matchId);
    await _messaging.subscribeToTopic(topic);
  }

  /// 채팅 토픽 구독 해제
  Future<void> unsubscribeFromChat(String matchId) async {
    final topic = AppConstants.chatTopic(matchId);
    await _messaging.unsubscribeFromTopic(topic);
  }
}

/// FcmService 프로바이더
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    FirebaseMessaging.instance,
    ref.watch(userRepositoryProvider),
  );
});

/// 백그라운드 메시지 핸들러 (최상위 함수)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('백그라운드 메시지 수신: ${message.messageId}');
}

