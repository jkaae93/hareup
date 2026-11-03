# 하릅 디자인 시스템

이 문서는 Flutter 구현과 동일한 이름과 값을 사용한다. 기준 구현은 `packages/design_system/lib/design_system.dart`, 글꼴 선언은 루트 `pubspec.yaml`, UI 조사 범위는 [UI 감사](ui-audit.md)다. 앱과 프리뷰 모두 `HareupTheme.light`를 사용한다. Pretendard 400·500·600·700·800은 앱에 포함되며 라이선스는 `assets/fonts/pretendard/LICENSE.txt`에 있다.

## 파운데이션

색상은 아래 **Dart 상수**를 정식 토큰 이름으로 사용한다. 숫자는 해당 색 계열 내 밝기 순서를 표현하며 계열 간 동일한 명도나 균등 간격을 의미하지 않는다. 별도로 정의되지 않은 단계는 만들지 않는다.

| 색상 토큰 | HEX | 용도 |
| --- | --- | --- |
| `HareupColors.primary100` | `#CCE5FF` | primary container |
| `HareupColors.primary300` | `#93CCFF` | 밝은 파랑 강조 |
| `HareupColors.primary500` | `#007BB9` | 브랜드 보조 파랑 |
| `HareupColors.primary700` | `#006194` | 기본 동작, 선택 |
| `HareupColors.primary900` | `#001D31` | 어두운 파랑 |
| `HareupColors.secondary100` / `secondary300` / `secondary700` / `secondary900` | `#6CF8BB` / `#4EDEA3` / `#006C49` / `#005236` | 긍정·완료 표면과 글자 |
| `HareupColors.success100` / `success700` / `success900` | `#6CF8BB` / `#006C49` / `#005236` | 성공 상태; 동일한 secondary 색상의 의미별 별칭 |
| `HareupColors.warning100` / `warning700` / `warning900` | `#FFDDB8` / `#825100` / `#653E00` | 주의 표면과 글자 |
| `HareupColors.error100` / `error700` / `error900` | `#FFDAD6` / `#BA1A1A` / `#93000A` | 오류 표면과 글자 |
| `HareupColors.neutral0` / `neutral50` / `neutral100` / `neutral200` / `neutral300` | `#FFFFFF` / `#F9F9FF` / `#F0F3FF` / `#E7EEFF` / `#DEE8FF` | 카드·배경·표면 |
| `HareupColors.neutral400` / `neutral700` / `neutral900` | `#BFC7D2` / `#3F4850` / `#111C2D` | 테두리·보조 글자·본문 |

`seed`, `background`, `primaryContainer`, `secondary`, `surfaceContainer`, `onSurface`, `onSurfaceVariant`, `outline`은 기존 호출을 위한 별칭이다. `Theme.of(context).colorScheme`의 `primary`는 `primary700`, `primaryContainer`는 `primary100`, `secondary`는 `secondary700`, `error`는 `error700`이다. 성공·주의·오류는 색상 외에 라벨이나 아이콘을 함께 사용한다. 본문 대비는 4.5:1 이상을 목표로 한다.

### 타이포그래피

| 토큰 | Material TextTheme | 크기 / 줄 높이 / 굵기 / 자간 |
| --- | --- | --- |
| `HareupTypography.display` | `displaySmall` | 30 / 38 / 700 / -0.6 |
| `HareupTypography.heading` | `headlineSmall` | 24 / 32 / 700 / -0.24 |
| `HareupTypography.section` | `headlineMedium` | 20 / 28 / 600 / 0 |
| `HareupTypography.titleLarge` | `titleLarge` | 18 / 24 / 600 / 0 |
| `HareupTypography.titleMedium` | `titleMedium` | 16 / 22 / 600 / 0 |
| `HareupTypography.bodyLarge` | `bodyLarge` | 16 / 24 / 400 / 0 |
| `HareupTypography.bodyMedium` | `bodyMedium` | 14 / 20 / 400 / 0 |
| `HareupTypography.bodySmall` | `bodySmall` | 13 / 18 / 400 / 0 |
| `HareupTypography.labelLarge` | `labelLarge` | 14 / 20 / 600 / 0 |
| `HareupTypography.labelMedium` | `labelMedium` | 12 / 16 / 600 / 0 |
| `HareupTypography.labelSmall` | `labelSmall` | 11 / 14 / 500 / 0 |

크기·줄 높이·자간 단위는 Flutter 논리 픽셀이다. 화면에서는 `Theme.of(context).textTheme`으로 색상과 폰트가 적용된 스타일을 가져온다. 정의하지 않은 Material 텍스트 역할은 Flutter 기본값이므로 새 UI에는 위 역할을 선택한다. 시스템 글자 확대를 허용하고 글자 고정 높이를 피한다.

### 간격과 형태

