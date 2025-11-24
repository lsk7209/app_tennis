import 'package:flutter/material.dart';

/// 디자인 토큰 상수
class DesignTokens {
  DesignTokens._();

  // 색상
  static const Color primaryMain = Color(0xFF0000FF); // #0000FF
  static const Color secondaryMain = Color(0xFF263238); // blueGrey[900]
  
  // 테니스 앱 특화 색상
  static const Color tennisGreen = Color(0xFFA8C958); // 테니스 코트 그린
  static const Color vibrantOrange = Color(0xFFFF6B00); // 활기찬 오렌지
  static const Color primaryOrange = Color(0xFFFFA726); // 프라이머리 오렌지
  static const Color pointGreen = Color(0xFF4CAF50); // 포인트 그린
  static const Color activeGreen = Color(0xFF4CAF50); // 액티브 그린 (pointGreen과 동일)
  
  // 배경 색상
  static const Color backgroundColor = Color(0xFFF8F7F5); // 메인 배경 (베이지/크림)
  static const Color backgroundColorLight = Color(0xFFF6F8F6); // 연한 그린 배경
  static const Color backgroundColorChat = Color(0xFFF5F8F6); // 채팅 배경
  
  // 텍스트 색상
  static const Color textMain = Color(0xFF333333); // 메인 텍스트
  static const Color textSecondary = Color(0xFFAAAAAA); // 보조 텍스트
  static const Color textSecondaryDark = Color(0xFF6B7280); // 다크 보조 텍스트
  static const Color textTertiary = Color(0xFF6C757D); // 3차 텍스트
  
  // 테두리 색상
  static const Color borderLight = Color(0xFFEAEAEA); // 연한 테두리
  static const Color borderMedium = Color(0xFFDEE2E6); // 중간 테두리
  
  // Neutral 색상 스케일 (50-900)
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // 간격 (4px 스텝)
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing8 = 32.0;

  // Border Radius (전역 기본 8)
  static const double borderRadius0 = 0.0;
  static const double borderRadius4 = 4.0;
  static const double borderRadius8 = 8.0; // 기본값
  static const double borderRadius12 = 12.0;
  static const double borderRadius16 = 16.0;

  // Shadows (0-24, blur↑ opacity↓)
  static List<BoxShadow> get shadow0 => [];
  static List<BoxShadow> get shadow4 => [
    BoxShadow(
      color: const Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> get shadow8 => [
    BoxShadow(
      color: const Color.fromRGBO(0, 0, 0, 0.06),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> get shadow12 => [
    BoxShadow(
      color: const Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  static List<BoxShadow> get shadow16 => [
    BoxShadow(
      color: const Color.fromRGBO(0, 0, 0, 0.04),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> get shadow24 => [
    BoxShadow(
      color: const Color.fromRGBO(0, 0, 0, 0.03),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
}

/// 앱 테마 설정
/// Design Tokens 기반 테마 적용
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    // Primary 색상 (테니스 그린)
    primary: DesignTokens.tennisGreen,
    onPrimary: Colors.white,
    primaryContainer: Color.fromRGBO(
      DesignTokens.tennisGreen.red,
      DesignTokens.tennisGreen.green,
      DesignTokens.tennisGreen.blue,
      0.2,
    ),
    onPrimaryContainer: DesignTokens.tennisGreen,
    
    // Secondary 색상 (오렌지)
    secondary: DesignTokens.vibrantOrange,
    onSecondary: Colors.white,
    secondaryContainer: Color.fromRGBO(
      DesignTokens.vibrantOrange.red,
      DesignTokens.vibrantOrange.green,
      DesignTokens.vibrantOrange.blue,
      0.2,
    ),
    onSecondaryContainer: DesignTokens.vibrantOrange,
    
    // Tertiary 색상 (포인트 그린)
    tertiary: DesignTokens.pointGreen,
    onTertiary: Colors.white,
    tertiaryContainer: Color.fromRGBO(
      DesignTokens.pointGreen.red,
      DesignTokens.pointGreen.green,
      DesignTokens.pointGreen.blue,
      0.1,
    ),
    onTertiaryContainer: DesignTokens.pointGreen,
    
    // Error
    error: Colors.red.shade700,
    onError: Colors.white,
    
    // Surface & Background
    surface: Colors.white,
    onSurface: DesignTokens.textMain,
    surfaceVariant: DesignTokens.neutral100,
    onSurfaceVariant: DesignTokens.textSecondaryDark,
    background: DesignTokens.backgroundColor,
    onBackground: DesignTokens.textMain,
    
    // Outline
    outline: DesignTokens.borderLight,
    outlineVariant: DesignTokens.neutral200,
  ),
  
  // Typography
  // TODO: Pretendard Variable 폰트 추가 후 활성화
  // TODO: Outfit 폰트 (영문 헤드라인용) 추가 후 활성화
  fontFamily: 'Pretendard', // 폰트 추가 후 활성화
  
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  ),
  
  // AppBar
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Color.fromRGBO(
      DesignTokens.backgroundColor.red,
      DesignTokens.backgroundColor.green,
      DesignTokens.backgroundColor.blue,
      0.8,
    ),
    foregroundColor: DesignTokens.textMain,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: DesignTokens.textMain,
    ),
  ),
  
  // Card
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
    ),
    color: Colors.white,
    shadowColor: const Color.fromRGBO(0, 0, 0, 0.05),
  ),
  
  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
      borderSide: const BorderSide(color: DesignTokens.neutral300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
      borderSide: const BorderSide(color: DesignTokens.neutral300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
      borderSide: const BorderSide(color: DesignTokens.primaryMain, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
      borderSide: const BorderSide(color: Colors.red),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: DesignTokens.spacing4,
      vertical: DesignTokens.spacing3,
    ),
    filled: true,
    fillColor: Colors.white,
  ),
  
  // Elevated Button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DesignTokens.vibrantOrange,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing6,
        vertical: DesignTokens.spacing3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.borderRadius12),
      ),
      elevation: 8,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.1,
      ),
    ),
  ),
  
  // Outlined Button
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DesignTokens.primaryMain,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing6,
        vertical: DesignTokens.spacing3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
      ),
      side: const BorderSide(color: DesignTokens.primaryMain),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
  ),
  
  // Text Button
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: DesignTokens.primaryMain,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing4,
        vertical: DesignTokens.spacing2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
  ),
  
  // Floating Action Button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: DesignTokens.primaryMain,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
    ),
  ),
  
  // Bottom Navigation Bar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: DesignTokens.tennisGreen,
    unselectedItemColor: DesignTokens.textSecondary,
    selectedLabelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
  
  // Divider
  dividerTheme: const DividerThemeData(
    color: DesignTokens.neutral200,
    thickness: 1,
    space: 1,
  ),
);

