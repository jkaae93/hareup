# 반려동물 아키텍처

- 요구사항: PET-01. 책임: 고양이·강아지 등록·수정·삭제.
- 현재 상태: `FirestorePetRepository`가 승인된 그룹의 `groups/{groupId}/pets` 문서와 프로필 사진을 영구 저장한다. 앱 조립부가 선택된 그룹별 저장소를 주입한다. Preview는 메모리 저장소를 사용하며, 질환 입력 선택지는 확정 전이다.

## 흐름과 계층

화면은 사용자 입력을 BLoC/Cubit에 전달하고 로딩·성공·빈 상태·실패를 렌더링한다. 일회성 이동과 메시지는 지속 상태와 분리한다. Domain은 엔티티·유스케이스·저장소 계약을 소유하고, data는 DTO·데이터 소스·저장소 구현을 제공한다. 앱 조립 계층이 구현을 주입한다.

## 데이터와 연동

- 의존성: 반려동물 저장소, 사진 선택.
- JSON은 data 경계에서 DTO로 검증하고 도메인 모델로 변환한다. 공통 오류는 실패 타입으로 변환한다.
- 공유 데이터와 사진은 `groups/{groupId}/pets/{petId}` 및 `groups/{groupId}/pets/{petId}/profile.jpg`로 분리한다. Firestore/Storage 규칙에서 승인된 구성원 권한을 검증한다.
- 테스트에는 가짜 저장소와 고정 상태를 사용한다. 네트워크·플랫폼 플러그인을 Preview에서 호출하지 않는다.

## 검증 및 결정 대기

- 정상·빈 상태·실패·재시도와 권한 거부를 테스트한다. 입력·삭제·중복·그룹 격리는 해당 기능 구현 시 추가한다.
- 선행 결정: 질환 선택지와 삭제 시 기록 보존. 실제 연동 전에 계약과 수용 기준을 구체화한다.
- 설계 변경 시 PRD 요구사항과 상태·인터페이스·테스트를 함께 갱신한다.

## 기능별 설계 상세

- 화면 흐름: 목록 → 추가·수정 → 저장; 삭제 확인 → 목록 갱신.
- 상태·계약: PetCubit: load/save/remove; LoadState<List<Pet>>. PetRepository: list/save/delete는 Result를 반환한다. 저장·삭제는 독립 Command로 처리하고 오류를 표시한다. PetDto: checked JSON 변환.
- 필수 테스트: 공백 이름 거부, 생성·수정·삭제, DTO 누락값, 삭제 취소.
- Firebase 구성: `FirestorePetRepository(firestore:, storage:, groupId:)`; 앱 조립 계층에서 인증된 사용자의 활성 그룹 ID를 전달한다.
