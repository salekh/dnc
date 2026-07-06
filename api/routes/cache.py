import os
import logging
from fastapi import APIRouter, HTTPException, status
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel
from api.services.cache import CACHE_DIR, get_cache_key, get_cached_response

logger = logging.getLogger("route_cache")
router = APIRouter()

class CacheLookupRequest(BaseModel):
    prompt: str

@router.get("/cache")
def list_cache_keys():
    """List all available cached response keys (hashes)."""
    try:
        files = os.listdir(CACHE_DIR)
        keys = [f[:-4] for f in files if f.endswith(".txt")]
        return {"cache_directory": CACHE_DIR, "cached_keys_count": len(keys), "keys": keys}
    except Exception as e:
        logger.error(f"Failed to list cache: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to list cache directory: {e}"
        )

@router.get("/cache/{cache_key}", response_class=PlainTextResponse)
def get_cache_by_key(cache_key: str):
    """Retrieve raw cached content for a specific cache key."""
    content = get_cached_response(cache_key)
    if content is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Cache key {cache_key} not found."
        )
    return content

@router.post("/cache/lookup")
def lookup_cache_by_prompt(req: CacheLookupRequest):
    """Look up if a prompt is cached and return the key and availability."""
    key = get_cache_key(req.prompt)
    content = get_cached_response(key)
    exists = content is not None
    return {
        "cache_key": key,
        "exists": exists,
        "content_preview": content[:200] + "..." if exists else None
    }
