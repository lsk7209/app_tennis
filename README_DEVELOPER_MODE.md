# Developer Mode 활성화 가이드

## 현재 문제
```
Error: Building with plugins requires symlink support.
```

## 해결 방법

### Windows 설정에서 활성화

1. **Win + I** 키를 눌러 설정 열기
2. 검색창에 **"개발자"** 입력
3. **"개발자 모드"** 토글을 **켜기**
4. 확인 클릭
5. 재부팅 (선택사항)
6. `flutter run -d windows` 다시 실행

### 확인 명령어

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense"
```

결과가 `1`이면 활성화됨

## 대안

### Android 에뮬레이터 사용
- Developer Mode 불필요
- Android Studio 설치 필요

### 웹에서 실행
- Firebase 설정 필요
- 현재 웹 패키지 호환성 문제 있음

## 참고 문서
- `STEP_BY_STEP_GUIDE.md` - 상세 단계별 가이드
- `QUICK_FIX.md` - 빠른 해결 방법

