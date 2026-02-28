from fastapi import APIRouter, HTTPException, Header, Query
from app.database import get_supabase
from app.schemas.collection import (
    CollectionCreate,
    CollectionResponse,
    CollectionUpdate,
    CollectionListResponse,
)

router = APIRouter()


def _get_user_id(authorization: str) -> str:
    sb = get_supabase()
    token = authorization.replace("Bearer ", "")
    user = sb.auth.get_user(token)
    if not user or not user.user:
        raise HTTPException(status_code=401, detail="인증이 필요합니다.")
    return user.user.id


@router.post("", response_model=CollectionResponse, status_code=201)
async def create_collection(data: CollectionCreate, authorization: str = Header(...)):
    """새 컬렉션 카드 생성"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    # 종 존재 확인
    try:
        sb.table("species").select("id").eq("id", data.species_id).single().execute()
    except Exception:
        raise HTTPException(status_code=404, detail="종 정보를 찾을 수 없습니다.")

    insert_data = {
        "user_id": user_id,
        "species_id": data.species_id,
        "photo_url": data.photo_url,
        "thumbnail_url": data.thumbnail_url,
        "gps_latitude": data.gps_latitude,
        "gps_longitude": data.gps_longitude,
        "location_name": data.location_name,
        "stats": data.stats.model_dump() if data.stats else {},
        "original_owner_id": user_id,
        "co_discoverers": data.co_discoverers,
        "notes": data.notes,
    }

    result = sb.table("collections").insert(insert_data).execute()
    collection = result.data[0]

    # 소유권 이력 기록 (최초 발견)
    sb.table("ownership_history").insert(
        {
            "collection_id": collection["id"],
            "from_user_id": None,
            "to_user_id": user_id,
            "transfer_type": "discovery",
        }
    ).execute()

    return CollectionResponse(**collection)


@router.get("", response_model=CollectionListResponse)
async def list_collections(
    authorization: str = Header(...),
    category: str | None = Query(None, description="카테고리 필터"),
    sort: str = Query("discovered_at", description="정렬 기준"),
    order: str = Query("desc", pattern="^(asc|desc)$"),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """내 컬렉션 목록 조회"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    query = (
        sb.table("collections")
        .select("*, species(korean_name, category, color_code)", count="exact")
        .eq("user_id", user_id)
    )

    if category:
        query = query.eq("species.category", category)

    is_desc = order == "desc"
    query = query.order(sort, desc=is_desc).range(offset, offset + limit - 1)

    result = query.execute()

    items = []
    for item in result.data:
        species_info = item.pop("species", {}) or {}
        items.append(
            CollectionResponse(
                **item,
                species_name=species_info.get("korean_name"),
                species_category=species_info.get("category"),
                species_color=species_info.get("color_code"),
            )
        )

    return CollectionListResponse(
        items=items,
        total=result.count or len(items),
    )


@router.get("/{collection_id}", response_model=CollectionResponse)
async def get_collection(collection_id: str, authorization: str = Header(...)):
    """컬렉션 카드 상세 조회"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    try:
        result = (
            sb.table("collections")
            .select("*, species(korean_name, category, color_code)")
            .eq("id", collection_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(status_code=404, detail="카드를 찾을 수 없습니다.")

    data = result.data
    # 본인 카드이거나 공개 카드인 경우만 조회 허용
    if data["user_id"] != user_id and not data.get("is_public"):
        raise HTTPException(status_code=403, detail="접근 권한이 없습니다.")

    species_info = data.pop("species", {}) or {}
    return CollectionResponse(
        **data,
        species_name=species_info.get("korean_name"),
        species_category=species_info.get("category"),
        species_color=species_info.get("color_code"),
    )


@router.put("/{collection_id}", response_model=CollectionResponse)
async def update_collection(
    collection_id: str, data: CollectionUpdate, authorization: str = Header(...)
):
    """컬렉션 카드 수정 (메모, 공개설정)"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    # 소유권 확인
    try:
        existing = (
            sb.table("collections")
            .select("user_id")
            .eq("id", collection_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(status_code=404, detail="카드를 찾을 수 없습니다.")

    if existing.data["user_id"] != user_id:
        raise HTTPException(status_code=403, detail="본인의 카드만 수정할 수 있습니다.")

    update_data = data.model_dump(exclude_none=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="수정할 데이터가 없습니다.")

    result = (
        sb.table("collections")
        .update(update_data)
        .eq("id", collection_id)
        .execute()
    )

    updated = (
        sb.table("collections")
        .select("*, species(korean_name, category, color_code)")
        .eq("id", collection_id)
        .single()
        .execute()
    )

    item = updated.data
    species_info = item.pop("species", {}) or {}
    return CollectionResponse(
        **item,
        species_name=species_info.get("korean_name"),
        species_category=species_info.get("category"),
        species_color=species_info.get("color_code"),
    )


@router.delete("/{collection_id}")
async def delete_collection(collection_id: str, authorization: str = Header(...)):
    """컬렉션 카드 삭제"""
    sb = get_supabase()
    user_id = _get_user_id(authorization)

    try:
        existing = (
            sb.table("collections")
            .select("user_id")
            .eq("id", collection_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(status_code=404, detail="카드를 찾을 수 없습니다.")

    if existing.data["user_id"] != user_id:
        raise HTTPException(status_code=403, detail="본인의 카드만 삭제할 수 있습니다.")

    sb.table("collections").delete().eq("id", collection_id).execute()
    return {"message": "카드가 삭제되었습니다."}
