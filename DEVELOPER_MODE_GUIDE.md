# Windows Developer Mode 활성화 가이드

## 문제
Flutter Windows 앱 실행 시 다음 에러 발생:
```
Error: Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

## 해결 방법

### 방법 1: 설정 앱에서 활성화 (가장 간단)

1. **Windows 설정 열기**
   - `Win + I` 키 누르기
   - 또는 시작 메뉴에서 "설정" 검색

2. **개발자용 설정 찾기**
   - 검색창에 "개발자" 또는 "developer" 입력
   - 또는 "개인 정보 보호 및 보안" > "개발자용" 선택

3. **개발자 모드 활성화**
   - "개발자 모드" 또는 "Developer Mode" 토글을 **켜기**
   - 확인 대화상자에서 "예" 클릭

4. **재부팅 (필요한 경우)**
   - 일부 시스템에서는 재부팅이 필요할 수 있습니다

5. **다시 실행**
   ```powershell
   flutter run -d windows
   ```

### 방법 2: PowerShell로 활성화 (관리자 권한 필요)

1. **PowerShell을 관리자 권한으로 실행**
   - 시작 메뉴에서 "PowerShell" 검색
   - 우클릭 > "관리자 권한으로 실행"

2. **스크립트 실행**
   ```powershell
   cd D:\cursorai\apps\1_tennis_app
   .\fix_symlink_issue.ps1
   ```

3. **또는 직접 레지스트리 수정**
   ```powershell
   New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force
   Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
   ```

### 방법 3: Android 에뮬레이터 사용 (Developer Mode 불필요)

Android Studio를 설치하고 에뮬레이터에서 실행:
```powershell
flutter run
```

## 확인 방법

Developer Mode가 활성화되었는지 확인:
```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense"
```

값이 `1`이면 활성화됨, `0`이거나 없으면 비활성화됨

## 참고

- Developer Mode는 Windows 10/11에서 개발 도구 사용을 위한 기능입니다
- symlink(심볼릭 링크) 생성 권한을 제공합니다
- 보안상의 이유로 기본적으로 비활성화되어 있습니다

