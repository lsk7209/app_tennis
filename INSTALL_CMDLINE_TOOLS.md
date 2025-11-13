# Android cmdline-tools 설치 가이드

## 문제
```
Android sdkmanager not found.
cmdline-tools component is missing.
```

## 해결 방법

### 방법 1: Android Studio SDK Manager (권장)

1. **Android Studio 실행**

2. **SDK Manager 열기**
   - 메뉴: **Tools** > **SDK Manager**
   - 또는 상단 툴바의 SDK Manager 아이콘 클릭

3. **SDK Tools 탭 선택**
   - 상단 탭에서 **"SDK Tools"** 클릭

4. **cmdline-tools 설치**
   - 목록에서 **"Android SDK Command-line Tools (latest)"** 찾기
   - 체크박스 선택
   - **"Apply"** 클릭
   - **"OK"** 클릭하여 설치 시작

5. **설치 완료 대기**
   - 다운로드 및 설치 진행 (몇 분 소요)
   - 완료되면 "Finish" 클릭

### 방법 2: 수동 다운로드 (고급)

1. **다운로드**
   - https://developer.android.com/studio#command-line-tools-only
   - Windows용 zip 파일 다운로드

2. **압축 해제**
   - 다운로드한 zip 파일 압축 해제
   - 압축 해제된 폴더 이름을 `latest`로 변경

3. **설치 위치로 이동**
   ```
   C:\Users\<사용자명>\AppData\Local\Android\Sdk\cmdline-tools\latest
   ```
   - `cmdline-tools` 폴더가 없으면 생성
   - `latest` 폴더를 그 안에 배치

4. **구조 확인**
   ```
   C:\Users\<사용자명>\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat
   ```
   이 경로에 파일이 있어야 합니다.

## 설치 확인

설치 완료 후 PowerShell에서:
```powershell
# Flutter 상태 확인
flutter doctor

# 라이선스 동의
flutter doctor --android-licenses
```

모든 라이선스에 `y` 입력하여 동의

## 다음 단계

cmdline-tools 설치 및 라이선스 동의 완료 후:

1. **에뮬레이터 생성**
   - Android Studio > Tools > Device Manager
   - Create Device > 디바이스 선택 > 시스템 이미지 선택

2. **앱 실행**
   ```powershell
   flutter run
   ```

## 문제 해결

### SDK Manager가 보이지 않음
- Android Studio가 완전히 로드될 때까지 대기
- File > Settings > Appearance & Behavior > System Settings > Android SDK

### 설치가 느림
- 인터넷 연결 확인
- 방화벽 설정 확인
- Android Studio의 다운로드 진행 상황 확인

### 여전히 찾을 수 없음
- Android Studio 재시작
- Flutter 재시작: `flutter doctor -v`로 경로 확인

