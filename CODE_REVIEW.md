# 🎾 Tennis Friends - 전체 코드베이스 검토 보고서

## 📋 개요

**프로젝트명**: Tennis Friends  
**언어**: Dart/Flutter  
**상태 관리**: Riverpod  
**백엔드**: Firebase (Auth, Firestore, FCM, Storage)  
**검토 일자**: 2024

---

## ✅ 강점 (Strengths)

### 1. 아키텍처
- ✅ **클린 아키텍처**: 레이어 분리가 명확함 (data, features, core, app)
- ✅ **의존성 주입**: Riverpod을 통한 DI 구현
- ✅ **관심사 분리**: Repository 패턴, Service 패턴 적절히 사용
- ✅ **모듈화**: Feature 기반 구조로 확장성 좋음

### 2. 코드 품질
- ✅ **타입 안정성**: Freezed 모델 사용으로 타입 안전성 확보
- ✅ **에러 처리**: 커스텀 예외 클래스로 명확한 에러 처리
- ✅ **상태 관리**: Riverpod StreamProvider 적절히 활용
- ✅ **비동기 처리**: AsyncValueWidget으로 로딩/에러 상태 처리

### 3. 기능 구현
- ✅ **Fallback 매칭 알고리즘**: 3단계 필터링 로직 구현
- ✅ **트랜잭션 처리**: Firestore 트랜잭션으로 데이터 일관성 보장
- ✅ **실시간 업데이트**: Stream 기반 실시간 데이터 동기화
- ✅ **FCM 통합**: 푸시 알림 기본 구조 구현

---

## ⚠️ 발견된 문제점 (Issues)

### 🔴 Critical (즉시 수정 필요)

#### 1. **매칭 생성 시 matchId 미사용 버그**
**위치**: `lib/data/repositories/match_repository.dart:33-50`

**문제**:
```dart
final matchId = _uuid.v4();  // matchId 생성
// ...
await _source.createMatch(json);  // 하지만 .add()로 새 ID 생성됨
```

**영향**: 생성한 matchId가 무시되고 Firestore가 자동 생성한 ID가 사용됨

**수정 방안**:
```dart
// FirestoreSource.createMatch 수정 필요
Future<String> createMatch(String matchId, Map<String, dynamic> data) async {
  await _firestore.collection('matches').doc(matchId).set(data);
  return matchId;
}
```

#### 2. **카카오 로그인 미완성**
**위치**: `lib/features/auth/services/kakao_auth_service.dart:30-33`

**문제**: Firebase 커스텀 토큰 생성 로직이 없어 로그인이 불가능

**영향**: 카카오 로그인 기능이 동작하지 않음

**수정 방안**:
- Cloud Functions에 커스텀 토큰 생성 함수 배포 필요
- 또는 Firebase Admin SDK를 사용한 서버리스 함수 구현

#### 3. **Firebase 초기화 오류 처리 부족**
**위치**: `lib/main.dart:20-26`

**문제**: Firebase 초기화 실패 시 앱이 계속 실행됨

**영향**: Firebase 기능이 동작하지 않는데도 앱이 실행되어 런타임 에러 발생

**수정 방안**: 초기화 실패 시 사용자에게 알림 및 대체 플로우 제공

---

### 🟡 Major (중요, 우선순위 높음)

#### 4. **매칭 목록 쿼리 최적화 부족**
**위치**: `lib/data/sources/firestore_source.dart:47-72`

**문제**:
- 복합 쿼리 인덱스 필요할 수 있음 (region + state + time.start)
- limit 기본값이 없어 모든 문서를 가져올 위험

**영향**: 대량 데이터 시 성능 저하 및 비용 증가

**수정 방안**:
```dart
query = query
  .where('state', isEqualTo: 'open')
  .orderBy('time.start')
  .limit(limit ?? 20);
```

#### 5. **채팅 메시지 역순 스크롤 버그**
**위치**: `lib/features/chat/chat_screen.dart:186-196`

**문제**:
```dart
final reversedMessages = messages.reversed.toList();
// ...
reverse: true,  // 이미 역순인데 또 역순 처리
```

**영향**: 메시지 순서가 잘못 표시될 수 있음

