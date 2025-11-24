import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/match_model.dart';
import '../sources/firestore_source.dart';

/// 매칭 리포지토리
class MatchRepository {
  final FirestoreSource _source;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  MatchRepository(this._source, this._auth, this._uuid);

  /// 매칭 생성
  Future<String> createMatch({
    required String region,
    required DateTime startTime,
    required DateTime endTime,
    required double ntrpMin,
    required double ntrpMax,
    required FacilitiesModel facilities,
    String? geohashPrefix,
  }) async {
    // 개발 단계: 로그인 없이도 등록 가능하도록 기본 사용자 ID 사용
    final user = _auth.currentUser;
    final hostId = user?.uid ?? 'dev-user-${DateTime.now().millisecondsSinceEpoch}';
    
    if (user == null) {
      print('개발 모드: 로그인 없이 매칭 등록 (hostId: $hostId)');
    }

    final matchId = _uuid.v4();
    final now = DateTime.now();
    
    // Firestore에 직접 저장할 수 있는 Map 생성 (DateTime 객체 직접 사용)
    final json = <String, dynamic>{
      'hostId': hostId,
      'users': <String>[],
      'waitlist': <String>[],
      'region': region,
      if (geohashPrefix != null) 'geohashPrefix': geohashPrefix,
      'time': {
        'start': startTime, // DateTime 객체 직접 사용 (Firestore가 자동 변환)
        'end': endTime,     // DateTime 객체 직접 사용
      },
      'ntrpRange': {
        'min': ntrpMin,
        'max': ntrpMax,
      },
      'facilities': {
        'parking': facilities.parking,
        'balls': facilities.balls,
        'water': facilities.water,
        'racket': facilities.racket,
        'etc': facilities.etc,
      },
      'state': MatchState.open.name,
      'createdAt': now, // DateTime 객체 직접 사용
    };

    print('직렬화된 JSON (DateTime 객체 포함): $json');
    await _source.createMatch(matchId, json);
    return matchId;
  }

  /// 매칭 목록 조회 (스트림)
  Stream<List<MatchModel>> getMatches({
    String? region,
    DateTime? startAfter,
    int? limit = 20,
  }) {
    return _source.getMatches(
      region: region,
      startAfter: startAfter,
      limit: limit,
    ).map((docs) {
      return docs.map((doc) {
        final data = doc.data();
        data['matchId'] = doc.id;
        return MatchModel.fromJson(data);
      }).toList();
    });
  }

  /// 매칭 상세 조회
  Future<MatchModel?> getMatch(String matchId) async {
    final data = await _source.getMatch(matchId);
    if (data == null) return null;

    return MatchModel.fromJson({
      ...data,
      'matchId': matchId,
    });
  }

  /// 매칭 상태 업데이트
  Future<void> updateMatchState(String matchId, MatchState state) async {
    await _source.updateMatch(matchId, {'state': state.name});
  }

  /// 매칭에 참가자 추가
  Future<void> addParticipant(String matchId, String userId) async {
    final match = await getMatch(matchId);
    if (match == null) {
      throw MatchException('매칭을 찾을 수 없습니다');
    }

    final users = List<String>.from(match.users);
    if (!users.contains(userId)) {
      users.add(userId);
      await _source.updateMatch(matchId, {'users': users});
    }
  }

  /// 매칭에 대기자 추가
  Future<void> addWaitlist(String matchId, String userId) async {
    final match = await getMatch(matchId);
    if (match == null) {
      throw MatchException('매칭을 찾을 수 없습니다');
    }

    final waitlist = List<String>.from(match.waitlist);
    if (!waitlist.contains(userId)) {
      waitlist.add(userId);
      await _source.updateMatch(matchId, {'waitlist': waitlist});
    }
  }

  /// 대기자 승격 (첫 번째 대기자를 참가자로)
  Future<void> promoteWaitlist(String matchId) async {
    final match = await getMatch(matchId);
    if (match == null) {
      throw MatchException('매칭을 찾을 수 없습니다');
    }

    if (match.waitlist.isEmpty) return;

    final waitlist = List<String>.from(match.waitlist);
    final users = List<String>.from(match.users);
    final promoted = waitlist.removeAt(0);
    users.add(promoted);

    await _source.updateMatch(matchId, {
      'users': users,
      'waitlist': waitlist,
    });
  }
}

/// MatchRepository 프로바이더
final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(
    FirestoreSource(FirebaseFirestore.instance),
    FirebaseAuth.instance,
    const Uuid(),
  );
});

