# 인증 아키텍처

- 요구사항: AUTH-01. 책임: 로그인·세션 복원 및 로그아웃.
- 현재 상태: Firebase 이메일/비밀번호 가입·로그인, 세션 복원, 로그아웃 계약과 화면을 연결했다. 첫 개발 인증 방식은 운영 소셜 로그인 정책이 확정되기 전까지 이메일/비밀번호로 정했다.

## 흐름과 계층

화면은 사용자 입력을 BLoC/Cubit에 전달하고 로딩·성공·빈 상태·실패를 렌더링한다. 일회성 이동과 메시지는 지속 상태와 분리한다. Domain은 엔티티·유스케이스·저장소 계약을 소유하고, data는 DTO·데이터 소스·저장소 구현을 제공한다. 앱 조립 계층이 구현을 주입한다.

## 데이터와 연동

- 의존성: Firebase Authentication 이메일/비밀번호 공급자. Firebase Console에서 Email/Password 공급자를 활성화해야 한다.
- 가입 후 Firebase UID 세션이 확인되면 인증된 앱으로 이동한다. 가족 초대 코드 입력은 가입 이후 가족 기능에서 처리하며, 코드를 입력한 것만으로 접근 권한을 주지 않는다. 가족 관리자의 승인으로 구성원 권한을 확정한다.
- JSON은 data 경계에서 DTO로 검증하고 도메인 모델로 변환한다. 공통 오류는 실패 타입으로 변환한다.
- 공유 데이터와 사진은 가족 그룹을 기준으로 분리하며 실제 서버에서 권한을 검증한다.
- 테스트에는 가짜 저장소와 고정 상태를 사용한다. 네트워크·플랫폼 플러그인을 Preview에서 호출하지 않는다.

## 검증 및 결정 대기

- 정상·빈 상태·실패·재시도와 권한 거부를 테스트한다. 입력·삭제·중복·그룹 격리는 해당 기능 구현 시 추가한다.
- 운영 배포 전 확정: 이메일 인증 요구 여부, 비밀번호 재설정, 소셜 로그인 여부, 약관 동의 및 계정 삭제 정책.
- 설계 변경 시 PRD 요구사항과 상태·인터페이스·테스트를 함께 갱신한다.

## 기능별 설계 상세

- 화면 흐름: 가입 또는 로그인 → Firebase 세션 복원 → 홈; 실패 메시지를 표시하고 다시 시도한다.
- 상태·계약: AuthCubit은 세션 스트림, 이메일/비밀번호 가입·로그인, 로그아웃, 재구독 및 실패를 관리한다. FirebaseAuthRepository는 Firebase Authentication 호출과 오류 변환을 담당한다. AuthGate는 사용자 ID를 키로 화면 하위 상태를 분리한다.
- 필수 테스트: 취소·실패·만료와 계정 전환 시 캐시 격리.
- 운영 통합 시에는 인증 사용자별 저장소·캐시·내비게이션 스택을 분리하고 로그아웃 또는 계정 전환 때 폐기한다. Firebase 설정은 `lib/firebase_options.dart`에서 생성하며 앱 진입 시 초기화한다. Widget Preview와 인증 어댑터가 주입되지 않은 개발 harness에서는 unavailable 어댑터를 사용한다.

## Apple 로그인 설정

- 의존성: `sign_in_with_apple: ^8.2.0`, `crypto: ^3.0.6`. Apple 어댑터는 매 로그인마다 안전한 nonce를 만들고 SHA-256 해시를 Apple에 전달한 뒤, 원본 nonce와 ID 토큰으로 Firebase 자격 증명을 생성한다. 취소는 `FederatedSignInCancelled`로 전달한다. 토큰이나 인증 코드를 로그로 남기지 않는다.
- Firebase Console → Authentication → Sign-in method에서 Apple 공급자를 활성화하고 Apple Developer의 Team ID, Key ID, `.p8` 키를 등록한다. Firebase 화면의 callback URL을 기록한다.
- Apple Developer → Certificates, Identifiers & Profiles에서 App ID `com.overcomplex.hareup.mobile`에 Sign in with Apple을 활성화한다. Xcode의 Runner 타깃에도 같은 capability를 추가하고, 서명용 provisioning profile을 다시 생성한다.
- Android 로그인은 Apple Services ID와 Firebase callback URL을 요구한다. Services ID를 Apple의 Sign in with Apple 설정에 연결하고 Firebase callback URL을 Return URL로 등록한다. 실행 시 `--dart-define=APPLE_SERVICE_ID=<Services-ID>`로 Services ID를 전달한다. 리디렉션 도메인은 `lib/firebase_options.dart`의 Firebase Auth domain을 사용한다.
- Apple은 이름과 이메일을 최초 승인에서만 제공할 수 있으므로 받은 값을 첫 로그인에서 저장한다. 앱 로그아웃은 Apple 계정 연결을 해제하지 않으며 Firebase 세션은 저장소가 종료한다.

