# Developer Mode 활성화 - 단계별 가이드

## 🎯 목표
Windows에서 Flutter 앱을 실행하기 위해 Developer Mode 활성화

## 📋 정확한 단계

### 방법 1: Windows 설정 앱 (가장 확실)

1. **Windows 설정 열기**
   ```
   방법 A: Win + I 키 동시에 누르기
   방법 B: 시작 메뉴 > "설정" 검색 > 클릭
   방법 C: PowerShell에서: start ms-settings:
   ```

2. **개발자용 설정 찾기**
   - 설정 창 상단의 **검색창** 클릭
   - **"개발자"** 또는 **"developer"** 입력
   - 검색 결과에서 **"개발자용"** 또는 **"For developers"** 클릭

   또는:
   - 왼쪽 메뉴에서 **"개인 정보 보호 및 보안"** 클릭
   - 오른쪽에서 **"개발자용"** 찾아서 클릭

3. **개발자 모드 활성화**
   - 페이지에서 **"개발자 모드"** 또는 **"Developer Mode"** 찾기
   - 토글 스위치를 **오른쪽으로 밀어서 켜기** (ON)
   - 경고 창이 나오면 **"예"** 또는 **"Yes"** 클릭

4. **확인**
   - 토글이 **파란색**으로 바뀌고 **"켜짐"** 또는 **"On"** 표시되면 성공

5. **재부팅 (선택사항)**
   - 대부분 즉시 적용되지만, 안 되면 재부팅

6. **다시 실행**
   ```powershell
   flutter run -d windows
   ```

### 방법 2: 레지스트리 직접 수정 (고급 사용자)

⚠️ **주의**: 관리자 권한 필요

1. PowerShell을 **관리자 권한으로 실행**
   - 시작 메뉴 > PowerShell 검색
   - 우클릭 > **"관리자 권한으로 실행"**

2. 다음 명령어 실행:
   ```powershell
   New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force
   Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
   ```

3. 재부팅

4. 확인:
   ```powershell
   Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense"
   ```
   결과가 `1`이면 성공

## 🔍 문제 해결

### "개발자용" 메뉴를 찾을 수 없어요
- Windows 10/11 Pro 이상이 필요합니다
- Home 버전에서는 Developer Mode가 제한될 수 있습니다

### 토글을 켜도 여전히 에러가 나요
1. 재부팅 시도
2. PowerShell을 관리자 권한으로 실행 후 다시 시도
3. 레지스트리 방법 시도

### 여전히 안 되면?
- Android Studio 설치 후 에뮬레이터 사용 (Developer Mode 불필요)
- 또는 웹에서 실행 (Firebase 설정 필요)

## ✅ 확인 방법

Developer Mode가 활성화되었는지 확인:
```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
```

결과:
- `AllowDevelopmentWithoutDevLicense : 1` → ✅ 활성화됨
- `AllowDevelopmentWithoutDevLicense : 0` 또는 없음 → ❌ 비활성화됨

