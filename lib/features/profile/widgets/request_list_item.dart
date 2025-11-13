import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/request_model.dart';
import '../../../core/utils/date_utils.dart' as app_date;

/// 신청 내역 아이템 위젯
class RequestListItem extends StatelessWidget {
  final RequestModel request;

  const RequestListItem({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('매칭 신청'),
        subtitle: Text(
          app_date.AppDateUtils.formatRelative(request.createdAt),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor(request.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(request.status),
            style: TextStyle(
              fontSize: 12,
              color: _getStatusColor(request.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          context.push('/match/${request.matchId}');
        },
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.requested:
        return Colors.orange;
      case RequestStatus.waitlisted:
        return Colors.blue;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.requested:
        return '신청됨';
      case RequestStatus.waitlisted:
        return '대기중';
      case RequestStatus.approved:
        return '승인됨';
      case RequestStatus.rejected:
        return '거부됨';
      case RequestStatus.cancelled:
        return '취소됨';
    }
  }
}

