from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import get_settings
from app.routers import auth, species, collections, diary

settings = get_settings()

app = FastAPI(
    title="자연도감 API",
    description="Nature Collection App - AI 기반 동식물 도감 서비스",
    version="0.1.0",
    docs_url="/docs" if settings.is_development else None,
    redoc_url="/redoc" if settings.is_development else None,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1/auth", tags=["인증"])
app.include_router(species.router, prefix="/api/v1/species", tags=["종 정보"])
app.include_router(collections.router, prefix="/api/v1/collections", tags=["컬렉션"])
app.include_router(diary.router, prefix="/api/v1/diary", tags=["그림일기"])


@app.get("/")
async def root():
    return {"message": "자연도감 API v0.1.0", "status": "running"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
