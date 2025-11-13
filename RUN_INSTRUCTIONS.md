# 🎯 실행 가이드

## 현재 상태

✅ **코드 작성**: 완료
⏳ **Flutter 설치**: 필요
⏳ **코드 생성**: 필요 (build_runner)
⏳ **Firebase 설정**: 필요

## 실행 단계

### 1단계: Flutter 설치 확인

```bash
flutter doctor
```

모든 항목이 체크되어야 합니다.

### 2단계: 의존성 설치

```bash
flutter pub get
```

### 3단계: 코드 생성 (필수!)

Freezed와 JSON Serialization 파일 생성:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

이 명령어는 다음 파일들을 생성합니다:
- `lib/data/models/*.freezed.dart`
- `lib/data/models/*.g.dart`

### 4단계: Firebase 설정

#### 방법 1: FlutterFire CLI 사용 (권장)

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 프로젝트 설정
flutterfire configure
```

이 명령어가 `lib/firebase_options.dart` 파일을 자동 생성합니다.

#### 방법 2: 수동 설정

1. Firebase Console에서 프로젝트 생성
2. Android/iOS 앱 추가
3. `lib/firebase_options.dart` 파일 생성
4. `lib/main.dart`에서 import 주석 해제

### 5단계: 카카오 SDK 설정 (선택사항, 로그인 테스트용)

1. 카카오 개발자 콘솔 접속
2. 앱 등록 및 네이티브 앱 키 발급
3. Android/iOS 네이티브 설정 파일에 키 추가

### 6단계: 실행

```bash
# 에뮬레이터/시뮬레이터 실행 후
flutter run
```

## 문제 해결

### 오류: "part file not found"
→ `flutter pub run build_runner build --delete-conflicting-outputs` 실행 필요

### 오류: "firebase_options.dart not found"
→ `flutterfire configure` 실행 또는 수동으로 파일 생성

### 오류: "Flutter not found"
→ Flutter SDK 설치 및 PATH 설정 필요

## 개발 모드 팁

### Hot Reload
- `r`: Hot Reload
- `R`: Hot Restart
- `q`: 종료

### 디버그 모드
```bash
flutter run --debug
```

### 릴리즈 모드
```bash
flutter run --release
```

