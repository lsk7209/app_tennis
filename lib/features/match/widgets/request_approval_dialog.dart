import 'package:flutter/material.dart';
import '../../../data/models/request_model.dart';
import '../../../data/repositories/request_repository.dart';
import '../../../core/errors/app_exceptions.dart';

/// 신청 승인/거절 다이얼로그
class RequestApprovalDialog extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onApproved;
  final VoidCallback onRejected;

  const RequestApprovalDialog({
    super.key,
    required this.request,
    required this.onApproved,
    required this.onRejected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('신청 처리'),
      content: const Text('이 신청을 승인하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRejected();
          },
          child: const Text('거절'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onApproved();
          },
          child: const Text('승인'),
        ),
      ],
    );
  }
}

/// 호스트 신청 관리 위젯
class HostRequestManager extends StatelessWidget {
  final String matchId;
  final RequestRepository requestRepo;

  const HostRequestManager({
    super.key,
    required this.matchId,
    required this.requestRepo,
  });

  Future<void> _handleApprove(BuildContext context, String reqId) async {
    try {
      await requestRepo.approveRequest(reqId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신청이 승인되었습니다')),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('승인에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _handleReject(BuildContext context, String reqId) async {
    try {
      await requestRepo.rejectRequest(reqId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신청이 거절되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('거절에 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RequestModel>>(
      future: _loadRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('신청이 없습니다'),
          );
        }

        final requests = snapshot.data!
            .where((req) =>
                req.status == RequestStatus.requested ||
                req.status == RequestStatus.waitlisted)
            .toList();

        if (requests.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('처리할 신청이 없습니다'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '신청 관리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text('신청자: ${request.applicantId.substring(0, 8)}...'),
                    subtitle: Text('상태: ${_getStatusText(request.status)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (request.status == RequestStatus.requested) ...[
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _handleApprove(context, request.reqId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _handleReject(context, request.reqId),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<RequestModel>> _loadRequests() async {
    final source = requestRepo as dynamic;
    final docs = await source._source.getMatchRequests(matchId);
    return docs.map((doc) {
      final data = doc.data();
      return RequestModel.fromJson({
        ...data,
        'reqId': doc.id,
      });
    }).toList();
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

