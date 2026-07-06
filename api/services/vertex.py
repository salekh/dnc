import os
import asyncio
import logging
from typing import AsyncGenerator

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("vertex_service")

VERTEX_AVAILABLE = False
PROJECT_ID = None

try:
    import google.auth
    from google.cloud import aiplatform
    import vertexai
    from vertexai.generative_models import GenerativeModel

    # Check if google auth default works and if we have a project configured
    credentials, project = google.auth.default()
    if project:
        PROJECT_ID = project
        vertexai.init(project=project, credentials=credentials)
        VERTEX_AVAILABLE = True
        logger.info(f"Vertex AI initialized successfully. Project: {PROJECT_ID}")
    else:
        logger.warning("Vertex AI could not find project ID. Running in offline/mock mode.")
except Exception as e:
    logger.warning(f"Vertex AI initialization failed or unavailable ({e}). Running in offline/mock mode.")

# Model configurations
# gemini-3.1-pro for grading/sparring, gemini-3.5-flash for goldfish (spec-comprehension replay)
MODEL_SPARRING = "gemini-3.5-flash"
MODEL_GOLDFISH = "gemini-3.5-flash"

# Mock responses for offline mode
MOCK_INTERROGATE_RESPONSE = """{
  "compliance_status": "NON_COMPLIANT",
  "issues_detected": [
    {
      "severity": "WARNING",
      "file_path": "content/magenta-tv/plan.md",
      "line_number": 42,
      "rule_violated": "GEMINI.md requirements",
      "description": "Mock Warning: Verify that no banned libraries are imported.",
      "remediation_suggestion": "Review imports in plan.md."
    }
  ],
  "gaps_identified": [
    {
      "spec_section": "Ingestion Pipeline",
      "missing_requirement": "Clean watch history when watch percentage >= 90%",
      "suggested_fix": "Add watch percentage check to processing worker"
    }
  ]
}"""

def get_mock_goldfish_response(file_name: str, change_instruction: str, file_content: str) -> str:
    return f"""# Modified by Goldfish (Mock Mode)
# Instruction: {change_instruction}
# File: {file_name}

{file_content}

# End of Goldfish Modification
"""

async def generate_mock_stream(text: str) -> AsyncGenerator[str, None]:
    # Stream word by word or block by block to simulate real model streaming
    words = text.split(" ")
    chunk_size = 5
    for i in range(0, len(words), chunk_size):
        chunk = " ".join(words[i:i+chunk_size]) + " "
        yield chunk
        await asyncio.sleep(0.05)  # Simulate network latency

async def call_vertex_stream(model_name: str, prompt: str) -> AsyncGenerator[str, None]:
    """
    Calls Vertex AI generative model to stream response.
    If VERTEX_AVAILABLE is False, yields mock response.
    """
    if not VERTEX_AVAILABLE:
        logger.info(f"Using mock stream for model {model_name}")
        if model_name == MODEL_SPARRING:
            async for chunk in generate_mock_stream(MOCK_INTERROGATE_RESPONSE):
                yield chunk
        else:
            # We don't have request params here directly, yield a simple mock
            async for chunk in generate_mock_stream("Mock goldfish output. Complete requirements to see model replay."):
                yield chunk
        return

    try:
        logger.info(f"Calling Vertex AI model {model_name} with stream=True")
        from vertexai.generative_models import GenerativeModel
        model = GenerativeModel(model_name)
        # vertexai is typically synchronous in generator retrieval, but we run in executor or use async
        # To avoid blocking event loop, we yield chunks.
        # Note: GenerativeModel.generate_content has a stream option.
        response = model.generate_content(prompt, stream=True)
        for chunk in response:
            if chunk.text:
                yield chunk.text
    except Exception as e:
        logger.error(f"Error calling Vertex AI model {model_name}: {e}")
        raise e
