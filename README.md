# 자연도감 (Nature Collection App)

> 사진으로 만나는 자연 탐험! 아이들이 동식물을 촬영하면 AI가 종을 식별하고, 나만의 컬렉션 카드로 만들어주는 교육용 앱

## 서비스 소개

**자연도감**은 아이들이 스마트폰 카메라로 실제 동식물을 촬영하면, AI가 즉시 종을 식별하여 게임 카드처럼 랜덤 스탯이 부여된 컬렉션 카드로 만들어주는 교육 플랫폼입니다.

### 핵심 기능
- **AI 자연 탐험**: 사진 촬영 → AI 종 식별 → 자동 도감 기록
- **컬렉션 카드**: 고유 ID, 랜덤 스탯(HP/공격/방어/속도/매력), 희귀도
- **카테고리 분류**: 곤충, 식물, 어류, 조류, 포유류, 파충류, 양서류, 버섯, 해양생물
- **그림일기**: 발견한 생물에 대해 그림을 그리고 음성을 녹음
- **생명 존중 교육**: "곤충 친구를 관찰한 후 자유롭게 보내줘요!" 메시지

### 향후 기능
- 카드 교환/선물 시스템
- 보호자 모드 (심리 설문, 리포트)
- AI 맞춤형 동화 생성
- 환경 보호 미션
- '함께 가요' 그룹 탐험
- 나만의 도감 책 인쇄 서비스

## 기술 스택

| 영역 | 기술 |
|------|------|
| Frontend | Flutter (iOS + Android) |
| State Management | BLoC / Cubit |
| Backend | FastAPI (Python 3.11) |
| Database | Supabase (PostgreSQL + Auth + Storage) |
| Local DB | SQLite (sqflite) |
| AI | Google Gemini Vision API |

## 프로젝트 구조

```
├── backend/          # FastAPI 서버
│   ├── app/          # 애플리케이션 코드
│   │   ├── models/   # SQLAlchemy 모델
│   │   ├── schemas/  # Pydantic 스키마
│   │   ├── routers/  # API 라우터
│   │   ├── services/ # 비즈니스 로직
│   │   └── utils/    # 유틸리티
│   └── tests/        # 테스트
├── frontend/         # Flutter 앱
│   └── lib/
│       ├── blocs/    # BLoC 상태관리
│       ├── models/   # 데이터 모델
│       ├── screens/  # 화면
│       ├── services/ # 서비스
│       └── widgets/  # 공통 위젯
└── supabase/         # DB 마이그레이션
```

## 시작하기

### 백엔드 실행
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # 환경변수 설정
uvicorn app.main:app --reload --port 8000
```

### 프론트엔드 실행
```bash
cd frontend
flutter pub get
flutter run
```

### 환경변수 설정 (`.env`)
```
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
SUPABASE_SERVICE_KEY=your_service_role_key
GEMINI_API_KEY=your_gemini_api_key
```

## 라이선스

GPL-3.0 License
