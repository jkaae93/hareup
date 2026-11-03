# 하릅 (Hareup)

Flutter 기반 Android / iOS / Web 반려동물 관찰 앱. 제품 요구사항은 [PRD](docs/PRD.md)를 참고하세요.

## 현재 구현 상태

Feature-first 구조, Pub workspace 공통 패키지, 이메일·비밀번호 인증, 가족 생성·초대·관리자 승인, 그룹별 Firestore/Storage 저장소를 구현했습니다. 반려동물·물그릇·화장실·분석 기록은 선택한 승인 그룹에 영구 저장됩니다. Meta Model API 사진 분석 callable도 구현했지만 함수 배포와 실제 API 검증은 남아 있고, 정확도 검증 전까지 분석 값 표시 게이트는 비활성화되어 있습니다. 설정 화면의 기기 기능과 실제 건강 안내 검토도 남은 작업입니다.

각 기능 설계는 `lib/features/<feature>/ARCHITECTURE.md`를 참고하세요. 설계 문서 중 구현되지 않은 내용은 목표 구조입니다.

## 개발

```sh
fvm install
fvm flutter pub get
fvm flutter run
fvm dart run build_runner build
fvm flutter analyze
fvm flutter test
```

FVM으로 `.fvmrc`에 지정된 Flutter 안정 버전을 사용합니다. FVM 설치 후 `fvm install`을 실행하세요. Widget Preview는 `fvm flutter widget-preview start`로 실행합니다. Preview에는 실 Firebase나 플랫폼 서비스를 연결하지 않습니다.

## Firebase 및 외부 서비스

Firebase 프로젝트 `hareup-mobile`의 FlutterFire 설정과 Emulator 구성을 사용합니다. `functions/`에는 `META_MODEL_API` Secret을 사용하는 API 확인 및 승인 그룹 구성원용 사진 분석 callable이 있습니다. 로컬 Emulator 실행 전 `cd functions && npm install`을 실행하고, 필요하면 `functions/.secret.local`에 `META_MODEL_API=...`를 지정하세요. 이 파일은 Git에서 제외되며 앱에는 Meta 키를 저장하지 않습니다. Firebase Console에서 Email/Password 인증을 활성화하고, Functions를 배포하기 전에 Firebase 프로젝트에 `META_MODEL_API` Secret이 등록되어 있는지 확인하세요. 가족 정책은 초대 후 관리자 승인, 관리자만 삭제, 승인된 구성원은 추가·수정 가능입니다.

Google·Apple·Kakao Firebase 로그인 어댑터와 로그인 버튼을 준비했습니다. Firebase·Google·Apple·Kakao Console과 Android/iOS native 설정은 [로그인 제공자 설정 안내](docs/auth-provider-setup.md)를 따라 운영자가 직접 완료해야 합니다. Kakao Native App Key와 Apple Services ID는 `--dart-define`으로 전달하며 코드에 커밋하지 않습니다.

## Web

Web 실행·빌드와 Firebase Web 앱 등록은 [Web 설정 안내](docs/web.md)를 참고하세요. Web에서는 이메일 및 Firebase Google 팝업 로그인을 지원하며 Apple/Kakao 네이티브 로그인은 모바일 전용입니다. Firebase Hosting 배포 설정은 `firebase.json`에 포함되어 있습니다.
