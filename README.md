# 🎾 Tennis Friends

근거리·시간대 기반의 신뢰 중심 테니스 매칭 앱

## 프로젝트 구조

```
lib/
  app/          # 앱 설정 (라우팅, 테마, DI)
  core/         # 공통 유틸리티, 상수, 에러
  data/         # 데이터 레이어 (모델, 소스, 리포지토리)
  features/     # 기능별 모듈
    auth/       # 인증
    onboarding/ # 온보딩
    match/      # 매칭
    chat/       # 채팅
    profile/    # 프로필
  widgets/      # 공통 위젯
```

## 기술 스택

- **Flutter** 3.0+
- **Firebase** (Auth, Firestore, Functions, FCM)
- **Riverpod** (상태 관리)
- **go_router** (라우팅)
- **freezed** (데이터 모델)

## 개발 환경 설정

1. Flutter SDK 설치
2. 의존성 설치:
   ```bash
   flutter pub get
   ```
3. 코드 생성:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Firebase 프로젝트 설정 및 `firebase_options.dart` 추가

## 실행

```bash
flutter run
```

## PRD

자세한 요구사항은 `scripts/prd.txt`를 참고하세요.

# app_tennis
