# 🚀 Tennis Friends 실행 가이드

## 필수 사전 준비

### 1. Flutter 설치
1. Flutter SDK 다운로드: https://flutter.dev/docs/get-started/install
2. 환경 변수 설정 (PATH에 Flutter bin 디렉토리 추가)
3. 설치 확인:
   ```bash
   flutter doctor
   ```

### 2. Firebase 프로젝트 설정
1. Firebase Console에서 프로젝트 생성
2. Flutter 앱 추가 (Android/iOS)
3. `firebase_options.dart` 파일 생성:
   ```bash
   flutterfire configure
   ```
4. 생성된 파일을 `lib/` 디렉토리에 배치

### 3. 카카오 SDK 설정
1. 카카오 개발자 콘솔에서 앱 등록
2. 네이티브 앱 키 발급
3. Android: `android/app/src/main/AndroidManifest.xml`에 키 추가
4. iOS: `ios/Runner/Info.plist`에 키 추가

## 실행 단계

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 코드 생성 (Freezed, JSON Serialization)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 실행
```bash
# Android
flutter run

# iOS (macOS만)
flutter run -d ios

# 특정 디바이스
flutter devices
flutter run -d <device-id>
```

## 문제 해결

### 코드 생성 오류
- `part` 파일이 없다는 오류가 나면 `build_runner` 실행 필요
- 캐시 문제 시: `flutter clean && flutter pub get`

### Firebase 오류
- `firebase_options.dart` 파일이 없으면 `flutterfire configure` 실행
- Firebase 프로젝트가 제대로 연결되었는지 확인

### 카카오 로그인 오류
- 네이티브 앱 키가 올바르게 설정되었는지 확인
- Android/iOS 네이티브 설정 확인

## 개발 모드 실행 (에뮬레이터/시뮬레이터)

### Android 에뮬레이터
```bash
# 에뮬레이터 목록
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch <emulator-id>

# 앱 실행
flutter run
```

### iOS 시뮬레이터 (macOS만)
```bash
# 시뮬레이터 실행
open -a Simulator

# 앱 실행
flutter run
```

