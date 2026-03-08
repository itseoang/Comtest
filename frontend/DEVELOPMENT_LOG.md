# 자연도감 Flutter 앱 개발 로그

**문서 작성일**: 2026-03-05
**프로젝트명**: Nature Collection (자연도감)
**버전**: 0.1.0+1

---

## 프로젝트 개요

자연도감은 어린이들이 발견한 생물을 사진으로 촬영하여 도감을 만들 수 있는 AI 기반 동식물 인식 앱입니다. 디바이스 온칩(TFLite) 종 식별, 관찰일기 작성, 친구 기능, 보호자 모니터링 시스템을 제공하며, 보호자는 자녀의 활동을 모니터링하고 격려 댓글을 남길 수 있습니다.

### 핵심 기능
- **종 식별**: TFLite 온디바이스 AI 모델을 통한 생물 인식
- **도감 수집**: 발견한 생물을 분류별로 관리
- **관찰일기**: 촬영 위치, 날씨, 설명과 함께 일기 기록
- **친구 기능**: 다른 사용자의 도감 열람 및 학술 정보 공유
- **보호자 모드**: 보호자 초대(QR 코드), 자녀 활동 모니터링, 격려 댓글
- **네이버 지도 연동**: 발견 장소를 지도 마커로 표시 및 주변 장소 검색

---

## 기술 스택

### 프레임워크 & 언어
- **Flutter 3.16.0+** (Dart 3.2.0+)

### 상태관리
- `flutter_bloc` (8.1.6) - BLoC 패턴
- `bloc` (8.1.4)
- `equatable` (2.0.5) - 상태/이벤트 동등성 비교

### 네비게이션
- `go_router` (14.2.0) - 강타입 라우팅

### 백엔드 & 데이터
- `supabase_flutter` (2.7.0) - 백엔드 서비스
- `dio` (5.7.0) - HTTP 클라이언트
- `sqflite` (2.3.3) - 로컬 SQLite DB
- `path_provider` (2.1.4) - 파일 경로

### 카메라 & 이미지
- `camera` (0.11.0+2)
- `image_picker` (1.1.2)
- `image` (4.2.0)
- `native_exif` (0.6.0) - EXIF 메타데이터

### 위치정보
- `geolocator` (12.0.0) - GPS
- `geocoding` (3.0.0) - 좌표 ↔ 주소 변환

### UI & 시각화
- `cached_network_image` (3.4.1)
- `shimmer` (3.0.0) - 로딩 효과
- `lottie` (3.1.2) - 애니메이션
- `flutter_staggered_grid_view` (0.7.0)
- `percent_indicator` (4.2.3)

### 그림일기 (Drawing)
- `flutter_drawing_board` (1.0.1)
- `record` (6.2.0) - 음성 녹음
- `audioplayers` (6.1.0) - 음성 재생

### 지도
- `flutter_naver_map` (1.3.0) - 네이버 지도 SDK
- `url_launcher` (6.2.5) - 외부 앱/URL 실행

### QR 코드
- `qr_flutter` (4.1.0) - QR 코드 생성
- `mobile_scanner` (5.1.1) - QR 코드 스캔

### 환경설정
- `flutter_dotenv` (5.2.1) - .env 환경변수

### 유틸리티
- `uuid` (4.5.0)
- `intl` (0.19.0) - 국제화/날짜 포맷
- `json_annotation` (4.9.0)
- `freezed_annotation` (2.4.4)

---

## 개발 이력

### Task 1: 앱 빌드 및 실행

**요청**: "앱 빌드하고 실행해줘"

**내용**:
- Flutter 앱을 iOS 시뮬레이터(iPhone 17 Pro)에서 빌드 및 실행
- 초기 프로젝트 구조 검증
- 의존성 설치 및 빌드 완료

**결과**: ✅ 성공
**수정 파일**: 없음
**신규 파일**: 없음

---

### Task 2: 보호자 모드 추가

**요청**: "내 프로필을 보면 보호자 모드가 있는데 보호자 세션에서는 메뉴가 하나 더 추가 되어야 해"

