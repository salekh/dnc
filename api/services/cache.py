import os
import hashlib
import asyncio
import logging
from typing import AsyncGenerator
from api.services.vertex import (
    call_vertex_stream,
    VERTEX_AVAILABLE,
    MODEL_SPARRING,
    MODEL_GOLDFISH,
    MOCK_INTERROGATE_RESPONSE,
    get_mock_goldfish_response,
    generate_mock_stream
)

logger = logging.getLogger("cache_service")
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE_DIR = os.path.join(BASE_DIR, "cache")

# Ensure cache directory exists if writable
try:
    os.makedirs(CACHE_DIR, exist_ok=True)
except Exception as e:
    logger.warning(f"Could not create CACHE_DIR at {CACHE_DIR}: {e}")

def get_cache_key(prompt: str) -> str:
    """Generate SHA256 hash of the prompt string to use as the cache key."""
    return hashlib.sha256(prompt.strip().encode('utf-8')).hexdigest()

def get_cached_response(cache_key: str) -> str:
    """Retrieve the cached response if it exists."""
    cache_path = os.path.join(CACHE_DIR, f"{cache_key}.txt")
    if os.path.exists(cache_path):
        try:
            with open(cache_path, "r", encoding="utf-8") as f:
                return f.read()
        except Exception as e:
            logger.error(f"Error reading cache file {cache_path}: {e}")
    return None

def write_cache_response(cache_key: str, content: str) -> None:
    """Write response to cache file."""
    cache_path = os.path.join(CACHE_DIR, f"{cache_key}.txt")
    try:
        with open(cache_path, "w", encoding="utf-8") as f:
            f.write(content)
        logger.info(f"Successfully cached response to {cache_path}")
    except Exception as e:
        logger.error(f"Error writing cache file {cache_path}: {e}")

async def stream_with_cache(
    model_name: str, 
    prompt: str, 
    fallback_mock_data: str = None
) -> AsyncGenerator[str, None]:
    """
    Attempts to stream from Vertex AI with a 4-second timeout for the first chunk.
    Falls back to api/cache/ golden responses, and then to mock responses if cache is missing.
    """
    cache_key = get_cache_key(prompt)
    cached_content = get_cached_response(cache_key)
    
    if VERTEX_AVAILABLE:
        try:
            # We want to check if the stream responds within 4.0 seconds.
            # To do this, we get the async generator and await its first item.
            gen = call_vertex_stream(model_name, prompt)
            iterator = gen.__aiter__()
            
            async def get_next():
                try:
                    return await iterator.__anext__()
                except StopAsyncIteration:
                    return None
            
            # Timeout of 4.0 seconds for the first chunk
            first_chunk = await asyncio.wait_for(get_next(), timeout=4.0)
            
            if first_chunk is not None:
                yield first_chunk
                async for chunk in iterator:
                    yield chunk
                return
            else:
                logger.warning("Live model stream returned empty.")
        except asyncio.TimeoutError:
            logger.warning(f"Live model call timed out (> 4.0s) for prompt hash {cache_key}. Falling back to cache.")
        except Exception as e:
            logger.warning(f"Live model call failed for prompt hash {cache_key}. Error: {e}. Falling back to cache.")
            
    # Fallback to Golden Cache
    if cached_content is not None:
        logger.info(f"Cache HIT for prompt hash {cache_key}. Streaming cached content.")
        # Yield in chunks of 50 chars to simulate streaming
        chunk_size = 50
        for i in range(0, len(cached_content), chunk_size):
            yield cached_content[i:i+chunk_size]
            await asyncio.sleep(0.01)
        return

    # Fallback to Mock Responses if cache and live model both failed/unavailable
    logger.info(f"Cache MISS and live model unavailable for prompt hash {cache_key}. Using default mock response.")
    mock_data = fallback_mock_data or (
        MOCK_INTERROGATE_RESPONSE if model_name == MODEL_SPARRING else "Mock goldfish response."
    )
    async for chunk in generate_mock_stream(mock_data):
        yield chunk
