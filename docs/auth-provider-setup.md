# 로그인 제공자 설정

앱 코드는 Firebase Authentication을 공통 세션으로 사용합니다. 아래 콘솔 설정은 프로젝트 소유자가 직접 적용한 뒤 실제 기기에서 확인해 주세요. 비밀 키, 서비스 계정 파일, OAuth client secret은 Dart 코드나 Git에 넣지 마세요.

## 공통 준비

1. Firebase Console에서 Authentication을 활성화하고 Email/Password, Google, Apple 제공자를 켭니다. Apple은 Firebase의 Apple 공급자 설정에 Team ID, Key ID, private key를 등록합니다.
2. Firebase 앱의 Android application ID와 iOS Bundle ID는 모두 `com.overcomplex.hareup.mobile`이어야 합니다.
3. 제공자 콘솔의 OAuth client 설정에 현재 Firebase 프로젝트와 정확히 일치하는 앱 식별자 및 리디렉션 정보를 등록합니다. 설정 파일을 교체하면 Android/iOS 앱 타깃에 포함됐는지 확인합니다.

## Google

- Firebase Authentication에서 Google 로그인과 지원 이메일을 설정합니다.
- Google Cloud/Firebase Android 앱에 개발 및 배포 서명 인증서의 SHA-1/SHA-256을 등록합니다. Play 배포는 Play App Signing 지문도 추가합니다. 갱신한 `google-services.json`에 웹 OAuth client가 포함됐는지 확인합니다.
- iOS의 `GoogleService-Info.plist`를 최신 파일로 교체하고 Runner 타깃에 포함합니다. `CLIENT_ID`를 `GIDClientID`, `REVERSED_CLIENT_ID`를 URL scheme으로 등록합니다.

## Apple

- Apple Developer에서 App ID에 Sign in with Apple capability를 활성화하고, Xcode Runner와 provisioning profile에도 적용합니다.
- Firebase Apple 공급자에 Team ID, Key ID, `.p8` private key를 등록합니다. Apple이 최초 승인 때만 이름을 반환할 수 있습니다.
- Android 로그인을 제공하려면 Apple Services ID를 만들고 Firebase callback URL을 Return URL로 등록합니다. 실행할 때 Services ID를 전달합니다.

```sh
fvm flutter run --dart-define=APPLE_SERVICE_ID=com.example.hareup.signin
```

## Kakao

- Kakao Developers에서 앱을 만들고 Android package `com.overcomplex.hareup.mobile`, 디버그/릴리스 키 해시, iOS bundle ID `com.overcomplex.hareup.mobile`을 등록합니다. Kakao Login과 OpenID Connect를 활성화하고 필요한 동의 항목을 설정합니다.
- Firebase의 Kakao OIDC 연동에는 Identity Platform이 필요합니다. 제공자 ID는 `oidc.kakao`, issuer는 `https://kauth.kakao.com`으로 설정합니다. 앱 SDK가 반환하는 ID token의 audience가 Kakao Native App Key이므로 Firebase OIDC Client ID도 그 값과 맞춰야 합니다. Client secret은 Firebase Console에만 입력합니다.
- Android에서 `android/local.properties`에 `kakao.nativeAppKey=<Native-App-Key>`를 추가합니다. 이 파일은 로컬 전용이며 커밋하지 마세요. 빌드 설정이 Android 로그인 callback scheme을 구성합니다.
- iOS Runner target의 Build Settings에 `KAKAO_NATIVE_APP_KEY` 사용자 정의 설정을 추가하고 같은 Native App Key를 지정합니다. `Info.plist`가 이를 Kakao callback URL scheme에 사용합니다.
- Native App Key는 공개 클라이언트 키입니다. Dart 앱 초기화에도 전달해야 Kakao 로그인 버튼이 표시됩니다.

```sh
fvm flutter run --dart-define=KAKAO_NATIVE_APP_KEY=<Kakao-Native-App-Key>
```

Kakao Developers의 앱 설정에서 Android package/key hash와 iOS bundle ID를 등록하고, 카카오톡 미설치 시 계정 로그인도 확인하세요.

## 패키지 및 앱 코드

`google_sign_in`, `sign_in_with_apple`, `kakao_flutter_sdk_user` 어댑터는 OAuth 자격 증명을 Firebase Auth로 교환합니다. Google·Apple 버튼은 앱에서 준비되며 Kakao 버튼은 Native App Key를 전달했을 때 표시됩니다. 로그아웃은 제공자 세션 정리를 시도한 후 Firebase 세션을 종료합니다. 패키지를 갱신한 뒤 `fvm flutter pub get`을 실행하세요.

로그인 취소는 오류와 별도로 처리합니다. 제공자가 Firebase Console에서 활성화되지 않았거나 native 설정이 누락되면 인증 오류가 표시됩니다. 각 플랫폼에서 신규 가입, 기존 계정 로그인, 취소, 로그아웃을 확인한 뒤 사용을 시작하세요.