**내용**:
- **Profile 모델 확장**:
  - `isGuardian` 필드 추가 (기본값: false)
  - `guardianName` 필드 추가 (보호자 이름)
  - `copyWith` 메서드 구현

- **인증 시스템**:
  - AuthBloc에 `DevGuardianLogin` 이벤트 추가 (개발 전용 보호자 로그인)
  - 로그인 화면에 "보호자 모드로 시작" 버튼 추가

- **하단 네비게이션**:
  - 일반 모드: 5탭 (홈/도감/발견/일기/친구/프로필)
  - 보호자 모드: 6탭 (홈/도감/발견/일기/친구/모니터링/프로필)
  - `StatefulShellRoute.indexedStack`에서 동적 탭 인덱스 매핑

- **GuardianMonitorScreen** (신규):
  - 자녀의 활동을 모니터링하는 대시보드
  - 수집 현황, 최근 활동, 일기 피드 표시

**수정 파일**:
- `lib/models/profile.dart`
- `lib/blocs/auth/auth_bloc.dart`
- `lib/blocs/auth/auth_event.dart`
- `lib/screens/auth/login_screen.dart`
- `lib/widgets/common/nature_bottom_nav.dart`
- `lib/router/app_router.dart`

**신규 파일**:
- `lib/screens/guardian/guardian_monitor_screen.dart`

---

### Task 3: 홈 대시보드 화면

**요청**: "푸터에 전체 메뉴를 바로가기 기능을 만들어줘 home 기능을 만들어야 해"

**내용**:
- **DashboardScreen** (신규):
  - 첫 번째 탭으로 설정
  - 인사 배너 ("안녕하세요, [닉네임]님!")
  - 6개 메뉴 그리드 바로가기 (도감/발견/일기/친구/프로필/설정)
  - 에코포인트 배너
  - 주간 챌린지 위젯

- **라우팅 변경**:
  - 홈 탭 → DashboardScreen
  - 도감은 /home/collection 서브라우트로 접근 가능

**수정 파일**:
- `lib/widgets/common/nature_bottom_nav.dart`
- `lib/router/app_router.dart`

**신규 파일**:
- `lib/screens/home/dashboard_screen.dart`

---

### Task 4: 보호자 댓글 시스템

**요청**: "내 아이가 쓴 글에 보호자의 글도 같이 보이게 해줘 칭찬 독려 하는거야"

**내용**:
- **GuardianComment 모델**:
  - 보호자 이름, 댓글 내용, 타임스탬프 필드
  - 보호자는 자녀의 일기에 응원/칭찬 댓글 추가 가능

- **DiaryEntry 모델 확장**:
  - `guardianComments` 필드 (List<GuardianComment>) 추가

- **DiaryBloc**:
  - `AddGuardianComment` 이벤트 추가
  - 댓글 추가 로직 구현

- **일기 상세 화면** (DiaryDetailScreen):
  - 보호자 댓글 섹션 표시
  - 보호자 모드일 때만 댓글 입력 필드 노출

- **일기 리스트 카드** (DiaryScreen):
  - 보호자 댓글 있을 때 "보호자 💬" 뱃지 표시

- **Mock 데이터**:
  - 보호자 댓글 샘플 데이터 추가

**수정 파일**:
- `lib/models/diary.dart`
- `lib/blocs/diary/diary_bloc.dart`
- `lib/screens/diary/diary_detail_screen.dart`
- `lib/screens/diary/diary_screen.dart`

**신규 파일**: 없음 (모델 내부에 GuardianComment 정의)

---

### Task 5: 일기 위치 → 네이버 지도 연동

**요청**: "발견한 장소를 클릭하면 네이버 지도로 마커를 찍어줘야해"

**내용**:
- **패키지 추가**:
  - `url_launcher` (6.2.5) - URL 스킴 실행

- **iOS 설정** (Info.plist):
  - `LSApplicationQueriesSchemes`에 `nmap` 추가 (네이버 지도 URL 스킴)

- **DiaryEntry 모델**:
  - `latitude`, `longitude` 필드 추가
  - Mock 데이터에 좌표 입력 (서울 주요 위치)

