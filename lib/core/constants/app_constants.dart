/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  // 매칭 관련
  static const int maxPendingRequests = 3;
  static const int maxMatchHistory = 10;
  static const int maxMatchCapacity = 4; // 매칭 최대 참가자 수
  
  // 채팅 관련
  static const int maxImageSizeMB = 2;
  static const int chatReadonlyHours = 24;
  static const int chatArchiveDays = 30;
  
  // 필터링 관련
  static const double distanceStep1 = 5.0; // km
  static const double distanceStep2 = 10.0; // km
  static const double distanceStep3 = 15.0; // km
  static const int timeOverlapMinutes = 15;
  static const double ntrpTolerance = 0.8;
  
  // 매너온도
  static const double defaultMannerScore = 36.5;
  
  // Functions Rate Limit
  static const int functionsRateLimit = 10; // per minute
  
  // FCM Topics
  static String chatTopic(String matchId) => 'chat-$matchId';
  
  // Deep Links
  static String matchDeepLink(String matchId) => '/match/$matchId';
  static String chatDeepLink(String chatId) => '/chat/$chatId';
}

