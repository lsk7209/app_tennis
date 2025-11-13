import 'package:firebase_messaging/firebase_messaging.dart';

/// 백그라운드 메시지 핸들러
/// 최상위 함수로 정의해야 함
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('백그라운드 메시지 수신: ${message.messageId}');
  // 여기서는 로깅만, 실제 처리는 앱이 열릴 때 처리
}

