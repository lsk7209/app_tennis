# Android Studio 설정 - 다음 단계

## 현재 상태
- ✅ Android Studio 설치 완료
- ⏳ Android SDK 다운로드 필요

## 지금 해야 할 일

### 1. Android Studio 실행
- 시작 메뉴에서 "Android Studio" 검색
- 또는 `C:\Program Files\Android\Android Studio\bin\studio64.exe` 실행

### 2. Setup Wizard 완료
Android Studio를 처음 실행하면 Setup Wizard가 나타납니다:

1. **Welcome 화면**
   - "Next" 클릭

2. **Install Type 선택**
   - "Standard" 선택 (권장)
   - "Next" 클릭

3. **SDK Components 설치**
   - 자동으로 SDK 컴포넌트 다운로드 시작
   - **시간이 걸립니다 (10-30분)**
   - 완료될 때까지 대기

4. **License 동의**
   - 모든 라이선스에 "Accept" 클릭

5. **Finish**
   - "Finish" 클릭하여 완료

### 3. SDK 설치 확인
Android Studio가 열리면:
1. **Tools** > **SDK Manager** 클릭
2. **SDK Platforms** 탭에서 최신 Android 버전 확인
3. **SDK Tools** 탭에서 필요한 도구 확인

### 4. Flutter 설정
SDK 설치 완료 후 PowerShell에서:
```powershell
# SDK 경로 자동 찾기
.\find_android_sdk.ps1

# 또는 수동 설정 (SDK 경로를 알고 있다면)
flutter config --android-sdk "C:\Users\<사용자명>\AppData\Local\Android\Sdk"
```

### 5. 라이선스 동의
```powershell
flutter doctor --android-licenses
```
모든 라이선스에 `y` 입력

### 6. 에뮬레이터 생성
Android Studio에서:
1. **Tools** > **Device Manager** 클릭
2. **Create Device** 클릭
3. 디바이스 선택 (예: Pixel 5)
4. 시스템 이미지 선택 (API 33 이상 권장)
5. **Finish** 클릭

### 7. 앱 실행
에뮬레이터 실행 후:
```powershell
flutter run
```

## 문제 해결

### SDK를 찾을 수 없음
- Android Studio > Tools > SDK Manager에서 SDK 경로 확인
- 경로를 복사하여 `flutter config --android-sdk <경로>` 실행

### Setup Wizard가 나타나지 않음
- Android Studio가 이미 설정되어 있을 수 있습니다
- Tools > SDK Manager에서 SDK 설치 확인

### 다운로드가 느림
- 인터넷 연결 확인
- 방화벽 설정 확인
- Android Studio의 다운로드 진행 상황 확인

## 참고
- SDK 다운로드는 시간이 걸립니다 (10-30분)
- 인터넷 연결이 안정적이어야 합니다
- 최소 8GB RAM 권장

