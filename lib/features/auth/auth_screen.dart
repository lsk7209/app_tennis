import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../onboarding/onboarding_screen.dart';
import 'providers/auth_providers.dart';
import 'providers/auth_service_providers.dart';
import 'services/kakao_auth_service.dart';
import '../../../core/utils/async_value_widget.dart';
import '../../../core/errors/app_exceptions.dart';

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
      final kakaoAuth = ref.read(kakaoAuthServiceProvider);
      await kakaoAuth.signInWithKakao();
      
      // 로그인 성공 후 전화번호 인증 화면으로
      if (mounted) {
        context.push('/phone-verify');
      }
    } on AppException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '로그인에 실패했습니다: $e';
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
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tennis Friends',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '테니스 매칭을 시작해보세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
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
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleKakaoLogin,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chat_bubble_outline),
                label: Text(_isLoading ? '로그인 중...' : '카카오로 시작하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.yellow.shade700,
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
