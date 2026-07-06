import os
import logging
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from api.services.cache import stream_with_cache
from api.services.vertex import MODEL_GOLDFISH, get_mock_goldfish_response

logger = logging.getLogger("route_goldfish")
router = APIRouter()

class GoldfishRequest(BaseModel):
    file_name: str
    change_instruction: str
    file_content: str

@router.post("/goldfish")
async def goldfish(req: GoldfishRequest):
    logger.info(f"Received goldfish request for file: {req.file_name}")
    
    # Load prompt template
    prompt_template_path = "/usr/local/google/home/sanchitalekh/Code/dnc/content/prompts/goldfish.txt"
    try:
        with open(prompt_template_path, "r", encoding="utf-8") as f:
            template = f.read()
    except Exception as e:
        logger.error(f"Error reading prompt template {prompt_template_path}: {e}")
        template = "Apply changes to {file_name} with instruction: {change_instruction}. File content:\n{file_content}"

    # Format the prompt
    prompt = (
        template.replace("{file_name}", req.file_name)
        .replace("{change_instruction}", req.change_instruction)
        .replace("{file_content}", req.file_content)
    )

    # Generate specialized mock response in case of cache miss + Vertex AI timeout/offline
    fallback_mock = get_mock_goldfish_response(
        req.file_name,
        req.change_instruction,
        req.file_content
    )

    return StreamingResponse(
        stream_with_cache(MODEL_GOLDFISH, prompt, fallback_mock_data=fallback_mock),
        media_type="text/event-stream"
    )
