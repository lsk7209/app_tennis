import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 인증 화면
/// 카카오 로그인 + 전화번호 인증
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleKakaoLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: 카카오 로그인 연동 완료 후 주석 해제
      // final kakaoAuth = ref.read(kakaoAuthServiceProvider);
      // await kakaoAuth.signInWithKakao();
      
      // 임시: 카카오 로그인 없이 바로 전화번호 인증 화면으로 이동
      await Future.delayed(const Duration(milliseconds: 300)); // 로딩 효과를 위한 짧은 딜레이
      
      // 전화번호 인증 화면으로
      if (mounted) {
        context.push('/phone-verify');
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류가 발생했습니다: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6), // background-light
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 상단 여백
              const Spacer(),
              
              // 중앙 콘텐츠
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 앱 아이콘/로고 영역
                    Container(
                      width: 200,
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.sports_tennis,
                        size: 100,
                        color: Color(0xFF0DF246), // primary green
                      ),
                    ),
                    
                    // 헤드라인
                    const Text(
                      '테니스는 혼자보다,\n함께일 때 더 즐겁습니다.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1C11),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // 하단 버튼 영역
              Column(
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  
                  // 카카오 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleKakaoLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE500), // 카카오 노란색
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999), // full rounded
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 카카오 아이콘 (임시로 텍스트로 표시)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 16,
                                    color: Color(0xFFFEE500),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '카카오로 시작하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.015,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  // 이용약관 안내 텍스트
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    child: Text(
                      '로그인 시 이용약관 및 개인정보처리방침에 동의하는 것으로 간주합니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