**수정 방안**: `reversed.toList()` 제거 또는 `reverse: false`로 변경

#### 6. **트랜잭션 외부에서 채팅 생성**
**위치**: `lib/data/repositories/request_repository.dart:164-197`

**문제**: 트랜잭션 완료 후 채팅 생성 실패 시 데이터 불일치 가능

**영향**: 매칭은 확정되었지만 채팅이 없는 상태 발생 가능

**수정 방안**: 
- Cloud Function으로 매칭 확정 이벤트 처리
- 또는 트랜잭션 내에서 채팅 문서도 함께 생성

#### 7. **FCM 포그라운드 알림 미구현**
**위치**: `lib/core/services/fcm_service.dart:43-47`

**문제**: 포그라운드에서 알림이 표시되지 않음

**영향**: 앱 사용 중 알림을 받지 못함

**수정 방안**: `flutter_local_notifications` 패키지 추가 및 구현

---

### 🟢 Minor (개선 권장)

#### 8. **에러 메시지 하드코딩**
여러 파일에서 에러 메시지가 하드코딩되어 있음

**개선**: 다국어 지원을 위한 localization 파일로 분리

#### 9. **매칭 필터링 로직 복잡도**
**위치**: `lib/core/utils/match_filter_utils.dart`

**문제**: Fallback 알고리즘이 복잡하고 테스트하기 어려움

**개선**: 각 단계를 별도 함수로 분리하고 단위 테스트 추가

#### 10. **상수 값 검증 부족**
**위치**: `lib/core/constants/app_constants.dart`

**문제**: 상수 값에 대한 검증 로직 없음 (예: maxPendingRequests)

**개선**: 상수 값 검증 및 문서화

#### 11. **이미지 업로드 크기 제한 UI 피드백 부족**
**위치**: `lib/features/chat/services/image_upload_service.dart`

**문제**: 2MB 초과 시 사용자에게 명확한 피드백 없음

**개선**: 업로드 전 크기 체크 및 사용자 알림

#### 12. **매칭 상세 화면에서 사용자 정보 조회 없음**
**위치**: `lib/features/match/screens/match_detail_screen.dart`

**문제**: 참가자 목록에 사용자 정보(닉네임, NTRP 등) 표시 안 함

**개선**: UserRepository를 통해 사용자 정보 조회 및 표시

---

## 🔒 보안 이슈 (Security)

### 1. **Firebase Security Rules 미설정**
- Firestore Security Rules 파일 없음
- 현재 모든 사용자가 모든 데이터에 접근 가능한 상태

