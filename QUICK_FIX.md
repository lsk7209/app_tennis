# 빠른 해결 방법

## ⚠️ 현재 문제
```
Error: Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

## ✅ 해결 방법 (3단계)

### 1단계: Windows 설정 열기
- `Win + I` 키를 누르세요
- 또는 시작 메뉴에서 "설정" 검색

### 2단계: 개발자 모드 찾기
설정 창에서:
- 검색창에 **"개발자"** 또는 **"developer"** 입력
- 또는 왼쪽 메뉴에서 **"개인 정보 보호 및 보안"** > **"개발자용"** 클릭

### 3단계: 개발자 모드 켜기
- **"개발자 모드"** 또는 **"Developer Mode"** 토글을 **ON**으로 변경
- 경고 메시지가 나오면 **"예"** 클릭

### 4단계: 재부팅 (선택사항)
- 일부 시스템에서는 재부팅이 필요할 수 있습니다
- 재부팅하지 않고 바로 시도해도 됩니다

### 5단계: 다시 실행
```powershell
flutter run -d windows
```

## 🔄 대안: Android 에뮬레이터 사용

Developer Mode 없이 Android 에뮬레이터에서 실행:

1. Android Studio 설치
   - https://developer.android.com/studio

2. Android Studio에서 에뮬레이터 생성
   - Tools > Device Manager > Create Device

3. 에뮬레이터 실행 후:
   ```powershell
   flutter run
   ```

## 📝 확인 방법

Developer Mode가 활성화되었는지 확인:
```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense"
```

결과가 `1`이면 활성화됨, `0`이거나 없으면 비활성화됨

