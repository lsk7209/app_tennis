# 🎾 Tennis Friends 개발 상태

## ✅ 완료된 기능

### 1. 데이터 레이어
- [x] Firestore 소스 구현
- [x] User, Match, Request, Chat 리포지토리
- [x] Review 리포지토리 (내부 저장)
- [x] 트랜잭션 및 배치 처리

### 2. 인증
- [x] 카카오 로그인 서비스
- [x] 전화번호 인증 서비스
- [x] 인증 화면
- [x] 전화번호 인증 화면
- [x] Splash 화면 및 인증 상태 체크

### 3. 온보딩
- [x] 닉네임, 지역(집/직장), NTRP 입력
- [x] 폼 검증
- [x] 데이터 저장

### 4. 매칭
- [x] 매칭 등록 화면
- [x] 홈 화면 (추천 매칭)
- [x] 매칭 리스트 화면 (필터 + 탐색)
- [x] 매칭 상세 화면
- [x] 신청/취소 로직
- [x] 호스트 승인/거절 UI
- [x] Fallback 매칭 알고리즘 (3단계)
- [x] 참가자 목록 표시
- [x] 매칭 완료 처리

### 5. 채팅
- [x] 그룹 채팅 UI
- [x] 실시간 메시지 전송/수신
- [x] 이미지 업로드 (2MB 제한)
- [x] 매칭 확정 시 채팅 자동 생성

### 6. 프로필
- [x] 프로필 정보 표시
- [x] 신청 내역 조회
- [x] 매칭 이력 조회
- [x] 통계 표시 (매칭 수, 완료율, 리뷰율)
- [x] 알림 설정 화면
- [x] 로그아웃

### 7. 기타
- [x] FCM 알림 서비스
- [x] 딥링크 핸들러
- [x] 하단 네비게이션 바
- [x] 에러 처리 위젯
- [x] 로딩 위젯
- [x] 유효성 검사 유틸리티

## 📋 다음 단계

### 필수 작업
1. **코드 생성**
   ```bash
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Firebase 설정**
   - Firebase 프로젝트 생성
   - `firebase_options.dart` 파일 추가
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
   - Firestore Security Rules 설정
   - Cloud Functions 배포

3. **카카오 SDK 설정**
   - 카카오 개발자 앱 등록
   - 네이티브 앱 키 설정

### 개선 사항
- [ ] 채팅 목록 화면 추가
- [ ] 매칭 상세 화면에서 사용자 프로필 조회
- [ ] 이미지 선택 다이얼로그 (갤러리/카메라)
- [ ] Pull-to-refresh 개선
- [ ] 오프라인 지원 (Firestore 캐시)
- [ ] 성능 최적화

## 📁 프로젝트 구조

```
lib/
├── app/                    # 앱 설정
│   ├── app.dart           # 메인 앱 위젯
│   ├── router.dart        # 라우팅
│   ├── theme.dart         # 테마
│   ├── di.dart            # 의존성 주입
│   ├── splash_screen.dart # 스플래시
│   └── firebase_messaging.dart
├── core/                  # 공통
│   ├── constants/         # 상수
│   ├── errors/            # 에러 클래스
│   ├── utils/             # 유틸리티
│   └── services/          # 서비스 (FCM)
├── data/                  # 데이터 레이어
│   ├── models/            # Freezed 모델
│   ├── sources/           # Firestore 소스
│   └── repositories/      # 리포지토리
├── features/              # 기능별 모듈
│   ├── auth/              # 인증
│   ├── onboarding/        # 온보딩
│   ├── match/             # 매칭
│   ├── chat/              # 채팅
│   └── profile/           # 프로필
└── widgets/               # 공통 위젯
```

## 🔧 주요 기술 스택

- **Flutter** 3.0+
- **Riverpod** (상태 관리)
- **go_router** (라우팅)
- **Firebase** (Auth, Firestore, Functions, FCM, Storage)
- **Freezed** (데이터 모델)
- **Kakao SDK** (로그인)

## 📝 참고사항

- 모든 모델은 Freezed로 생성되므로 `build_runner` 실행 필요
- Firebase 설정 파일은 프로젝트에 포함되지 않음 (보안)
- MVP에서는 리뷰 UI 비노출, 내부 저장만
- 매너온도는 내부 저장, UI 비노출

