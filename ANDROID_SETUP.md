# Android Studio 설정 가이드

## 1. Android Studio 설치

### 다운로드 및 설치
1. **Android Studio 다운로드**
   - https://developer.android.com/studio
   - Windows용 설치 파일 다운로드

2. **설치**
   - 설치 파일 실행
   - 기본 설정으로 설치 진행
   - Android SDK 자동 설치됨

3. **초기 설정**
   - Android Studio 실행
   - Setup Wizard 따라하기
   - SDK 컴포넌트 자동 다운로드

## 2. Flutter Android 설정

### SDK 경로 확인
Android Studio 설치 후 SDK 경로는 보통:
```
C:\Users\<사용자명>\AppData\Local\Android\Sdk
```

### Flutter에 SDK 경로 설정
```powershell
flutter config --android-sdk "C:\Users\<사용자명>\AppData\Local\Android\Sdk"
```

또는 환경 변수 설정:
```powershell
$env:ANDROID_HOME = "C:\Users\<사용자명>\AppData\Local\Android\Sdk"
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $env:ANDROID_HOME, "User")
```

## 3. 에뮬레이터 생성

### 방법 1: Android Studio에서
1. Android Studio 실행
2. **Tools** > **Device Manager** 클릭
3. **Create Device** 클릭
4. 원하는 디바이스 선택 (예: Pixel 5)
5. 시스템 이미지 선택 (API 33 이상 권장)
6. **Finish** 클릭

### 방법 2: 명령어로
```powershell
# 사용 가능한 시스템 이미지 확인
flutter emulators --create

# 또는 직접 AVD 생성
# Android Studio의 AVD Manager 사용 권장
```

## 4. 에뮬레이터 실행

### 방법 1: Android Studio에서
1. Device Manager에서 생성한 에뮬레이터 선택
2. **Play** 버튼 클릭

### 방법 2: 명령어로
```powershell
# 사용 가능한 에뮬레이터 확인
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch <에뮬레이터_이름>

# 또는
emulator -avd <에뮬레이터_이름>
```

## 5. Flutter 앱 실행

에뮬레이터가 실행된 후:
```powershell
# 에뮬레이터 확인
flutter devices

# 앱 실행
flutter run

# 또는 특정 에뮬레이터 지정
flutter run -d <device_id>
```

## 문제 해결

### Android SDK를 찾을 수 없음
```powershell
flutter config --android-sdk "C:\Users\<사용자명>\AppData\Local\Android\Sdk"
```

### 라이선스 동의 필요
```powershell
flutter doctor --android-licenses
```

### 에뮬레이터가 보이지 않음
- Android Studio에서 에뮬레이터 생성 확인
- `flutter emulators` 명령어로 확인

## 참고

- 첫 실행 시 에뮬레이터 부팅에 시간이 걸릴 수 있습니다
- Android Studio는 최소 8GB RAM 권장
- 에뮬레이터는 최소 2GB RAM 할당 권장

