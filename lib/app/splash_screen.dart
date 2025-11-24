import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_providers.dart';
import '../data/repositories/user_repository.dart';

/// 스플래시 화면
/// 인증 상태 체크 및 라우팅
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // 로그인 안됨 -> 인증 화면
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/auth');
          });
        } else {
          // 로그인 됨 -> 온보딩 체크
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              final userRepo = ref.read(userRepositoryProvider);
              final userModel = await userRepo.getCurrentUser();
              
              if (userModel == null) {
                // 온보딩 안함 -> 온보딩 화면
                context.go('/onboarding');
              } else {
                // 온보딩 완료 -> 홈 화면
                context.go('/home');
              }
            } catch (e) {
              print('사용자 정보 조회 오류: $e');
              context.go('/onboarding');
            }
          });
        }
        return const Scaffold(
          backgroundColor: Color(0xFFF8F7F5),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Tennis Friends',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8F7F5),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        print('인증 상태 확인 오류: $error');
        print('스택 트레이스: $stack');
        return Scaffold(
          backgroundColor: Color(0xFFF8F7F5),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '오류가 발생했습니다',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/auth');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('로그인 화면으로'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

