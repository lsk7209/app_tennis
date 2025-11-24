# 🚀 Tennis Friends - 배포 가이드

## 📋 사전 준비사항

### 1. Firebase 프로젝트 설정
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 초기화
firebase init
```

### 2. Firebase 프로젝트 구성
- Firestore Database 생성
- Storage 활성화
- Authentication 활성화 (카카오, 전화번호)
- Cloud Messaging 활성화

---

## 🔒 Security Rules 배포

### Firestore Rules
```bash
# firestore.rules 파일 배포
firebase deploy --only firestore:rules
```

**주의사항**:
- 배포 전 Rules 테스트 권장
- Firebase Console에서 Rules 시뮬레이터 사용

### Storage Rules
```bash
# storage.rules 파일 배포
firebase deploy --only storage
```

---

## 📊 Firestore 인덱스 생성

### 필수 복합 인덱스

Firebase Console → Firestore Database → Indexes에서 다음 인덱스 생성:

#### 1. 매칭 목록 조회 인덱스
```
Collection: matches
Fields:
  - state (Ascending)
  - time.start (Ascending)
Query scope: Collection
```

#### 2. 지역별 매칭 조회 인덱스 (선택)
```
Collection: matches
Fields:
  - state (Ascending)
  - region (Ascending)
  - time.start (Ascending)
Query scope: Collection
```

**인덱스 생성 방법**:
1. Firebase Console 접속
2. Firestore Database → Indexes
3. "Create Index" 클릭
4. 위 필드 구성 입력
5. 생성 완료 대기 (몇 분 소요)

---

## 📱 앱 설정

### 1. firebase_options.dart 생성
```bash
# FlutterFire CLI 사용
flutter pub global activate flutterfire_cli
flutterfire configure
```

또는 Firebase Console에서:
1. 프로젝트 설정 → 일반
2. 앱 추가 (Android/iOS)
3. `google-services.json` (Android) 다운로드
4. `GoogleService-Info.plist` (iOS) 다운로드
5. `firebase_options.dart` 생성

### 2. Android 설정
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}

// android/build.gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

### 3. iOS 설정
```bash
# Podfile에 추가
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Messaging'
pod 'Firebase/Storage'
```

---

## 🔧 Cloud Functions 설정 (선택)

### 매칭 확정 시 채팅 자동 생성

```bash
# functions 폴더 생성
mkdir functions
cd functions
npm init -y
npm install firebase-functions firebase-admin
```

**functions/index.js**:
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onMatchMatched = functions.firestore
  .document('matches/{matchId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // 매칭이 matched 상태로 변경된 경우
    if (before.state !== 'matched' && after.state === 'matched') {
      const matchId = context.params.matchId;
      const hostId = after.hostId;
      const users = after.users || [];
      
      // 채팅 멤버 구성 (호스트 + 참가자)
      const members = [hostId, ...users].filter((v, i, a) => a.indexOf(v) === i);
      
      // 채팅 생성
      await admin.firestore()
        .collection('chats')
        .doc(matchId)
        .set({
          matchId: matchId,
          members: members,
          state: 'active',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      
      console.log(`Chat created for match ${matchId}`);
    }
    
    return null;
  });
```

**배포**:
```bash
firebase deploy --only functions
```

---

## ✅ 배포 전 체크리스트

### 필수 항목
- [ ] Firebase 프로젝트 생성 완료
- [ ] `firebase_options.dart` 파일 생성
- [ ] Firestore Security Rules 배포
- [ ] Storage Security Rules 배포
- [ ] Firestore 복합 인덱스 생성
- [ ] Android/iOS 앱 등록 완료
- [ ] 카카오 개발자 앱 등록 (카카오 로그인 사용 시)

### 권장 항목
- [ ] Cloud Functions 배포 (채팅 자동 생성)
- [ ] Firebase App Check 프로덕션 모드 설정
- [ ] 에러 로깅 (Crashlytics) 활성화
- [ ] 성능 모니터링 설정
- [ ] Analytics 설정

---

## 🧪 테스트

### 1. Security Rules 테스트
Firebase Console → Firestore Database → Rules → Rules Playground 사용

### 2. 기능 테스트
- [ ] 매칭 생성/조회
- [ ] 신청 생성/승인
- [ ] 채팅 메시지 전송
- [ ] 이미지 업로드
- [ ] 알림 수신

### 3. 성능 테스트
- [ ] 대량 데이터 조회 성능
- [ ] 이미지 업로드 속도
- [ ] 실시간 동기화 속도

---

## 📊 모니터링

### Firebase Console 확인 사항
1. **Firestore Usage**: 읽기/쓰기 횟수 모니터링
2. **Storage Usage**: 저장 용량 모니터링
3. **Functions Logs**: 에러 및 실행 시간 확인
4. **Crashlytics**: 크래시 리포트 확인

---

## 🔄 업데이트 배포

### 코드 변경 후
```bash
# Flutter 빌드
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Security Rules 변경 시
firebase deploy --only firestore:rules,storage
```

---

## 🆘 트러블슈팅

### 인덱스 오류
```
Error: The query requires an index
```
→ Firebase Console에서 제안된 인덱스 생성

### Security Rules 오류
```
Error: Missing or insufficient permissions
```
→ Rules Playground에서 테스트 후 수정

### 이미지 업로드 실패
```
Error: User does not have permission
```
→ Storage Rules 확인, 채팅 멤버 확인

---

**배포 준비 완료!** 🎉

