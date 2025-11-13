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
            final userRepo = ref.read(userRepositoryProvider);
            final userModel = await userRepo.getCurrentUser();
            
            if (userModel == null) {
              // 온보딩 안함 -> 온보딩 화면
              context.go('/onboarding');
            } else {
              // 온보딩 완료 -> 홈 화면
              context.go('/home');
            }
          });
        }
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Tennis Friends'),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('오류가 발생했습니다'),
              const SizedBox(height: 8),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.go('/auth');
                },
                child: const Text('로그인 화면으로'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

