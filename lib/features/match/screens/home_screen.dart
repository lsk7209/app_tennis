import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/async_value_widget.dart';
import '../../../widgets/main_navigation.dart';
import '../../../data/models/match_model.dart';
import '../providers/match_providers.dart';
import '../widgets/match_card.dart';

/// 홈 화면 (오늘의 매칭 추천)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(recommendedMatchesProvider);
    const backgroundColor = Color(0xFFF8F8F5); // background-light
    const primaryYellow = Color(0xFFFFEB3B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            size: 28,
            color: Color(0xFF292524), // stone-800
          ),
          onPressed: () {
            // 메뉴 열기
          },
        ),
        title: const Text(
          'Tennis Friends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF292524),
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 28,
              color: Color(0xFF292524),
            ),
            onPressed: () {
              // 알림 화면으로 이동
            },
          ),
        ],
      ),
      body: AsyncValueWidget<List<MatchModel>>(
        value: matchesAsync,
        data: (matches) {
          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_tennis,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '등록된 매칭이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '첫 매칭을 등록해보세요!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(recommendedMatchesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                ...matches.map((match) => MatchCard(
                      match: match,
                      onTap: () {
                        context.push('/match/${match.matchId}');
                      },
                    )),
                // 조건에 맞는 친구가 없을 때 표시되는 섹션
                if (matches.length < 3)
                  Container(
                    margin: const EdgeInsets.only(top: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.sports_tennis,
                          size: 80,
                          color: Color(0xFF292524),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '조건에 맞는 친구가 없나요?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF292524),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '비슷한 매칭을 추천드려요.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 112), // FAB 공간 확보
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/match/create');
        },
        backgroundColor: primaryYellow,
        child: const Icon(
          Icons.sports_tennis,
          color: Color(0xFF292524),
          size: 32,
        ),
      ),
      bottomNavigationBar: MainNavigation(
        currentPath: GoRouterState.of(context).uri.path,
      ),
    );
  }
}