- **MapLauncher 서비스** (신규):
  - `launchNaverMapMarker(lat, lon)`: 네이버 지도 앱 실행
  - 네이버 지도 미설치 시 웹 폴백
  - 주소 역지오코딩 (좌표 → 주소)

- **UI 통합**:
  - DiaryDetailScreen: 위치 섹션 탭 → 지도 실행
  - DiaryScreen: 카드 위치 텍스트 탭 → 지도 실행

**수정 파일**:
- `frontend/pubspec.yaml`
- `frontend/ios/Runner/Info.plist`
- `lib/models/diary.dart`
- `lib/screens/diary/diary_detail_screen.dart`
- `lib/screens/diary/diary_screen.dart`

**신규 파일**:
- `lib/services/map_launcher.dart`

---

### Task 6: 컬렉션 상세 발견장소 → 지도 연동

**요청**: "발견장소 클릭해도 지도 마커로 되게 해줘야지" (스크린샷 첨부)

**내용**:
- **CollectionItem 모델**:
  - `latitude`, `longitude` 필드 추가
  - Mock 데이터에 서울 주요 공원/명소 좌표 입력:
    - 북한산 (37.6563, 126.9714)
    - 광릉수목원 (37.7406, 127.1654)
    - 올림픽공원 (37.5175, 127.1227)
    - 남산공원 (37.5515, 126.9909)
    - 청계산 (37.4865, 127.0153)
    - 덕수궁 (37.5651, 126.9709)

- **UI 개선** (CollectionDetailScreen):
  - 발견장소 리스트 → GestureDetector로 탭 감지
  - 타이핑: 밑줄 스타일 + open_in_new 아이콘으로 클릭 유도
  - MapLauncher 서비스 호출

**수정 파일**:
- `lib/models/collection.dart`
- `lib/blocs/collection/collection_bloc.dart`
- `lib/screens/home/collection_detail_screen.dart`

**신규 파일**: 없음

---

### Task 7: CMS/커뮤니티 기반 홈 레이아웃

**요청**: "홈 화면 자체가 cms 커뮤니티 기반으로 보이게 할 레이아웃이 필요해"

**내용**:
- **DashboardScreen 완전 재작성**:
  - **컴팩트 인사 배너**: 닉네임, 날씨, 에코포인트
  - **수평 스크롤 퀵 메뉴**: 칩 형태 (도감/발견/일기/친구/프로필)
  - **주간 챌린지 배너**: 진행률 바, 보상 정보
  - **인기관찰 수평 카드**: 아래 Task 8에서 상세 구현
  - **커뮤니티 피드**: 3개 포스트 (사용자 프로필, 내용, 좋아요/댓글)
  - **자연 팁 카드**: 오늘의 팁 섹션
  - **에코포인트 배너**: 누적 포인트, 다음 레벨까지 진행률

