import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/async_value_widget.dart';
import '../../../widgets/main_navigation.dart';
import '../../../data/models/match_model.dart';
import '../providers/match_providers.dart';
import '../widgets/match_card.dart';
import 'match_create_screen.dart';
import 'match_detail_screen.dart';

/// 홈 화면 (오늘의 매칭 추천)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(recommendedMatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tennis Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/match');
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
            child: ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return MatchCard(
                  match: match,
                  onTap: () {
                    context.push('/match/${match.matchId}');
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/match/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('매칭 등록'),
      ),
      bottomNavigationBar: MainNavigation(
        currentPath: GoRouterState.of(context).uri.path,
      ),
    );
  }
}

