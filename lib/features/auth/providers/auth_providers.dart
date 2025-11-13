import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

/// 현재 사용자 스트림
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// 현재 사용자 정보
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  if (authState == null) return null;
  
  final userRepo = ref.watch(userRepositoryProvider);
  return await userRepo.getCurrentUser();
});

/// 로그인 상태
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