- **배경**: NatureTheme 크림색 (#FAFAF5)
- **스크롤**: SingleChildScrollView로 모든 섹션 스크롤 가능

**수정 파일**:
- `lib/screens/home/dashboard_screen.dart`

**신규 파일**: 없음

---

### Task 8: 인기관찰 카드 사진 표시

**요청**: "카드에 사진도 표시" (선택지에서 선택)

**내용**:
- **_PopularItem 모델 확장**:
  - `author` (String): 작성자 닉네임
  - `emoji` (String): 이모지를 통한 Mock 사진 표시
  - `bgColors` (List<Color>): 카드 배경 그라디언트

- **인기관찰 카드 UI**:
  - 높이: 230px (증가)
  - 구성:
    - 상단: 이모지 대형 (100px)
    - 중간: 종명 + 카테고리 뱃지 + 좋아요 뱃지
    - 하단: 작성자 정보 (avatar + nickname)
  - 배경: `bgColors` 기반 그라디언트

- **Mock 데이터**:
  - 6개 인기관찰 항목 (벚꽃, 제비, 나비 등)

**수정 파일**:
- `lib/screens/home/dashboard_screen.dart`

**신규 파일**: 없음

---

### Task 9: 도감 리스트형 + 카테고리 + 내것/전체 토글

**요청**: "내 도감을 리스트형으로 하고 카테고리화 해줘, 내것만 보기 다른친구들것도 보기 추가해서"

**내용**:
- **HomeScreen (도감 화면) 완전 재작성**:
  - **토글 버튼** (AnimatedContainer):
    - "내 도감" / "전체 도감" 전환
    - 선택 상태에 따라 다른 배경색

  - **카테고리 필터** (수평 스크롤 칩):
    - 전체/식물/조류/곤충/포유류/양서류
    - 선택된 카테고리만 표시

  - **리스트 뷰**:
    - 아이콘 + 종명 + 위치/날짜 + 카드번호 + 희귀도 뱃지
    - 카테고리 아이콘 색상 구분

  - **친구 도감** (친구가 보유한 생물):
    - "친구" 뱃지 추가
    - 민트색 테두리로 구분
    - 상단 "전체 도감"에만 표시

  - **Mock 친구 데이터** (4명):
    - 김민지: 벚꽃
    - 이소연: 청둥오리
    - 박준호: 호랑나비
    - 최민서: 너구리

**수정 파일**:
- `lib/screens/home/home_screen.dart`

**신규 파일**: 없음

---

### Task 10: 보유 생물 컬러 / 미보유 그레이 처리

**요청**: "내가 갖고있는 탐색한 생물은 컬러로 해주고 내가 갖고있지 않은 도감은 그레이로 처리 해줘"

**내용**:
- **보유 생물 (내 것 또는 발견함)**:
  - 아이콘: 원래 색상 (컬러)
  - 배경: 흰색 (#FFFFFF)
  - 그림자: 드롭 섀도우 (0.2 opacity)
  - 상호작용: 탭 가능, 상세 화면 이동
  - 희귀도 뱃지: 컬러 (황금/은/동색)

- **미보유 생물** (친구가 가진 미발견 생물):
  - 아이콘: 회색 (#BDBDBD)
  - 배경: 라이트 그레이 (#F5F5F5)
  - 상호작용: 탭 불가
  - 상단 왼쪽: 잠금 아이콘
  - 우측: "미발견" 라벨 (회색 텍스트)
  - 희귀도 뱃지: 회색 "???" 텍스트

**수정 파일**:
- `lib/screens/home/home_screen.dart`

**신규 파일**: 없음

---

### Task 11: 미보유 아이템 촬영장소 버튼 + 주변 추천 정보

**요청**: "미보유 리스트에서는 오른쪽 끝에 촬영장소 버튼을 만들어주고 클릭하면 해당 지도로 이동, 그 아래에는 해당 지역 주변의 관광, 맛집, 체험할거 데이터를 넣을거야"

**내용**:
- **거리 계산** (Haversine 공식):
  - 사용자 위치 (Mock): 서울 중심부 (37.5665, 126.9780)
  - CollectionItem의 위치와 사용자 위치 거리 계산
  - 미보유 아이템 거리 가까운 순 정렬

- **미보유 아이템 UI**:
  - 회색 "???" 뱃지 → 그린 칩 버튼 "촬영장소"로 교체
  - 클릭 시 MapLauncher로 해당 좌표 지도 실행
  - 서브텍스트: 거리 표시 (예: "· 4.8km")

- **확장 패널** (미보유 아이템 탭 시):
  - AnimatedSize로 매끄러운 확장/축소
  - 3개 카테고리 (수평 스크롤 칩):
    - 🏛 관광 (박물관, 공원, 유산지)
    - 🍽 맛집 (카페, 레스토랑)
    - 🎯 체험 (체험학습, 생태 교실)
  - 각 칩 클릭 → 지도 검색 (MapLauncher)

- **Mock 주변 정보** (4개 장소별):
  - 여의도공원: 관광 3개, 맛집 3개, 체험 3개
  - 한강공원: 관광 3개, 맛집 3개, 체험 3개
  - 서울숲: 관광 3개, 맛집 3개, 체험 3개
  - 관악산: 관광 3개, 맛집 3개, 체험 3개

**수정 파일**:
- `lib/screens/home/home_screen.dart`

**신규 파일**: 없음

---

### Task 12: 네이버 맵 API 환경 설정

**요청**: "네이버 맵 api 사용할거야 env 셋팅을 진행해"

**용도**: 지도 SDK (앱 내 지도 표시) + Geocoding/검색 REST API 모두 사용

**내용**:
- **패키지 추가** (pubspec.yaml):
  - `flutter_dotenv` (5.2.1) - 환경변수 로드
  - `flutter_naver_map` (1.3.0) - 네이버 지도 SDK

- **환경설정 파일**:
  - `.env` (실제 API 키 저장 - .gitignore에 포함):
    - `NAVER_MAP_CLIENT_ID` (필수)
    - `NAVER_MAP_CLIENT_SECRET` (REST API 호출 시)

  - `.env.example` (템플릿):
    ```
    NAVER_MAP_CLIENT_ID=YOUR_CLIENT_ID
    NAVER_MAP_CLIENT_SECRET=YOUR_CLIENT_SECRET
    ```

- **EnvConfig 클래스** (신규):
  - 정적 메서드로 .env에서 환경변수 읽기
  - `EnvConfig.naverMapClientId`
  - `EnvConfig.naverMapClientSecret`

- **constants.dart 수정**:
  - const 값 → getter 변수 변경 (env에서 동적 로드)

- **main.dart 수정**:
  - `dotenv.load(fileName: '.env')` - .env 파일 로드
  - `FlutterNaverMap().init(clientId: ...)` - 네이버 지도 SDK 초기화
  - Supabase 초기화 (devMode 체크)

- **NaverMapApi 서비스** (신규):
  - Geocoding: 주소 → 좌표
  - Reverse Geocoding: 좌표 → 주소
  - 주변 장소 검색 (관광/맛집/체험)
  - dio 클라이언트를 통한 REST API 호출

- **.gitignore**:
  - `.env` 추가 (실제 키 커밋 방지)

**수정 파일**:
- `lib/pubspec.yaml`
- `lib/.gitignore`
- `lib/config/constants.dart`
- `lib/main.dart`

**신규 파일**:
- `.env` (템플릿)
- `.env.example` (템플릿 예시)
- `lib/config/env_config.dart`
- `lib/services/naver_map_api.dart`

---

### Task 13: 보호자 QR 코드 초대/스캔 시스템

**요청**: "어린이 모드에서 보호자 초대하기 하면 초대할 수 있는 세션이나, 보호자가 들어왔을때 qr code 스캔으로 보호자 등록되게 해줘"

**내용**:
- **패키지 추가** (pubspec.yaml):
  - `qr_flutter` (4.1.0) - QR 코드 생성
  - `mobile_scanner` (5.1.1) - QR 스캔

- **GuardianBloc & 관련 클래스** (신규):
  - **Events**:
    - `GenerateInviteCode`: 초대 코드 + QR 생성
    - `ScanGuardianQr`: QR 코드 스캔
    - `RegisterAsGuardian`: 보호자로 등록
    - `RemoveGuardian`: 보호자 제거
    - `CheckGuardianStatus`: 보호자 연결 상태 확인

  - **States**:
    - `GuardianInitial`
    - `InviteCodeGenerated` (초대코드, QR 이미지)
    - `ScanningQr` (스캔 중)
    - `GuardianRegistered` (등록 완료)
    - `GuardianError`

- **GuardianInviteScreen** (어린이 모드):
  - QR 코드 생성 (240x240px)
  - 8자리 초대 코드 표시 (복사 버튼)
  - 10분 만료 타이머 (시계 아이콘)
  - "재생성" 버튼
  - "초대 코드" 입력 필드 (보호자가 직접 입력 시)

- **GuardianScanScreen** (보호자 모드):
  - 카메라 QR 스캔 인터페이스
  - 스캔 가이드 오버레이 (프레임 표시)
  - 스캔 결과 다이얼로그 (확인 메시지)
  - "직접 코드 입력" 탭 (텍스트 필드)
  - 등록 완료 애니메이션 (체크마크 + 메시지)

- **Profile 모델 확장**:
  - `guardianName` 필드 추가 (보호자 이름)
  - `copyWith` 메서드 업데이트

- **ProfileScreen 내 _GuardianSheet**:
  - 어린이/보호자 모드 분기:
    - 어린이 모드: GuardianInviteScreen
    - 보호자 모드: GuardianScanScreen
  - 보호자 제거 옵션

**수정 파일**:
- `lib/pubspec.yaml`
- `lib/models/profile.dart`
- `lib/screens/profile/profile_screen.dart`

**신규 파일**:
- `lib/blocs/guardian/guardian_bloc.dart`
- `lib/blocs/guardian/guardian_event.dart`
- `lib/blocs/guardian/guardian_state.dart`
- `lib/screens/guardian/guardian_invite_screen.dart`
- `lib/screens/guardian/guardian_scan_screen.dart`

---

## 파일 구조

```
frontend/
├── .env                              # 환경변수 (NAVER_MAP_CLIENT_ID, SECRET)
├── .env.example                      # 환경변수 템플릿
├── .gitignore                        # .env 포함
├── pubspec.yaml                      # 의존성 정의
├── analysis_options.yaml
├── DEVELOPMENT_LOG.md                # 이 문서
├── ios/
│   ├── Runner/
│   │   ├── Info.plist               # LSApplicationQueriesSchemes (nmap)
│   │   ├── AppDelegate.swift
│   │   └── Assets.xcassets/
│   ├── Podfile
│   ├── Podfile.lock
│   └── Runner.xcworkspace/
├── android/
├── test/
└── lib/
    ├── main.dart                     # dotenv 로드, 네이버맵 초기화
    ├── config/
    │   ├── theme.dart               # NatureTheme (크림색 #FAFAF5)
    │   ├── constants.dart           # 상수 (동적 로드로 변경)
    │   └── env_config.dart          # .env 환경변수 래퍼 (NEW)
    ├── models/
    │   ├── profile.dart             # isGuardian, guardianName 추가
    │   ├── diary.dart               # latitude, longitude, guardianComments 추가
    │   ├── collection.dart          # latitude, longitude 추가
    │   ├── friend.dart              # 친구 모델
    │   └── ...
    ├── blocs/
    │   ├── auth/
    │   │   ├── auth_bloc.dart       # DevGuardianLogin 이벤트 추가
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   ├── diary/
    │   │   ├── diary_bloc.dart      # AddGuardianComment 이벤트
    │   │   ├── diary_event.dart
    │   │   └── diary_state.dart
    │   ├── collection/
    │   │   ├── collection_bloc.dart
    │   │   ├── collection_event.dart
    │   │   ├── collection_state.dart
    │   │   ├── collection_detail_bloc.dart
    │   │   ├── collection_detail_event.dart
    │   │   └── collection_detail_state.dart
    │   ├── friend/
    │   │   ├── friend_bloc.dart
    │   │   ├── friend_event.dart
    │   │   └── friend_state.dart
    │   └── guardian/                # NEW
    │       ├── guardian_bloc.dart
    │       ├── guardian_event.dart
    │       └── guardian_state.dart
    ├── services/
    │   ├── api/
    │   │   └── dio_client.dart      # HTTP 클라이언트
    │   ├── map_launcher.dart        # 네이버맵 URL 스킴 (NEW)
    │   ├── naver_map_api.dart       # 네이버 API (Geocoding, 검색) (NEW)
    │   ├── image_validator.dart
    │   ├── species_classifier.dart
    │   └── ...
    ├── screens/
    │   ├── auth/
    │   │   └── login_screen.dart    # 보호자 모드 버튼 추가
    │   ├── home/
    │   │   ├── home_screen.dart     # 도감 리스트 + 카테고리 + 토글
    │   │   ├── dashboard_screen.dart # CMS 커뮤니티 홈 (NEW)
    │   │   └── collection_detail_screen.dart
    │   ├── diary/
    │   │   ├── diary_screen.dart    # 보호자 댓글 뱃지 추가
    │   │   ├── diary_detail_screen.dart # 보호자 댓글 섹션 추가
    │   │   └── ...
    │   ├── identify/
    │   │   ├── identify_screen.dart
    │   │   └── identify_result_screen.dart
    │   ├── friends/
    │   │   ├── friends_screen.dart
    │   │   └── friend_collection_screen.dart
    │   ├── profile/
    │   │   └── profile_screen.dart  # 보호자 모드 선택, QR 섹션
    │   └── guardian/                # NEW
    │       ├── guardian_monitor_screen.dart # 보호자 활동 모니터링
    │       ├── guardian_invite_screen.dart  # QR 초대 (어린이)
    │       └── guardian_scan_screen.dart    # QR 스캔 (보호자)
    ├── widgets/
    │   ├── common/
    │   │   ├── nature_bottom_nav.dart      # 동적 탭 (5/6탭)
    │   │   └── ...
    │   ├── diary/
    │   │   ├── diary_write_sheet.dart
    │   │   └── ...
    │   ├── collection/
    │   │   └── ...
    │   ├── pet/
    │   │   └── pet_avatar.dart
    │   └── ...
    ├── router/
    │   └── app_router.dart          # DashboardScreen, GuardianMonitorScreen 라우트 추가
    ├── data/
    │   └── species_encyclopedia.dart # 6종 학술 정보 (TFLite mock)
    ├── utils/
    │   └── stats_calculator.dart
    └── ...
```

---

## 개발 환경 설정

### 필수 환경변수 (.env)

```
NAVER_MAP_CLIENT_ID=YOUR_NAVER_MAP_CLIENT_ID
NAVER_MAP_CLIENT_SECRET=YOUR_NAVER_MAP_CLIENT_SECRET
```

### iOS 특수 설정 (Info.plist)

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>nmap</string>  <!-- 네이버 지도 URL 스킴 -->
</array>
```

### 빌드 & 실행

```bash
# 의존성 설치
flutter pub get

# 빌드 러너 실행 (freezed, json_serializable 코드 생성)
flutter pub run build_runner build

# iOS 시뮬레이터 빌드
flutter run -d "iPhone 17 Pro"
```

---

## 주요 설계 결정

### 1. BLoC 패턴 채택
- 상태 관리: `flutter_bloc` (이벤트 기반)
- 이점: 테스트 용이, 확장성 강함

### 2. 동적 하단 네비게이션
- 보호자 모드: 6탭 (모니터링 탭 추가)
- 일반 모드: 5탭
- `StatefulShellRoute.indexedStack`로 구현

### 3. 네이버 지도 + URL 스킴
- 앱 내 지도 SDK: flutter_naver_map
- 외부 연동: URL 스킴 (nmap://) + 웹 폴백
- 사용자 경험 개선

### 4. 환경변수 관리
- .env 파일 (개발/프로덕션 구분)
- flutter_dotenv로 동적 로드
- 보안: .gitignore에 .env 포함

### 5. QR 기반 보호자 초대
- 보안: 8자리 코드 + 10분 만료
- 편의성: 직접 입력 옵션 제공
- 사용자 경험: 애니메이션 피드백

### 6. Haversine 공식으로 거리 계산
- 미보유 생물 정렬: 가까운 장소 우선
- 사용자의 촬영 동기 향상

---

## 향후 개선 사항

### API 연동
- 현재: Mock 데이터 (hardcoded)
- 향후: Supabase/백엔드 실제 API 연동

### 종 학술 정보 API
- 후보: 국가생물다양성 정보공유체계 (KBR), 공공데이터포털, 한반도 생물다양성 시스템
- 현재: `/data/species_encyclopedia.dart`에 6종만 정의

### 네이버 맵 내 표시
- 지도 화면 자체 내에서 마커 표시 (flutter_naver_map 활용)
- 현재: URL 스킴으로 외부 앱 실행

### 보호자 댓글 실시간 동기화
- 현재: Mock 데이터
- 향후: WebSocket 또는 Supabase Realtime

### QR 코드 유효성
- 현재: 10분 고정 만료
- 향후: 서버 검증, 사용 횟수 제한

---

## 문서 이력

| 날짜 | 버전 | 변경사항 |
|------|------|---------|
| 2026-03-05 | 1.0.0 | 초기 문서 작성 (13개 Task 정리) |

---

**최종 검토**: 2026-03-05
**다음 검토 예정**: Task 추가 시 즉시 업데이트
