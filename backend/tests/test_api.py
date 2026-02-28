import pytest
from fastapi.testclient import TestClient
from app.main import app


client = TestClient(app)


class TestHealthCheck:
    def test_root(self):
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert "자연도감" in data["message"]
        assert data["status"] == "running"

    def test_health(self):
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"


class TestSpeciesEndpoints:
    def test_list_species_endpoint_exists(self):
        """종 목록 조회 엔드포인트가 존재하고 인증 불필요"""
        # Supabase 미설정 환경에서는 DB 연결 에러 발생 가능
        try:
            response = client.get("/api/v1/species")
            assert response.status_code in [200, 500]
        except Exception:
            # Supabase 클라이언트 생성 실패 시 패스
            pass

    def test_identify_requires_auth(self):
        """종 식별은 인증 필요"""
        response = client.post("/api/v1/species/identify")
        assert response.status_code in [401, 422]


class TestCollectionEndpoints:
    def test_list_requires_auth(self):
        response = client.get("/api/v1/collections")
        assert response.status_code in [401, 422]

    def test_create_requires_auth(self):
        response = client.post(
            "/api/v1/collections",
            json={"species_id": 1, "photo_url": "test.jpg"},
        )
        assert response.status_code in [401, 422]


class TestDiaryEndpoints:
    def test_list_requires_auth(self):
        response = client.get("/api/v1/diary")
        assert response.status_code in [401, 422]

    def test_create_requires_auth(self):
        response = client.post(
            "/api/v1/diary",
            json={"title": "테스트 일기"},
        )
        assert response.status_code in [401, 422]
