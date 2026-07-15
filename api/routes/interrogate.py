import os
import logging
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from api.services.cache import stream_with_cache
from api.services.vertex import MODEL_SPARRING, MOCK_INTERROGATE_RESPONSE

logger = logging.getLogger("route_interrogate")
router = APIRouter()

class InterrogateRequest(BaseModel):
    spec_path: str
    spec_content: str
    target_files: str
    target_files_content: str

@router.post("/interrogate")
async def interrogate(req: InterrogateRequest):
    logger.info(f"Received interrogate request for spec: {req.spec_path}")
    
    # Load prompt template
    prompt_template_path = os.path.join("content", "prompts", "interrogate.txt")
    try:
        with open(prompt_template_path, "r", encoding="utf-8") as f:
            template = f.read()
    except Exception as e:
        logger.error(f"Error reading prompt template {prompt_template_path}: {e}")
        # Simplistic fallback template in case file reading fails
        template = "Verify spec {spec_path} with contents:\n{spec_content}\n\nAgainst targets {target_files} with contents:\n{target_files_content}"

    # Format the prompt
    prompt = (
        template.replace("{spec_path}", req.spec_path)
        .replace("{spec_content}", req.spec_content)
        .replace("{target_files}", req.target_files)
        .replace("{target_files_content}", req.target_files_content)
    )

    return StreamingResponse(
        stream_with_cache(MODEL_SPARRING, prompt, fallback_mock_data=MOCK_INTERROGATE_RESPONSE),
        media_type="text/event-stream"
    )
