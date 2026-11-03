# Flutter 공통 기반

Flutter의 [앱 아키텍처 가이드](https://docs.flutter.dev/app-architecture/guide)에 따라 화면과 상태 관리, 저장소 계약과 구현, 외부 데이터 소스를 분리하고 의존성을 생성자로 전달한다. Cubit은 이 프로젝트에서 화면의 상태와 동작을 담당한다.

- `LoadCubit<T>`: 단일 데이터를 비동기로 불러올 때 `loadValue` 또는 `Result`를 반환하는 저장소에는 `loadResult`로 로딩, 성공, 빈 상태, 실패를 관리한다. 빈 상태는 호출자가 판정하며, 나중에 시작한 요청만 상태에 반영하고 종료 후 결과를 무시한다. 요청 자체를 취소하지는 않는다.
- `BaseCubit<S>` / `BaseBloc<E, S>`: 기능별 상태나 이벤트에 사용한다. `BaseCubit`의 `emitIfOpen`은 종료 후 상태 발행을 방지하고 `runGuarded`는 비동기 성공·실패를 콜백으로 전달하며 종료 후 콜백을 생략한다. `mapFailure`를 재정의해 오류를 변환할 수 있다. 동시 요청의 순서 관리는 기능별로 구현한다.
- `LoadState<T>` 및 `AppFailure`: 화면에 전달하는 공통 상태와 실패 유형이다. 알 수 없는 오류는 `UnexpectedFailure`로 표시한다.
- `UseCase<Output, Input>`: 복잡하거나 여러 곳에서 재사용하는 비즈니스 로직에 선택적으로 사용한다.
- 저장소는 기능별 도메인 인터페이스로 필요한 동작만 정의하고 데이터 계층에서 구현한다. 공통 CRUD나 빈 기반 클래스를 강제하지 않는다.

`python3 scripts/generate_feature.py <feature> --dry-run`으로 생성 경로를 확인한다. 생성기는 기능별 상태와 `BaseCubit`을 기본으로 생성한다. 단일 로딩 상태가 적합한 경우 `LoadCubit`으로 변경한다. 생성된 코드는 출발점이며 기능별 상태, 계약, UI와 테스트를 아키텍처 문서에 맞춰 완성해야 한다.

## 아키텍처 구성 요소와 생성 기준

Flutter의 [아키텍처 권장 사항](https://docs.flutter.dev/app-architecture/recommendations)과 [가이드](https://docs.flutter.dev/app-architecture/guide)를 Hareup에 적용한다.

| 구성 요소 | Hareup의 기준 |
| --- | --- |
| View | 기능별 Page/Widget. 입력을 Cubit에 전달하고 상태를 표현한다. |
| ViewModel | `BaseCubit<S>`와 기능별 상태. 단일 로딩에는 `LoadCubit<T>`를 선택한다. |
| Repository | 도메인의 기능별 추상 인터페이스와 data 계층의 구현. 필요한 데이터와 동작을 기능별로 정한다. |
| Service | API나 플랫폼 등 외부 데이터 소스가 필요할 때 data 계층에 구체적으로 작성하고 생성자로 주입한다. |
| Model / DTO | 도메인 모델과 외부 형식에 맞는 DTO를 필요에 따라 따로 정의한다. |
| Use case | 복잡하거나 재사용되는 로직에만 기존 `UseCase<Output, Input>`을 구현한다. |
| Result | `Result<T>`, `Success<T>`, `Failure<T>`는 성공과 `AppFailure`를 명시적으로 전달할 때 사용한다. 기존 예외 기반 계약을 자동 변환하지 않는다. |
| Command | `Command0<T>`와 `Command1<T, A>`는 별도 작업의 진행·성공·실패를 관찰하고 중복 실행을 방지한다. Cubit 소유자는 생성한 명령을 `close`해야 한다. 완료 상태는 소비 후 `reset`한다. |

[Result 패턴](https://docs.flutter.dev/app-architecture/design-patterns/result)과 [Command 패턴](https://docs.flutter.dev/app-architecture/design-patterns/command)은 필요에 따라 적용한다. Command의 작업은 `Result<T>`를 반환하고, 처리되지 않은 오류는 `UnexpectedFailure`로 변환한다. 명령 종료는 진행 중인 작업 자체를 취소하지 않는다. 일회성 메시지나 이동을 처리할 때는 완료 상태를 중복 소비하지 않도록 화면에서 관리한다.

Repository·Service·DTO의 공통 부모는 Flutter 가이드의 필수 조건이 아니다. 기능별 책임과 계약을 먼저 정의하고, 공통 동작이 실제로 생겼을 때만 추상화를 추가한다. 생성기는 현재 Page, Cubit, 상태와 문서에 명시된 Repository 계약만 출발점으로 생성한다. Service, DTO, 구현체, Use case와 Command는 필요성과 계약이 확인될 때 추가한다.

## 네트워크 및 공통 화면

`NetworkClient`는 선택적으로 주입한 토큰을 설정된 기본 URL과 동일한 scheme·host·port에만 전송하고, 토큰이 포함된 요청의 자동 리디렉션을 차단한다. API 구현은 `failureFor`로 시간 초과·연결·인증/권한·요청·서버 오류를 화면에 안전하게 전달한다. 에러 응답 본문과 토큰은 사용자 메시지에 포함하지 않는다. 실제 API·인증 계약과 환경별 HTTPS 주소는 아직 연결되지 않았다.

`LoadView<T>`는 `LoadState<T>`의 로딩·빈 화면·실패 및 재시도를 공통 위젯으로 표현한다. `HareupTheme`, 색상·간격 토큰, `HareupCard`와 상태 위젯은 `hareup_design_system`에서 제공한다. 반려동물 목록은 `LoadView`를 사용한다.


## Firebase·미디어·직렬화

- Firebase 프로젝트 `hareup-mobile`과 Android/iOS 앱 등록을 사용한다. 앱 진입점에서 Firebase를 초기화하고 Firebase Auth, Firestore, Storage, Functions 인스턴스를 그룹별 저장소와 서버 어댑터에 주입한다. `HareupFirebaseServices.initialize`는 Emulator 및 별도 앱 인스턴스를 쓰는 개발·Preview 구성을 지원한다.
- `FirebaseAnalyticsAdapter`는 주입한 허용 이벤트·파라미터만 전송하며 호출자는 허용된 값에도 개인 정보가 포함되지 않도록 해야 한다. Crashlytics에는 예외 본문을 보내지 않는다. 실제 수집 정책·SDK 초기화 및 앱 연결은 미완료다.
- `PhotoSource`는 촬영·사진 선택의 성공, 사용자 취소, 권한 거부 및 실패를 구분한다. Android에서 앱 프로세스가 중단되었다가 돌아올 때 복구 API를 호출할 수 있다. 선택한 임시 파일을 장기 보관하는 저장 기능은 별도로 구현한다.
- `decodeJsonObject`는 JSON 객체만 허용하고 잘못된 입력을 `DataFormatException`으로 변환한다. `parseUtcDate`는 시간대가 명시된 문자열을 UTC로 정규화하며 시간대 없는 값은 거부한다.

## Firebase 보안 기본값

`firebase/firestore.rules`와 `firebase/storage.rules`는 승인된 구성원의 그룹 경로 접근을 허용하고 삭제는 관리자에게만 허용한다. 가족, 구성원, 초대 및 가입 요청 문서는 신뢰된 Functions만 쓸 수 있다. Emulator에서 허용·거부 사례를 검증한 뒤 규칙을 배포한다. 기존 deny-rule 검증 스크립트가 있으면 현재 정책과 맞는지 갱신 후 사용한다.

Firebase 오류는 `firebaseFailure`에서 공통 실패로 변환하고 원본 서버 오류 메시지는 사용자에게 노출하지 않는다.

## Meta Model API 비밀키

Meta Model API 키는 [Meta AI Developer 포털](https://dev.meta.ai/)에서 발급받는다. 앱의 Dart 코드, Remote Config, Firebase 클라이언트 설정에 넣지 않는다. 사진 분석은 Firebase Functions 서버가 Meta API를 호출하도록 구성한다.

Cloud Functions 코드는 `defineSecret('META_MODEL_API')`로 키를 선언한다. `verifyMetaModelApi`는 인증된 요청으로 API 연결을 확인하고, `analyzePhoto` callable은 승인된 그룹 구성원만 사진 분석을 요청할 수 있게 한다. 두 함수 모두 Secret을 서버에만 바인딩하며 키나 공급자 오류 본문을 응답·로그에 노출하지 않는다.

로컬 Functions Emulator는 `functions/.secret.local`에 `META_MODEL_API=...`를 저장해 사용한다. 이 파일은 `.gitignore`에서 제외한다. 배포용 값은 `firebase functions:secrets:set META_MODEL_API`로 관리하고, 새 값 등록 후에는 이 Secret을 사용하는 함수를 재배포해야 한다. 로컬 `.secret.local`과 배포 Secret은 각각 별도로 설정한다. 분석 결과의 정확도가 검증될 때까지 `AnalysisValidation` 기능 게이트를 활성화하지 않는다.
