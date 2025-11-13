import 'package:flutter/material.dart';
import '../../../data/models/match_model.dart';
import '../../../core/utils/date_utils.dart' as app_date;

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      match.region,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStateColor(match.state),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStateText(match.state),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    app_date.AppDateUtils.formatDateTime(match.time.start),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${match.users.length}명 참가',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (match.waitlist.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '대기 ${match.waitlist.length}명',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NTRP ${match.ntrpRange.min.toStringAsFixed(1)}-${match.ntrpRange.max.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (match.facilities.parking)
                    _FacilityChip(icon: Icons.local_parking, label: '주차'),
                  if (match.facilities.balls)
                    _FacilityChip(icon: Icons.sports_tennis, label: '공'),
                  if (match.facilities.water)
                    _FacilityChip(icon: Icons.water_drop, label: '물'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStateColor(MatchState state) {
    switch (state) {
      case MatchState.open:
        return Colors.green;
      case MatchState.matched:
        return Colors.blue;
      case MatchState.completed:
        return Colors.grey;
    }
  }

  String _getStateText(MatchState state) {
    switch (state) {
      case MatchState.open:
        return '모집중';
      case MatchState.matched:
        return '확정';
      case MatchState.completed:
        return '완료';
    }
  }
}

/// 시설 칩 위젯
class _FacilityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FacilityChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