`HareupSpacing.extraSmall` 4, `small` 8, `medium` 16, `large` 24, `extraLarge` 32를 사용한다. 화면 좌우는 `HareupSpacing.pageMargin` 20, 카드 내부는 16, 항목 간격은 8, 섹션 간격은 24가 기본이다. `HareupContent`는 최대 폭 `maxContentWidth` 680을 적용한다. 떠 있는 추가 버튼 아래에 가려지지 않도록 목록에서만 `floatingActionClearance` 88을 사용한다. 카드 반경은 16, 입력과 버튼은 12, 배지는 pill이다. 최소 터치 영역은 48×48이다.

## 핵심 컴포넌트

기존 Material 위젯을 공통 `HareupTheme.light`로 스타일링한다. 모든 화면에 적용되므로 동일한 버튼을 별도 래퍼로 다시 만들지 않는다. `lib/app/previews.dart`의 **핵심 컴포넌트와 상태** 프리뷰에서 동작을 확인한다.

| 컴포넌트 | 사용·상태 | Do | Don't |
| --- | --- | --- | --- |
| `FilledButton` / `OutlinedButton` / `TextButton` | 주·보조·낮은 강조 동작. 기본, hover, focus, pressed, disabled를 테마에서 처리한다. `onPressed: null`은 비활성이다. | 화면의 주요 완료 동작에는 Filled를 쓴다. 진행 중에는 중복 실행을 막고 진행 상태를 알려준다. | 한 영역에 같은 강조도의 주요 동작을 여러 개 두지 않는다. 비활성 색만으로 이유를 전달하지 않는다. |
| `TextFormField` / `TextField` | 흰 배경·12 반경·기본 테두리, focus 테두리, error·disabled 테두리. `InputDecoration`의 라벨·에러를 사용한다. | 필요한 입력 유형과 명시적 라벨·검증 메시지를 제공한다. | 힌트만 라벨로 쓰거나 입력 폼을 모달에 넣지 않는다. |
| `Checkbox` / `CheckboxListTile` | 선택·미선택·disabled, hover·focus 표시. 선택 값과 콜백은 화면이 관리한다. | 독립적으로 여러 항목을 고를 때 사용한다. 텍스트 라벨을 함께 둔다. | 서로 배타적인 선택이나 즉시 적용 설정을 체크박스로 혼동하지 않는다. |
| `Card` / `HareupPanel` | 흰 표면·16 반경·neutral200 테두리·옅은 그림자. `HareupPanel`은 16 내부 패딩을 제공한다. | 관련 내용을 묶고, 탭 가능하면 `ListTile` 등의 명확한 동작을 제공한다. | 단순 여백만을 위해 카드를 중첩하지 않는다. |
| `HareupStatusBadge` / Material `Icon` | 배지는 neutral·success·warning·error와 라벨을 제공한다. 아이콘 기본 크기는 24, 아이콘 버튼 터치 영역은 최소 48이다. | 상태는 의미 있는 텍스트를 같이 표시하고 아이콘 단독 버튼에는 tooltip을 제공한다. | 색이나 모양만으로 상태를 알리거나 장식 아이콘을 동작처럼 보이게 하지 않는다. |

예시:

```dart
final text = Theme.of(context).textTheme;
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('반려동물', style: text.headlineMedium),
    const SizedBox(height: HareupSpacing.small),
    const TextField(decoration: InputDecoration(labelText: '이름')),
    const SizedBox(height: HareupSpacing.medium),
    FilledButton(onPressed: save, child: const Text('저장')),
  ],
)
```

## 공통 화면 구성

`HareupFormPage`는 입력 화면의 본문과 하단 동작을 배치하고 `HareupTextEntryPage`는 간단한 단일 텍스트 입력 후 결과를 반환한다. 입력·상세는 일반 화면으로 열고, 모달은 삭제·로그아웃 등 상태 확인에만 사용한다. `HareupPhotoPreview`, `HareupPhotoComparison`, `HareupPhotoActions`, `HareupSectionHeader`, `EmptyNotice`, `ErrorNotice`, `HareupLoading`은 각각 사진, 섹션, 비동기 상태를 공통 처리한다.

음수량 목표·배변 점수·통계·IoT·진료 리포트는 Stitch 참고 디자인에만 존재하는 기능이다. 실제 데이터와 기능 설계가 준비되기 전에는 해당 수치나 상태를 임의로 표시하지 않는다.

Stitch 가이드 기준 주요 버튼은 primary500, 최소 높이 52이며 hover·pressed·focus·disabled 상태를 공통 테마에서 처리한다. 보조 버튼은 흰 배경과 primary500 테두리다. 입력 기본 테두리는 neutral300, 포커스는 primary500, 오류는 error700이다. 가이드의 추가 기능 예시는 실제 앱 기능으로 간주하지 않는다.

`HareupCountField`는 0 이상의 관찰 횟수를 직접 입력하거나 증감할 때 사용한다. 각 증감 버튼에는 대상을 포함한 접근성 라벨을 제공한다. `HareupGuidance`, `HareupFormSection`, `HareupMetric`은 촬영 안내, 입력 그룹과 추정 수치를 일관되게 표시한다. 사진 촬영·선택 버튼과 폼 하단 동작은 좁은 화면과 확대된 글자에서 줄바꿈한다.
