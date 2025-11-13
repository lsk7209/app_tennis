import 'package:flutter/material.dart';

/// 프로필 화면
/// 내정보: 프로필, 신청내역, 매칭이력, 통계, 설정
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내정보'),
      ),
      body: const Center(
        child: Text('Profile Screen - 구현 예정'),
      ),
    );
  }
}

