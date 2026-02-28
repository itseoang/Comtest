from fastapi import APIRouter, HTTPException, UploadFile, File, Query, Header
from app.database import get_supabase
from app.schemas.species import SpeciesResponse, SpeciesIdentifyResponse, SpeciesListResponse
from app.services.ai_identifier import identify_species
from app.services.card_generator import generate_stats

router = APIRouter()


@router.get("", response_model=SpeciesListResponse)
async def list_species(
    category: str | None = Query(None, description="카테고리 필터"),
    search: str | None = Query(None, description="검색어 (한국어명)"),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """종 목록 조회"""
    sb = get_supabase()
    query = sb.table("species").select("*", count="exact")

    if category:
        query = query.eq("category", category)
    if search:
        query = query.ilike("korean_name", f"%{search}%")

    result = query.range(offset, offset + limit - 1).execute()

    return SpeciesListResponse(
        items=[SpeciesResponse(**item) for item in result.data],
        total=result.count or len(result.data),
        category=category,
    )


@router.get("/{species_id}", response_model=SpeciesResponse)
async def get_species(species_id: int):
    """종 상세 조회"""
    sb = get_supabase()
    try:
        result = sb.table("species").select("*").eq("id", species_id).single().execute()
        return SpeciesResponse(**result.data)
    except Exception:
        raise HTTPException(status_code=404, detail="종 정보를 찾을 수 없습니다.")


@router.post("/identify", response_model=SpeciesIdentifyResponse)
async def identify(
    image: UploadFile = File(..., description="식별할 동식물 사진"),
    authorization: str = Header(...),
):
    """AI로 동식물 사진을 분석하여 종을 식별합니다."""
    sb = get_supabase()

    # 인증 확인
    token = authorization.replace("Bearer ", "")
    user = sb.auth.get_user(token)
    if not user or not user.user:
        raise HTTPException(status_code=401, detail="인증이 필요합니다.")

    # 이미지 읽기
    content = await image.read()
    if len(content) > 10 * 1024 * 1024:  # 10MB 제한
        raise HTTPException(status_code=400, detail="이미지 크기는 10MB 이하여야 합니다.")

    content_type = image.content_type or "image/jpeg"
    if not content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")

    # AI 식별
    try:
        ai_result = await identify_species(content, content_type)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI 식별 중 오류가 발생했습니다: {str(e)}")

    # DB에서 기존 종 검색
    is_new = False
    existing = (
        sb.table("species")
        .select("*")
        .ilike("korean_name", ai_result["korean_name"])
        .execute()
    )

    if existing.data:
        species_data = existing.data[0]
    else:
        # 신규 종 등록
        new_species = {
            "korean_name": ai_result["korean_name"],
            "scientific_name": ai_result.get("scientific_name"),
            "category": ai_result.get("category", "insect"),
            "subcategory": ai_result.get("subcategory"),
            "description": ai_result.get("description"),
            "habitat": ai_result.get("habitat"),
            "rarity_tier": ai_result.get("rarity_tier", 1),
            "fun_fact": ai_result.get("fun_fact"),
            "eco_message": ai_result.get("eco_message"),
        }
        result = sb.table("species").insert(new_species).execute()
        species_data = result.data[0]
        is_new = True

    species = SpeciesResponse(**species_data)
    suggested_stats = generate_stats(species.rarity_tier, species.category)

    return SpeciesIdentifyResponse(
        species=species,
        confidence=ai_result.get("confidence", 0.8),
        suggested_stats=suggested_stats,
        is_new_species=is_new,
    )
