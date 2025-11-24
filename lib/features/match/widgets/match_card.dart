import 'package:flutter/material.dart';
import '../../../data/models/match_model.dart';
import '../../../core/constants/app_constants.dart';

/// 매칭 카드 위젯
class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF8F8F5);
    const textMain = Color(0xFF292524); // stone-800
    const textSecondary = Color(0xFF78716C); // stone-500
    const textTertiary = Color(0xFF57534E); // stone-600

    // 모집 인원 계산
    final totalCapacity = match.users.length + (match.waitlist.length);
    final maxCapacity = AppConstants.maxMatchCapacity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 텍스트 정보
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 지역, 시간
                    Text(
                      '${match.region}, ${_formatTime(match.time.start)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 모집 인원, NTRP
                    Text(
                      '$totalCapacity/$maxCapacity명 모집, NTRP ${match.ntrpRange.min.toStringAsFixed(1)}-${match.ntrpRange.max.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 시설 아이콘들
                    Wrap(
                      spacing: 12,
                      children: [
                        if (match.facilities.parking)
                          const Icon(
                            Icons.local_parking,
                            size: 20,
                            color: textTertiary,
                          ),
                        if (match.facilities.water)
                          const Icon(
                            Icons.shower,
                            size: 20,
                            color: textTertiary,
                          ),
                        if (match.facilities.balls)
                          const Icon(
                            Icons.roofing,
                            size: 20,
                            color: textTertiary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 오른쪽: 이미지
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const Icon(
                    Icons.sports_tennis,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
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
    
    return '$dateStr $timeStr';
  }
}

