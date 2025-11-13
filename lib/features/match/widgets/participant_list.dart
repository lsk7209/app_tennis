import 'package:flutter/material.dart';
import '../../../data/models/match_model.dart';

/// 참가자 목록 위젯
class ParticipantList extends StatelessWidget {
  final MatchModel match;
  final String? currentUserId;

  const ParticipantList({
    super.key,
    required this.match,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final allParticipants = [
      match.hostId,
      ...match.users,
    ].toSet().toList(); // 중복 제거

    if (allParticipants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '참가자',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allParticipants.length,
          itemBuilder: (context, index) {
            final userId = allParticipants[index];
            final isHost = userId == match.hostId;
            final isMe = userId == currentUserId;

            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  userId.substring(0, 1).toUpperCase(),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    userId.substring(0, 8),
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isHost) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '호스트',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                  if (isMe) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(나)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        if (match.waitlist.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '대기자',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: match.waitlist.length,
            itemBuilder: (context, index) {
              final userId = match.waitlist[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    userId.substring(0, 1).toUpperCase(),
                  ),
                ),
                title: Text(
                  userId.substring(0, 8),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                subtitle: const Text('대기중'),
              );
            },
          ),
        ],
      ],
    );
  }
}

