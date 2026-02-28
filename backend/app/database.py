from supabase import create_client, Client
from app.config import get_settings

_supabase_client: Client | None = None


def get_supabase() -> Client:
    global _supabase_client
    if _supabase_client is None:
        settings = get_settings()
        _supabase_client = create_client(
            settings.supabase_url,
            settings.supabase_service_key or settings.supabase_key,
        )
    return _supabase_client


def get_supabase_anon() -> Client:
    """Anonymous client for user-facing operations."""
    settings = get_settings()
    return create_client(settings.supabase_url, settings.supabase_key)
