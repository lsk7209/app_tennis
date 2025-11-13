import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/request_model.dart';
import '../../../data/repositories/request_repository.dart';
import '../../../data/sources/firestore_source.dart';
import '../../../core/errors/app_exceptions.dart';

/// 호스트 신청 관리 위젯
class HostRequestManager extends ConsumerWidget {
  final String matchId;

  const HostRequestManager({
    super.key,
    required this.matchId,
  });

  Future<void> _handleApprove(BuildContext context, WidgetRef ref, String reqId) async {
    try {
      final requestRepo = ref.read(requestRepositoryProvider);
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

  Future<void> _handleReject(BuildContext context, WidgetRef ref, String reqId) async {
    try {
      final requestRepo = ref.read(requestRepositoryProvider);
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
  Widget build(BuildContext context, WidgetRef ref) {
    final source = FirestoreSource(FirebaseFirestore.instance);
    
    return FutureBuilder<List<RequestModel>>(
      future: _loadRequests(source),
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
            const Text(
              '신청 관리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('신청자: ${request.applicantId.substring(0, 8)}...'),
                    subtitle: Text('상태: ${_getStatusText(request.status)}'),
                    trailing: request.status == RequestStatus.requested
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => _handleApprove(context, ref, request.reqId),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _handleReject(context, ref, request.reqId),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<RequestModel>> _loadRequests(FirestoreSource source) async {
    final docs = await source.getMatchRequests(matchId);
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


