# Web 설정

Flutter Web 실행과 빌드가 활성화되어 있습니다. 모바일 코드베이스는 웹과 호환되도록
구성되어 있으며, 아래 운영 설정만 마치면 웹 앱으로 동작합니다.

## 사전 요구사항

```sh
fvm install
fvm flutter pub get
fvm flutter devices  # chrome이 목록에 있어야 합니다
```

`.fvmrc`에 지정된 Flutter 버전을 사용합니다.

## 1. Firebase Web 앱 등록

Firebase Console에서 프로젝트 설정 → 일반 → 앱 추가 → Web을 선택하고 앱을
등록합니다. Web 앱 설정에서 `apiKey`, `appId`, `authDomain`을 확인하세요.

Firebase Authentication에서 Email/Password와 Google 제공자를 활성화하고, 운영
도메인(`hareup-mobile.web.app`, `hareup-mobile.firebaseapp.com`, 커스텀 도메인)을
승인된 도메인에 추가합니다. Google 로그인은 Firebase Auth 팝업을 사용하므로 별도
OAuth 클라이언트 설정이 필요 없습니다.

## 2. Storage CORS 적용

웹에서는 사진 업로드·다운로드(`putData`/`getData`)가 브라우저에서 직접 Storage로
요청되므로 버킷에 CORS 설정이 필요합니다. 설정하지 않으면 사진 조회가 실패합니다.

```sh
gcloud storage buckets update gs://hareup-mobile.firebasestorage.app \
  --cors-file=firebase/storage.cors.json
```

`gsutil`을 사용하는 경우 `gsutil cors set firebase/storage.cors.json
gs://hareup-mobile.firebasestorage.app`를 실행하세요. 커스텀 도메인을 쓰면
`firebase/storage.cors.json`의 `origin`에 해당 도메인을 추가한 뒤 다시 적용합니다.
로컬 Chrome 실행은 고정 포트를 사용하면 같은 CORS 설정으로 테스트할 수 있습니다.

```sh
fvm flutter run -d chrome --web-port 8080 \
  --dart-define=FIREBASE_WEB_API_KEY=<web-api-key> \
  --dart-define=FIREBASE_WEB_APP_ID=<web-app-id>
```

## 3. 실행·빌드·배포

Web 설정은 컴파일 시 Dart define으로 전달합니다. API key는 Firebase 공개
클라이언트 설정이며 서버 비밀 키를 여기에 넣지 마세요.

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

정적 파일은 `build/web`에 생성됩니다. `firebase.json`은 Firebase Hosting의 SPA
재작성 규칙을 포함하므로 빌드 후 `firebase deploy --only hosting`으로 배포할 수
있습니다. Web 설정이 빠진 개발 빌드는 안내 화면을 표시합니다.

## 지원 범위

Web에서는 이메일/비밀번호 및 Google 팝업 로그인을 지원합니다. Apple과 Kakao
로그인은 모바일 전용이라 웹 로그인 화면에 나타나지 않습니다. 사진 선택은 파일
선택 대화상자로 동작하며, 촬영 버튼도 같은 대화상자를 엽니다. 기록 공유는 Web
Share API를 사용하고, 지원하지 않는 데스크톱 브라우저에서는 공유 문구를
클립보드에 복사합니다. FlutterFire 설정 생성이 필요한 경우
`flutterfire configure --project=hareup-mobile --platforms=web`을 실행해 웹 앱을
등록한 다음 `lib/firebase_options.dart`의 컴파일 설정과 동기화하세요.