**권장**: 
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /matches/{matchId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        resource.data.hostId == request.auth.uid;
    }
    // ... 기타 규칙
  }
}
```

### 2. **Firebase App Check 설정**
**위치**: `lib/app/di.dart:10-13`

**문제**: Debug 모드로만 설정되어 있음

**권장**: 프로덕션 빌드에서 Play Integrity/App Attest 사용

### 3. **이미지 업로드 검증 부족**
- 파일 타입 검증 없음
- 악성 파일 업로드 가능

**권장**: 파일 타입 및 확장자 검증 추가

---

## ⚡ 성능 개선 사항

### 1. **Firestore 쿼리 최적화**
- 복합 인덱스 생성 필요
- 페이지네이션 구현 (startAfter 사용)

### 2. **이미지 최적화**
- 이미지 리사이징 (업로드 전)
- 썸네일 생성

### 3. **캐싱 전략**
- Firestore 오프라인 캐시 활성화
- 사용자 정보 로컬 캐싱

### 4. **스트림 구독 관리**
- 일부 화면에서 스트림 구독 해제 로직 확인 필요

---

## 🧪 테스트 커버리지

### 현재 상태
- ❌ 단위 테스트 없음
- ❌ 위젯 테스트 없음
- ❌ 통합 테스트 없음

### 권장 테스트
1. **Repository 테스트**: Mock Firestore 사용
2. **유틸리티 테스트**: MatchFilterUtils 등
3. **위젯 테스트**: 주요 화면 위젯
4. **통합 테스트**: 인증 플로우, 매칭 생성 플로우

---

## 📝 문서화

### 현재 상태
- ✅ README.md 존재
- ✅ DEVELOPMENT_STATUS.md 존재
- ✅ 여러 가이드 문서 존재

### 개선 사항
- [ ] API 문서화 (주석 개선)
- [ ] 아키텍처 다이어그램
- [ ] 배포 가이드
- [ ] 트러블슈팅 가이드

---

## 🚀 다음 단계 우선순위

### Phase 1: Critical Fixes (즉시)
1. ✅ 매칭 생성 matchId 버그 수정
2. ✅ 카카오 로그인 구현 완료
3. ✅ Firebase 초기화 오류 처리 개선
4. ✅ 채팅 메시지 순서 버그 수정

### Phase 2: Security & Stability (1주 내)
1. ✅ Firestore Security Rules 설정
2. ✅ 이미지 업로드 검증 강화
3. ✅ 트랜잭션 외부 채팅 생성 문제 해결
4. ✅ FCM 포그라운드 알림 구현

### Phase 3: Performance & UX (2주 내)
1. ✅ Firestore 쿼리 최적화 및 인덱스 생성
2. ✅ 이미지 최적화 (리사이징)
3. ✅ 매칭 상세 화면 사용자 정보 표시
4. ✅ 오프라인 지원 (Firestore 캐시)

### Phase 4: Testing & Documentation (3주 내)
1. ✅ 핵심 기능 단위 테스트 작성
2. ✅ 위젯 테스트 작성
3. ✅ API 문서화
4. ✅ 배포 가이드 작성

---

## 📊 코드 메트릭

### 파일 구조
- 총 Dart 파일: ~50개
- 모델: 4개 (User, Match, Request, Chat)
- Repository: 5개
- 화면: ~10개
- 위젯: ~10개

### 의존성
- ✅ 최신 버전 사용 (Flutter 3.0+, Riverpod 2.4+)
- ⚠️ Firebase 패키지 `any` 버전 (버전 고정 권장)

### 코드 품질
- ✅ Linter 오류 없음
- ✅ 일관된 코딩 스타일
- ⚠️ 주석 부족 (복잡한 로직에 주석 필요)

---

## 💡 추가 제안사항

### 1. **상태 관리 개선**
- 일부 화면에서 `setState`와 Riverpod 혼용
- 모든 상태를 Riverpod으로 통일 권장

### 2. **에러 핸들링 통일**
- 모든 에러를 AppException으로 통일
- 에러 로깅 서비스 추가 (Firebase Crashlytics)

### 3. **로딩 상태 개선**
- 전역 로딩 인디케이터
- 스켈레톤 UI 적용

### 4. **접근성 (A11y)**
- Semantics 위젯 추가
- 스크린 리더 지원

### 5. **다크 모드**
- 테마에 다크 모드 추가

---

## ✅ 종합 평가

### 점수: 7.5/10

**강점**:
- 깔끔한 아키텍처
- 타입 안전성
- 실시간 기능 구현

**개선 필요**:
- Critical 버그 수정
- 보안 강화
- 테스트 추가
- 성능 최적화

**전체 평가**: 
프로젝트 구조와 기본 구현은 우수하나, 몇 가지 Critical 버그와 보안 이슈를 해결해야 프로덕션 배포가 가능합니다. 특히 매칭 생성 버그와 Firestore Security Rules 설정은 즉시 해결이 필요합니다.

---

## 📌 체크리스트

### 배포 전 필수
- [ ] 매칭 생성 matchId 버그 수정
- [ ] Firestore Security Rules 설정
- [ ] 카카오 로그인 완성
- [ ] Firebase 초기화 오류 처리
- [ ] 이미지 업로드 검증 강화
- [ ] FCM 포그라운드 알림 구현

### 배포 전 권장
- [ ] Firestore 인덱스 생성
- [ ] 이미지 최적화
- [ ] 오프라인 지원
- [ ] 에러 로깅 (Crashlytics)
- [ ] 성능 모니터링

### 배포 후
- [ ] 사용자 피드백 수집
- [ ] 성능 모니터링
- [ ] 에러 추적 및 수정
- [ ] A/B 테스트 준비

---

**검토 완료일**: 2024  
**검토자**: AI Code Reviewer

