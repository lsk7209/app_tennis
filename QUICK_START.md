# ⚡ 빠른 시작 가이드

## 실행 전 필수 체크리스트

- [ ] Flutter SDK 설치 완료 (`flutter doctor` 통과)
- [ ] Firebase 프로젝트 생성 및 `firebase_options.dart` 파일 추가
- [ ] 카카오 개발자 앱 등록 및 네이티브 키 설정
- [ ] 의존성 설치 (`flutter pub get`)
- [ ] 코드 생성 (`flutter pub run build_runner build --delete-conflicting-outputs`)

## 빠른 실행 명령어

```bash
# 1. 의존성 설치
flutter pub get

# 2. 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 3. 실행
flutter run
```

## 현재 상태

✅ **코드 작성 완료**: 모든 기능 구현 완료
⏳ **코드 생성 필요**: Freezed 및 JSON Serialization 파일 생성 필요
⏳ **Firebase 설정 필요**: `firebase_options.dart` 파일 추가 필요
⏳ **카카오 SDK 설정 필요**: 네이티브 앱 키 설정 필요

## 주의사항

1. **코드 생성 필수**: `.freezed.dart`와 `.g.dart` 파일이 없으면 컴파일 오류 발생
2. **Firebase 설정 필수**: `firebase_options.dart` 없이는 Firebase 초기화 실패
3. **에뮬레이터/디바이스 필요**: 실제 기기나 에뮬레이터에서 실행

