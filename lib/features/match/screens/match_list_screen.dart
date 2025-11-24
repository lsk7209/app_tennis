import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/async_value_widget.dart';
import '../../../widgets/main_navigation.dart';
import '../../../data/models/match_model.dart';
import '../providers/match_providers.dart';

/// 매칭 리스트 화면 (필터 + 탐색)
class MatchListScreen extends ConsumerStatefulWidget {
  const MatchListScreen({super.key});

  @override
  ConsumerState<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends ConsumerState<MatchListScreen> {
  String _selectedSort = 'Recommended'; // 추천, 거리, 시간
  String? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF6F8F6);
    const textMain = Color(0xFF333333);
    const textSecondary = Color(0xFF6B7280);
    
    final filter = MatchFilter(
      region: _selectedRegion,
      limit: 50,
    );
    final matchesAsync = ref.watch(matchesProvider(filter));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textMain),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '매칭 찾기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textMain,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 필터 버튼들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _FilterButton(
                    label: '날짜',
                    onTap: () {
                      // 날짜 선택
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterButton(
                    label: '시간',
                    onTap: () {
                      // 시간 선택
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterButton(
                    label: '지역',
                    onTap: () {
                      // 지역 선택
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 정렬 옵션 및 매칭 개수
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 ${matchesAsync.value?.length ?? 0}개의 매칭이 있습니다.',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                // 정렬 토글
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SortToggleButton(
                        label: '추천',
                        isSelected: _selectedSort == 'Recommended',
                        onTap: () => setState(() => _selectedSort = 'Recommended'),
                      ),
                      _SortToggleButton(
                        label: '거리',
                        isSelected: _selectedSort == 'Distance',
                        onTap: () => setState(() => _selectedSort = 'Distance'),
                      ),
                      _SortToggleButton(
                        label: '시간',
                        isSelected: _selectedSort == 'Time',
                        onTap: () => setState(() => _selectedSort = 'Time'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 매칭 리스트
          Expanded(
            child: AsyncValueWidget<List<MatchModel>>(
              value: matchesAsync,
              data: (matches) {
                if (matches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sports_tennis,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '아직 매칭이 없어요.\n조건을 완화해보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '새로운 친구를 기다리는 중이에요.',
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(matchesProvider(filter));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      return _MatchListItem(
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

/// 필터 버튼
class _FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.05),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
                letterSpacing: 0.015,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more,
              size: 20,
              color: Color(0xFF333333),
            ),
          ],
        ),
      ),
    );
  }
}

/// 정렬 토글 버튼
class _SortToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFF333333) : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }
}

/// 매칭 리스트 아이템 (매칭탭용)
class _MatchListItem extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onTap;

  const _MatchListItem({
    required this.match,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const textMain = Color(0xFF333333);
    const textSecondary = Color(0xFF6B7280);
    const backgroundColor = Colors.white;

    // 상태에 따른 배지 색상
    Color badgeColor;
    String badgeText;
    if (match.state == MatchState.open && match.users.length < 4) {
      badgeColor = Colors.green.shade100;
      badgeText = '신청가능';
    } else if (match.waitlist.isNotEmpty) {
      badgeColor = Colors.grey.shade200;
      badgeText = '대기중';
    } else {
      badgeColor = Colors.yellow.shade100;
      badgeText = '확정';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade300,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const Icon(
                    Icons.sports_tennis,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 텍스트 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.region,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(match.time.start),
                      style: const TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'NTRP ${match.ntrpRange.min.toStringAsFixed(1)}-${match.ntrpRange.max.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (match.facilities.parking)
                          const Icon(Icons.roofing, size: 16, color: textSecondary),
                        if (match.facilities.water)
                          const Icon(Icons.local_parking, size: 16, color: textSecondary),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badgeText == '신청가능'
                              ? Colors.green.shade600
                              : badgeText == '대기중'
                                  ? Colors.grey.shade600
                                  : Colors.yellow.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final matchDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (matchDate == today) {
      dateStr = '오늘';
    } else if (matchDate == today.add(const Duration(days: 1))) {
      dateStr = '내일';
    } else {
      final weekday = ['월', '화', '수', '목', '금', '토', '일'][dateTime.weekday - 1];
      dateStr = weekday;
    }
    
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    String timeStr;
    if (hour < 12) {
      timeStr = '오전 $hour:${minute.toString().padLeft(2, '0')}';
    } else if (hour == 12) {
      timeStr = '오후 $hour:${minute.toString().padLeft(2, '0')}';
    } else {
      timeStr = '오후 ${hour - 12}:${minute.toString().padLeft(2, '0')}';
    }
    
    return '$dateStr, $timeStr - ${(dateTime.hour + 2).toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

