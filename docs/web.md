# Web 설정

Flutter Web 실행과 빌드가 활성화되어 있습니다. Firebase Console의 `hareup-mobile` 프로젝트에 Web 앱을 등록하고 설정을 전달해야 인증, Firestore, Storage, Functions를 사용할 수 있습니다.

## Firebase 설정

Firebase Console에서 프로젝트 설정 → 일반 → 앱 추가 → Web을 선택하고 앱을 등록합니다. Web 앱 설정에서 `apiKey`, `appId`, `authDomain`을 확인하세요. Firebase Authentication에서 Email/Password와 Google 제공자를 활성화하고, 운영 도메인을 승인된 도메인에 추가합니다. Google 로그인은 Firebase Auth 팝업을 사용합니다.

Web 설정은 컴파일 시 Dart define으로 전달합니다. API key는 Firebase 공개 클라이언트 설정이며 서버 비밀 키를 여기에 넣지 마세요.

```sh
fvm flutter run -d chrome \
  --dart-define=FIREBASE_WEB_API_KEY=<web-api-key> \
  --dart-define=FIREBASE_WEB_APP_ID=<web-app-id> \
  --dart-define=FIREBASE_WEB_AUTH_DOMAIN=hareup-mobile.firebaseapp.com
```

배포용 파일은 같은 define을 사용해 생성합니다.

```sh
fvm flutter build web --release \
  --dart-define=FIREBASE_WEB_API_KEY=<web-api-key> \
  --dart-define=FIREBASE_WEB_APP_ID=<web-app-id> \
  --dart-define=FIREBASE_WEB_AUTH_DOMAIN=hareup-mobile.firebaseapp.com
```

정적 파일은 `build/web`에 생성됩니다. `firebase.json`은 Firebase Hosting의 SPA 재작성 규칙을 포함하므로 빌드 후 `firebase deploy --only hosting`으로 배포할 수 있습니다. Web 설정이 빠진 개발 빌드는 안내 화면을 표시합니다.

## 지원 범위

Web에서는 이메일/비밀번호 및 Google 팝업 로그인을 지원합니다. 사진 선택과 Firebase 데이터 기능은 웹 플러그인으로 동작합니다. Apple과 Kakao 로그인은 모바일 전용입니다. FlutterFire 설정 생성이 필요한 경우 `flutterfire configure --project=hareup-mobile --platforms=web`을 실행해 웹 앱을 등록한 다음 `lib/firebase_options.dart`의 컴파일 설정과 동기화하세요.
