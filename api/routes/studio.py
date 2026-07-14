import os
from typing import Optional
from fastapi import APIRouter, Query, HTTPException
from fastapi.responses import StreamingResponse, Response, FileResponse
from pydantic import BaseModel

from api.services.studio import (
    session_modules,
    get_specs_data,
    stream_recommender_generation
)

router = APIRouter()

class GenerateRequest(BaseModel):
    session_id: str = "default"
    tweak: Optional[str] = None

@router.get("/demo/ruby/")
@router.get("/demo/ruby/index.html")
async def serve_ruby_app():
    """Serves the Preact static shell for the Ruby TV mini-app."""
    file_path = "static_web/demo/ruby/index.html"
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Ruby TV mini-app shell not found.")
    return FileResponse(file_path, media_type="text/html")

@router.get("/demo/ruby/recommender.js")
async def serve_recommender_module(session: str = Query("default", description="Client session ID")):
    """
    Returns the currently active generated ES module for this session,
    or falls back to the golden fallback module.
    """
    if session in session_modules:
        return Response(content=session_modules[session], media_type="application/javascript")
    
    fallback_path = "static_web/demo/ruby/recommender.js"
    if not os.path.exists(fallback_path):
        raise HTTPException(status_code=404, detail="Golden fallback recommender.js not found.")
    
    with open(fallback_path, "r", encoding="utf-8") as f:
        content = f.read()
    return Response(content=content, media_type="application/javascript")

@router.post("/studio/generate")
async def generate_studio_recommender(req: GenerateRequest):
    """
    Streams Gemini 3.1 Pro output via SSE. On completion, writes to the per-session store.
    """
    return StreamingResponse(
        stream_recommender_generation(req.session_id, req.tweak),
        media_type="text/event-stream"
    )

@router.get("/studio/state")
async def get_studio_state(session_id: str = Query("default")):
    """Returns what version of the recommender is currently active for this session."""
    has_custom = session_id in session_modules
    return {
        "session_id": session_id,
        "active_version": "generated" if has_custom else "golden_fallback",
        "has_custom_module": has_custom
    }

@router.get("/studio/specs")
async def list_studio_specs():
    """Returns the list of specification stack files and their content/token count."""
    return {"specs": get_specs_data()}
