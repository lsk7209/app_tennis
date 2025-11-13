import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/request_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/request_repository.dart';

/// 현재 사용자 프로필 프로바이더
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final userRepo = ref.watch(userRepositoryProvider);
  return await userRepo.getCurrentUser();
});

/// 사용자 신청 내역 프로바이더
final userRequestsProvider = StreamProvider<List<RequestModel>>((ref) {
  final requestRepo = ref.watch(requestRepositoryProvider);
  return requestRepo.getUserRequests();
});

