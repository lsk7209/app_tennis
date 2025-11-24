import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/request_model.dart';

/// Firestore 데이터 소스
class FirestoreSource {
  final FirebaseFirestore _firestore;

  FirestoreSource(this._firestore);

  /// 사용자 문서 가져오기
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw FirestoreException('사용자 정보를 가져오는데 실패했습니다: $e');
    }
  }

  /// 사용자 문서 저장/업데이트
  Future<void> setUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      throw FirestoreException('사용자 정보를 저장하는데 실패했습니다: $e');
    }
  }

  /// 매칭 문서 가져오기
  Future<Map<String, dynamic>?> getMatch(String matchId) async {
    try {
      final doc = await _firestore.collection('matches').doc(matchId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw FirestoreException('매칭 정보를 가져오는데 실패했습니다: $e');
    }
  }

  /// 매칭 목록 조회 (쿼리)
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getMatches({
    String? region,
    DateTime? startAfter,
    int? limit,
  }) {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection('matches').where('state', isEqualTo: 'open');

      if (region != null) {
        query = query.where('region', isEqualTo: region);
      }

      // 시간 기준 정렬 - createdAt으로 정렬 (인덱스 문제 방지)
      // time.start는 중첩 필드라 인덱스가 필요하므로 createdAt 사용
      query = query.orderBy('createdAt', descending: true);
      
      // limit 기본값 설정 (성능 및 비용 최적화)
      // 기본값 20으로 설정하여 대량 데이터 조회 방지
      final queryLimit = limit ?? 20;
      query = query.limit(queryLimit);
      
      // startAfter는 페이지네이션을 위해 사용되지만,
      // 현재는 createdAt 기준이므로 startAfter 파라미터는 향후 개선 예정
      // TODO: startAfter를 DocumentSnapshot으로 변경하여 페이지네이션 구현

      return query.snapshots().map((snapshot) => snapshot.docs).handleError((error) {
        print('Firestore 스트림 오류: $error');
        // 에러 발생 시 빈 리스트 반환
        return <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      });
    } catch (e) {
      print('매칭 목록 조회 오류: $e');
      // 에러 발생 시 빈 스트림 반환
      return Stream.value(<QueryDocumentSnapshot<Map<String, dynamic>>>[]);
    }
  }

  /// 매칭 생성 (커스텀 ID 사용)
  Future<String> createMatch(String matchId, Map<String, dynamic> data) async {
    try {
      print('Firestore에 매칭 저장 시도: matchId=$matchId');
      print('저장할 데이터 타입 확인:');
      data.forEach((key, value) {
        print('  $key: ${value.runtimeType}');
      });
      
      // 타임아웃 설정 (30초)
      print('Firestore set() 호출 시작...');
      await _firestore.collection('matches').doc(matchId).set(data)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('Firestore 저장 타임아웃 발생!');
              throw FirestoreException('Firestore 저장 타임아웃: 30초 내에 응답이 없습니다. Firestore 규칙을 확인하거나 네트워크를 확인해주세요.');
            },
          );
      
      print('Firestore에 매칭 저장 성공: matchId=$matchId');
      return matchId;
    } catch (e, stackTrace) {
      print('Firestore 매칭 생성 실패: $e');
      print('스택 트레이스: $stackTrace');
      
      // 권한 오류인지 확인
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        throw FirestoreException('Firestore 권한 오류: Firestore 규칙을 확인하거나 배포해주세요. $e');
      }
      
      // 타임아웃 오류
      if (e is FirestoreException) {
        rethrow;
      }
      
      throw FirestoreException('매칭을 생성하는데 실패했습니다: $e');
    }
  }

  /// 매칭 업데이트
  Future<void> updateMatch(String matchId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('matches').doc(matchId).update(data);
    } catch (e) {
      throw FirestoreException('매칭을 업데이트하는데 실패했습니다: $e');
    }
  }

  /// 신청 생성 (커스텀 ID 사용)
  Future<String> createRequest(String reqId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('requests').doc(reqId).set(data);
      return reqId;
    } catch (e) {
      throw FirestoreException('신청을 생성하는데 실패했습니다: $e');
    }
  }

  /// 신청 조회
  Future<Map<String, dynamic>?> getRequest(String reqId) async {
    try {
      final doc = await _firestore.collection('requests').doc(reqId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw FirestoreException('신청 정보를 가져오는데 실패했습니다: $e');
    }
  }

  /// 사용자의 신청 목록 조회
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getUserRequests(
    String userId, {
    RequestStatus? status,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('requests')
          .where('applicantId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      return query.snapshots().map((snapshot) => snapshot.docs);
    } catch (e) {
      throw FirestoreException('신청 목록을 가져오는데 실패했습니다: $e');
    }
  }

  /// 매칭의 신청 목록 조회
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getMatchRequests(
    String matchId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('requests')
          .where('matchId', isEqualTo: matchId)
          .get();
      return snapshot.docs;
    } catch (e) {
      throw FirestoreException('매칭 신청 목록을 가져오는데 실패했습니다: $e');
    }
  }

  /// 신청 업데이트
  Future<void> updateRequest(String reqId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('requests').doc(reqId).update(data);
    } catch (e) {
      throw FirestoreException('신청을 업데이트하는데 실패했습니다: $e');
    }
  }

  /// 채팅 생성
  Future<void> createChat(String matchId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('chats').doc(matchId).set(data);
    } catch (e) {
      throw FirestoreException('채팅을 생성하는데 실패했습니다: $e');
    }
  }

  /// 채팅 메시지 스트림
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getChatMessages(
    String matchId,
  ) {
    try {
      return _firestore
          .collection('chats')
          .doc(matchId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } catch (e) {
      throw FirestoreException('채팅 메시지를 가져오는데 실패했습니다: $e');
    }
  }

  /// 채팅 메시지 전송
  Future<String> sendChatMessage(
    String matchId,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _firestore
          .collection('chats')
          .doc(matchId)
          .collection('messages')
          .add(data);
      return docRef.id;
    } catch (e) {
      throw FirestoreException('메시지를 전송하는데 실패했습니다: $e');
    }
  }

  /// 트랜잭션 실행
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) action,
  ) async {
    try {
      return await _firestore.runTransaction(action);
    } catch (e) {
      throw FirestoreException('트랜잭션 실행에 실패했습니다: $e');
    }
  }

  /// 배치 작업
  WriteBatch batch() {
    return _firestore.batch();
  }

  /// 배치 커밋
  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      throw FirestoreException('배치 작업에 실패했습니다: $e');
    }
  }
}