## Kakao 로그인 설정

- 어댑터: `KakaoAuthProvider`가 Kakao Flutter SDK로 로그인을 수행하고 ID token을 `oidc.kakao` Firebase 자격 증명으로 교환한다. 매 로그인마다 임의 nonce를 만들고 SHA-256 해시를 Kakao에 전달한 뒤 원본 nonce를 Firebase credential에 전달한다. Kakao SDK의 사용자 취소(`CANCELED`/`CANCELLED`)는 `FederatedSignInCancelled`로 전달하며 토큰을 로그에 남기지 않는다.
- 의존성: `kakao_flutter_sdk_user: ^2.1.0` (Dart 3.9+, Flutter 3.38+). 앱 시작 시 Firebase 초기화와 함께 `KakaoSdk.init(nativeAppKey: ...)`를 한 번 호출한다. Native App Key는 공개 클라이언트 키이며 REST/Admin 키나 Client Secret을 앱에 넣지 않는다.
- Kakao Developers에서 앱을 만들고 Android 패키지명 및 디버그/릴리스 키 해시, iOS 번들 ID와 URL scheme을 등록한다. Kakao Login과 OpenID Connect를 활성화하고 로그인 동의 항목을 설정한다. Flutter SDK는 KakaoTalk 로그인이 가능하면 사용하고, 불가능하면 Kakao Account 로그인을 제공한다.
- Firebase Authentication 프로젝트를 Identity Platform으로 업그레이드하고 OIDC 제공자 ID `oidc.kakao`를 등록한다. Issuer는 `https://kauth.kakao.com`이다. SDK 로그인 ID token의 `aud`는 초기화에 쓴 Native App Key이므로 Firebase OIDC Client ID도 그 값과 일치시킨다. Kakao ID token 직접 전달 자격 증명을 사용하며, 서버 authorization-code flow를 채택할 경우 REST API 키와 Client Secret을 서버 Secret Manager에만 저장하고 Firebase가 요구하는 callback URI를 Kakao에 등록한다.
- 설정 참고: [Kakao Flutter 로그인](https://developers.kakao.com/docs/en/kakaologin/flutter), [Kakao OIDC 설정](https://developers.kakao.com/docs/en/kakaologin/prerequisite), [Kakao ID token의 aud](https://developers.kakao.com/docs/en/kakaologin/rest-api), [Firebase OIDC](https://firebase.google.com/docs/auth/android/openid-connect). Kakao 앱 키와 Firebase OIDC Client ID의 일치 여부, 프로덕션 키 해시, 실제 기기 로그인을 콘솔 설정 후 확인한다.

## Google 로그인 설정

- 앱 어댑터는 `GoogleAuthProviderAdapter`이며 `google_sign_in: ^7.2.0`을 사용한다. 로그인 시 `GoogleSignIn.instance.initialize()`를 한 번 기다린 뒤 `authenticate()`로 ID token을 받아 Firebase `signInWithCredential`에 전달한다. Google OAuth 취소는 `FederatedSignInCancelled`로 분리한다. Google 및 Firebase 토큰은 로그에 남기지 않는다.
- Firebase Console에서 Authentication의 Google 공급자를 활성화하고 프로젝트 지원 이메일을 지정한다. Android 앱 등록의 패키지 ID가 `com.overcomplex.hareup.mobile`과 일치하는지 확인하고, 개발·배포 키스토어 및 Play App Signing의 SHA-1/SHA-256 지문을 등록한 뒤 최신 `google-services.json`을 Android 앱 설정에 반영한다. 파일에 `client_type: 3` 웹 OAuth 클라이언트가 있어야 한다.
- iOS 앱 등록의 Bundle ID가 `com.overcomplex.hareup.mobile`과 일치해야 한다. Google 공급자를 활성화한 뒤 최신 `GoogleService-Info.plist`를 내려받아 `ios/Runner` 타깃에 추가한다. `ios/Runner/Info.plist`에는 plist의 `CLIENT_ID`를 `GIDClientID`로, `REVERSED_CLIENT_ID`를 `CFBundleURLTypes`의 URL scheme으로 등록한다. Xcode에서 해당 plist가 Runner 타깃에 포함됐는지 확인한다.
- 이 저장소에서는 패키지 및 앱 코드를 준비한다. OAuth 클라이언트·Firebase 공급자 설정·서명 지문 등록·네이티브 설정 파일 교체는 운영자가 Firebase/Google Console과 Xcode에서 직접 완료해야 한다. 공식 참고: [Firebase federated auth](https://firebase.google.com/docs/auth/flutter/federated-auth), [`google_sign_in`](https://pub.dev/packages/google_sign_in), [Android integration](https://pub.dev/packages/google_sign_in_android), [iOS integration](https://pub.dev/packages/google_sign_in_ios).
