import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

      if (startAfter != null) {
        query = query.where('time.start', isGreaterThan: startAfter);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) => snapshot.docs);
    } catch (e) {
      throw FirestoreException('매칭 목록을 가져오는데 실패했습니다: $e');
    }
  }

  /// 매칭 생성
  Future<String> createMatch(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection('matches').add(data);
      return docRef.id;
    } catch (e) {
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

  /// 신청 생성
  Future<String> createRequest(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection('requests').add(data);
      return docRef.id;
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

