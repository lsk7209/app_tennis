import 'package:flutter/material.dart';

/// 매칭 화면
/// 홈: 추천 매칭, 매칭탭: 필터+리스트 탐색
class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭'),
      ),
      body: const Center(
        child: Text('Match Screen - 구현 예정'),
      ),
    );
  }
}

