import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/async_value_widget.dart';
import '../../../widgets/main_navigation.dart';
import '../../../data/models/match_model.dart';
import '../providers/match_providers.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

/// 매칭 리스트 화면 (필터 + 탐색)
class MatchListScreen extends ConsumerStatefulWidget {
  const MatchListScreen({super.key});

  @override
  ConsumerState<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends ConsumerState<MatchListScreen> {
  final _regionController = TextEditingController();
  String? _selectedRegion;

  @override
  void dispose() {
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = MatchFilter(
      region: _selectedRegion,
      limit: 50,
    );
    final matchesAsync = ref.watch(matchesProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 탐색'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _regionController,
              decoration: InputDecoration(
                labelText: '지역 검색',
                hintText: '예: 서울시 강남구',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _regionController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _regionController.clear();
                            _selectedRegion = null;
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) {
                setState(() {
                  _selectedRegion = value.trim().isEmpty ? null : value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: AsyncValueWidget<List<MatchModel>>(
              value: matchesAsync,
              data: (matches) {
                if (matches.isEmpty) {
                  return Center(
                    child: Text(
                      '검색 결과가 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(matchesProvider(filter));
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
          ),
        ],
      ),
      bottomNavigationBar: MainNavigation(
        currentPath: GoRouterState.of(context).uri.path,
      ),
    );
  }
}

