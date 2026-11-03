# 하릅 UI 감사

## 범위와 방법

2026-10-30 기준 저장소의 실제 Flutter 프레젠테이션 코드를 조사했다. 인증, 홈, 반려동물 등록·관리, 물그릇 등록·기준 사진, 화장실 등록·기준 사진, 사진 분석, 기록 목록·상세, 가족 선택·관리, 설정을 대상으로 했다. 이 문서는 코드 기반 감사이며 운영 서비스 전 화면을 캡처한 결과가 아니다. Stitch 참고 화면 네 장은 `stitch_pet_health_monitor_design`의 `_1`, `_2`, `_3`, `iot` 폴더에 있고, 앱 UI는 Flutter 위젯 프리뷰로 확인할 수 있다.

인증·홈·가족·물그릇·화장실·설정과 새 컴포넌트 갤러리는 위젯 프리뷰를 제공한다. 기록·사진 분석·반려동물 입력과 상태는 소스 및 위젯 테스트를 통해 조사했다. 앱에는 아직 Stitch의 통계·IoT 화면이 구현되어 있지 않다.

| 화면 | 현재 구현 |
| --- | --- |
| 인증 | [auth_gate.dart](../lib/features/auth/presentation/auth_gate.dart) |
| 홈 | [home_page.dart](../lib/features/home/presentation/home_page.dart) |
| 반려동물 목록·입력 | [pet_page.dart](../lib/features/pet/presentation/pet_page.dart), [pet_editor.dart](../lib/features/pet/presentation/pet_editor.dart) |
| 물그릇 목록·입력·상세 | [water_bowl_page.dart](../lib/features/water_bowl/presentation/water_bowl_page.dart) |
| 화장실 목록·입력·상세 | [litter_box_page.dart](../lib/features/litter_box/presentation/litter_box_page.dart) |
| 사진 분석 | [analysis_page.dart](../lib/features/photo_analysis/presentation/analysis_page.dart) |
| 기록 목록·상세 | [records_page.dart](../lib/features/records/presentation/records_page.dart) |
| 가족 선택·관리 | [family_access_page.dart](../lib/features/family/presentation/family_access_page.dart), [family_page.dart](../lib/features/family/presentation/family_page.dart) |
| 설정 | [settings_page.dart](../lib/features/settings/presentation/settings_page.dart) |

## 수집 결과

아래 수치는 `lib/features/*/presentation/*.dart`의 소스 호출 개수이며 런타임 화면에 동시에 표시되는 개수가 아니다. 제네릭 생성자는 집계에서 빠질 수 있다.

| 요소 | 발견된 사용 |
| --- | --- |
| 버튼 | `FilledButton` 8, `OutlinedButton` 4, `TextButton` 25, `IconButton` 6, `FloatingActionButton` 3 |
| 입력 | `TextFormField` 14, `TextField` 2, `DropdownButtonFormField` 3 |
| 선택 | `CheckboxListTile` 2, `SwitchListTile` 1 |
| 표면 | `Card` 14, `ListTile` 15 |
| 아이콘 | Material Icons 약 25종. 자주 쓰이는 아이콘은 `chevron_right` 6, `add` 3, `pets`, `water_drop_outlined`, `cleaning_services_outlined`, `hourglass_top` 각 2 |
| 텍스트 | Pretendard가 테마에 지정되어 있으나 사용 중인 `headlineMedium` 등 일부는 Flutter 기본 스타일로 남아 있었음 |
| 색상 | 주요 화면은 공통 테마를 사용. 색상 역할과 상태 배지에 같은 HEX가 여러 번 선언되어 있었음 |
| 간격 | 4·8·16·24·32와 화면 최대 폭 680을 사용하며, 추가 버튼을 위한 하단 88은 별도 예외 |

화면 코드에서 확인한 아이콘 전체: `add`, `add_home_outlined`, `chat_bubble_outline`, `chevron_right`, `cleaning_services_outlined`, `cruelty_free`, `delete_outline`, `g_mobiledata`, `history`, `home_outlined`, `hourglass_top`, `info_outline`, `key`, `key_outlined`, `login`, `logout`, `open_in_new`, `people_outline`, `person_outline`, `person_remove_outlined`, `pets`, `phone_iphone`, `refresh`, `settings_outlined`, `switch_account_outlined`, `water_drop_outlined`. 디자인 시스템 내부 사진·상태 아이콘은 별도로 공통 컴포넌트에 포함된다.

## 확인한 문제와 조치

1. 문서의 `Primary container #007BB9`와 코드의 `primaryContainer #CCE5FF`가 충돌했다. `primary500`은 `#007BB9`, 실제 Material `primaryContainer`는 `primary100 #CCE5FF`로 구분했다.
2. 문서의 18sp 카드 제목이 코드의 `titleLarge` 20sp와 달랐다. `headlineMedium`을 섹션 20sp, `titleLarge`를 카드 제목 18sp로 명시하고 사용처를 맞췄다.
3. 상태 배지에 색상 HEX가 중복됐다. 공통 색상 토큰을 참조하도록 바꿨다.
4. 버튼·입력·체크박스의 hover, focus, disabled, error 표현이 일부 Flutter 기본값에 의존했다. 공통 테마에 상태 규칙을 지정하고 갤러리에서 기본·오류·비활성·선택 상태를 확인할 수 있게 했다.
5. 기존 문서는 계획된 도메인 컴포넌트와 실제 구현을 섞어 설명했다. 구현된 공통 컴포넌트와 향후 기능을 분리했다.

## 남은 검토

- 이 감사는 코드와 위젯 프리뷰 기준이다. 실제 운영 계정·실데이터 및 모든 OS/화면 크기 조합의 캡처는 포함하지 않는다.
- 아이콘 의미가 비슷한 `pets`와 `cruelty_free`는 각각 고양이·강아지의 기존 표시로 유지했다. 실사용 맥락에서 의미가 충분히 명확한지 후속 사용성 검토가 필요하다.
- 다크 테마, IoT, 음수량 목표와 통계는 구현 범위가 아니므로 토큰이나 동작을 가정하지 않았다.
