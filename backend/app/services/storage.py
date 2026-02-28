import uuid
from app.database import get_supabase


async def upload_image(
    bucket: str,
    image_bytes: bytes,
    content_type: str = "image/jpeg",
    folder: str = "",
) -> str:
    """Supabase Storage에 이미지를 업로드하고 공개 URL을 반환합니다.

    Args:
        bucket: 스토리지 버킷 이름 ('collection-photos', 'diary-drawings', 등)
        image_bytes: 이미지 바이트
        content_type: MIME 타입
        folder: 하위 폴더 경로

    Returns:
        업로드된 이미지의 공개 URL
    """
    sb = get_supabase()

    ext = "jpg"
    if "png" in content_type:
        ext = "png"
    elif "webp" in content_type:
        ext = "webp"

    filename = f"{uuid.uuid4().hex}.{ext}"
    path = f"{folder}/{filename}" if folder else filename

    sb.storage.from_(bucket).upload(
        path,
        image_bytes,
        file_options={"content-type": content_type},
    )

    public_url = sb.storage.from_(bucket).get_public_url(path)
    return public_url


async def delete_image(bucket: str, path: str) -> bool:
    """Supabase Storage에서 이미지를 삭제합니다."""
    sb = get_supabase()
    try:
        sb.storage.from_(bucket).remove([path])
        return True
    except Exception:
        return False
