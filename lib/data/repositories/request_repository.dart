import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/constants/app_constants.dart';
import '../models/request_model.dart';
import '../sources/firestore_source.dart';
import 'chat_repository.dart';

/// 신청 리포지토리
class RequestRepository {
  final FirestoreSource _source;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  RequestRepository(this._source, this._auth, this._uuid);

  // ChatRepository import를 위해 필요
  FirestoreSource get source => _source;

  /// 신청 생성
  Future<String> createRequest(String matchId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('로그인이 필요합니다');
    }

    // 확정되지 않은 신청 개수 확인
    final pendingRequests = await getPendingRequestsCount(user.uid);
    if (pendingRequests >= AppConstants.maxPendingRequests) {
      throw MatchException(
        '확정되지 않은 신청이 ${AppConstants.maxPendingRequests}개 이상입니다',
      );
    }

    // 중복 신청 확인
    final existing = await getRequestByMatchAndUser(matchId, user.uid);
    if (existing != null && existing.status != RequestStatus.cancelled) {
      throw MatchException('이미 신청한 매칭입니다');
    }

    final reqId = _uuid.v4();
    final request = RequestModel(
      reqId: reqId,
      matchId: matchId,
      applicantId: user.uid,
      status: RequestStatus.requested,
      createdAt: DateTime.now(),
    );

    final json = request.toJson();
    json.remove('reqId'); // 문서 ID로 사용

    await _source.createRequest(reqId, json);
    return reqId;
  }

  /// 신청 조회
  Future<RequestModel?> getRequest(String reqId) async {
    final data = await _source.getRequest(reqId);
    if (data == null) return null;

    return RequestModel.fromJson({
      ...data,
      'reqId': reqId,
    });
  }

  /// 매칭과 사용자로 신청 조회
  Future<RequestModel?> getRequestByMatchAndUser(
    String matchId,
    String userId,
  ) async {
    final requests = await _source.getMatchRequests(matchId);
    for (final doc in requests) {
      final data = doc.data();
      if (data['applicantId'] == userId) {
        return RequestModel.fromJson({
          ...data,
          'reqId': doc.id,
        });
      }
    }
    return null;
  }

  /// 사용자의 신청 목록 (스트림)
  Stream<List<RequestModel>> getUserRequests({
    RequestStatus? status,
  }) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _source.getUserRequests(user.uid, status: status).map((docs) {
      return docs.map((doc) {
        final data = doc.data();
        return RequestModel.fromJson({
          ...data,
          'reqId': doc.id,
        });
      }).toList();
    });
  }

  /// 확정되지 않은 신청 개수
  Future<int> getPendingRequestsCount(String userId) async {
    final requests = await getUserRequests().first;
    return requests.where((req) =>
        req.status == RequestStatus.requested ||
        req.status == RequestStatus.waitlisted ||
        req.status == RequestStatus.approved).length;
  }

  /// 신청 승인 (트랜잭션)
  Future<void> approveRequest(String reqId) async {
    await _source.runTransaction((transaction) async {
      final reqDoc = await transaction.get(
        FirebaseFirestore.instance.collection('requests').doc(reqId),
      );
      if (!reqDoc.exists) {
        throw MatchException('신청을 찾을 수 없습니다');
      }

      final reqData = reqDoc.data()!;
      final matchId = reqData['matchId'] as String;
      final applicantId = reqData['applicantId'] as String;

      final matchDoc = await transaction.get(
        FirebaseFirestore.instance.collection('matches').doc(matchId),
      );
      if (!matchDoc.exists) {
        throw MatchException('매칭을 찾을 수 없습니다');
      }

      final matchData = matchDoc.data()!;
      final users = List<String>.from(matchData['users'] ?? []);
      final waitlist = List<String>.from(matchData['waitlist'] ?? []);

      // 이미 확정된 경우
      if (matchData['state'] == 'matched') {
        // 대기자로 추가
        if (!waitlist.contains(applicantId)) {
          waitlist.add(applicantId);
          transaction.update(matchDoc.reference, {'waitlist': waitlist});
        }
        transaction.update(reqDoc.reference, {'status': 'waitlisted'});
        return;
      }

      // 참가자로 추가
      if (!users.contains(applicantId)) {
        users.add(applicantId);
        transaction.update(matchDoc.reference, {'users': users});

        // 매칭 확정 여부 확인 (예: 최소 인원 도달 시)
        final wasMatched = matchData['state'] == 'matched';
        if (users.length >= 2 && !wasMatched) {
          transaction.update(matchDoc.reference, {'state': 'matched'});
          // 채팅 자동 생성은 트랜잭션 외부에서 처리
          // TODO: Cloud Function으로 매칭 확정 이벤트 처리 권장
          // 현재는 트랜잭션 완료 후 비동기로 처리 (실패 시 재시도 로직 필요)
          _createChatAfterApproval(matchId, users);
        }
      }

      transaction.update(reqDoc.reference, {'status': 'approved'});
    });
  }

  /// 승인 후 채팅 생성 (트랜잭션 외부)
  /// 
  /// 주의: Firestore 트랜잭션은 최대 500개 문서 제한이 있고,
  /// 채팅 생성은 별도 컬렉션이므로 트랜잭션 외부에서 처리합니다.
  /// 실패 시 재시도 로직을 포함합니다.
  Future<void> _createChatAfterApproval(String matchId, List<String> users) async {
    const maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // 호스트 포함하여 채팅 멤버 구성
        final match = await _source.getMatch(matchId);
        if (match == null) {
          print('매칭을 찾을 수 없어 채팅 생성 중단: $matchId');
          return;
        }

        final hostId = match['hostId'] as String;
        final allMembers = [hostId, ...users].toSet().toList(); // 중복 제거

        // 이미 채팅이 존재하는지 확인
        final chatDoc = await FirebaseFirestore.instance
            .collection('chats')
            .doc(matchId)
            .get();
        
        if (chatDoc.exists) {
          print('채팅이 이미 존재함: $matchId');
          return;
        }

        // ChatRepository를 직접 생성하여 사용
        final chatRepo = ChatRepository(
          _source,
          FirebaseAuth.instance,
          const Uuid(),
        );

        await chatRepo.createChat(
          matchId: matchId,
          members: allMembers,
        );
        
        print('채팅 생성 성공: $matchId');
        return; // 성공 시 종료
      } catch (e, stackTrace) {
        retryCount++;
        print('채팅 생성 실패 (재시도 $retryCount/$maxRetries): $e');
        print('스택 트레이스: $stackTrace');
        
        if (retryCount >= maxRetries) {
          // 최대 재시도 횟수 초과 시 로그만 남기고 종료
          // 실제 운영 환경에서는 에러 리포팅 서비스(Crashlytics 등)에 전송 권장
          print('채팅 생성 최종 실패: $matchId');
          // TODO: 에러 리포팅 서비스에 전송
        } else {
          // 재시도 전 대기 (지수 백오프)
          await Future.delayed(Duration(seconds: retryCount));
        }
      }
    }
  }

  /// 신청 거부
  Future<void> rejectRequest(String reqId, {String? rejectCode}) async {
    await _source.updateRequest(reqId, {
      'status': 'rejected',
      if (rejectCode != null) 'rejectCode': rejectCode,
    });
  }

  /// 신청 취소
  Future<void> cancelRequest(String reqId) async {
    await _source.updateRequest(reqId, {'status': 'cancelled'});
  }
}

/// RequestRepository 프로바이더
final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepository(
    FirestoreSource(FirebaseFirestore.instance),
    FirebaseAuth.instance,
    const Uuid(),
  );
});

