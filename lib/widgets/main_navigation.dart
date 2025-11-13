import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 메인 네비게이션 바 (하단)
class MainNavigation extends StatelessWidget {
  final String currentPath;

  const MainNavigation({
    super.key,
    required this.currentPath,
  });

  int _getCurrentIndex() {
    if (currentPath.startsWith('/home')) return 0;
    if (currentPath.startsWith('/match')) return 1;
    if (currentPath.startsWith('/chat')) return 2;
    if (currentPath.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/match');
            break;
          case 2:
            // 채팅 목록 화면이 없으므로 홈으로
            context.go('/home');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_tennis),
          label: '매칭',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: '채팅',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '내정보',
        ),
      ],
    );
  }
}

