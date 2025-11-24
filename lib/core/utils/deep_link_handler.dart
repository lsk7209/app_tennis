import 'package:go_router/go_router.dart';

/// 딥링크 핸들러
class DeepLinkHandler {
  final GoRouter router;

  DeepLinkHandler(this.router);

  /// 딥링크 처리
  void handleDeepLink(String link) {
    try {
      // 예: tennisfriends://match/123
      // 예: tennisfriends://chat/123
      final uri = Uri.parse(link);
      
      if (uri.scheme == 'tennisfriends' || uri.scheme == 'https') {
        final path = uri.path;
        
        if (path.startsWith('/match/')) {
          final matchId = path.replaceFirst('/match/', '');
          router.push('/match/$matchId');
        } else if (path.startsWith('/chat/')) {
          final chatId = path.replaceFirst('/chat/', '');
          router.push('/chat/$chatId');
        }
      }
    } catch (e) {
      print('딥링크 처리 오류: $e');
    }
  }

  /// FCM 데이터에서 딥링크 추출 및 처리
  void handleFcmDeepLink(Map<String, dynamic> data) {
    if (data.containsKey('route')) {
      final route = data['route'] as String;
      router.push(route);
    }
  }
}

