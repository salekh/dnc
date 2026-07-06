#!/usr/bin/env python3
import os
import sys
import hashlib
import logging

# Ensure api directory is in python path
sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("refresh_cache")

# Set paths
BASE_DIR = "/usr/local/google/home/sanchitalekh/Code/dnc"
CACHE_DIR = os.path.join(BASE_DIR, "api", "cache")
PROMPTS_DIR = os.path.join(BASE_DIR, "content", "prompts")
MAGENTA_DIR = os.path.join(BASE_DIR, "content", "magenta-tv")

os.makedirs(CACHE_DIR, exist_ok=True)

# Try importing vertex service components
from api.services.vertex import (
    VERTEX_AVAILABLE,
    MODEL_SPARRING,
    MODEL_GOLDFISH,
    MOCK_INTERROGATE_RESPONSE,
    get_mock_goldfish_response
)
from api.services.cache import get_cache_key, write_cache_response

def load_file(path):
    if not os.path.exists(path):
        logger.error(f"Required file does not exist: {path}")
        return ""
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def generate_key_prompts():
    """Generates the list of key prompts we want to pre-cache."""
    prompts_to_cache = []

    # 1. INTERROGATE PROMPT: MagentaTV spec vs targets
    interrogate_template = load_file(os.path.join(PROMPTS_DIR, "interrogate.txt"))
    spec_path = os.path.join(MAGENTA_DIR, "spec.md")
    spec_content = load_file(spec_path)
    
    target_files = [
        os.path.join(MAGENTA_DIR, "prd.md"),
        os.path.join(MAGENTA_DIR, "design.md"),
        os.path.join(MAGENTA_DIR, "plan.md"),
        os.path.join(MAGENTA_DIR, "GEMINI.md"),
        os.path.join(MAGENTA_DIR, "runbook.md"),
    ]
    
    target_files_content = ""
    for path in target_files:
        name = os.path.basename(path)
        content = load_file(path)
        target_files_content += f"File: {name}\n---\n{content}\n---\n\n"

    target_paths_str = ", ".join([os.path.basename(p) for p in target_files])

    if interrogate_template:
        interrogate_prompt = (
            interrogate_template.replace("{spec_path}", "content/magenta-tv/spec.md")
            .replace("{spec_content}", spec_content)
            .replace("{target_files}", target_paths_str)
            .replace("{target_files_content}", target_files_content)
        )
        prompts_to_cache.append({
            "model": MODEL_SPARRING,
            "prompt": interrogate_prompt,
            "type": "interrogate",
            "description": "MagentaTV Spec Interrogation",
            "mock_fallback": MOCK_INTERROGATE_RESPONSE
        })

    # 2. GOLDFISH PROMPT: Modify plan.md to add post-monitoring phase
    goldfish_template = load_file(os.path.join(PROMPTS_DIR, "goldfish.txt"))
    plan_path = os.path.join(MAGENTA_DIR, "plan.md")
    plan_content = load_file(plan_path)

    if goldfish_template and plan_content:
        inst_1 = "Add Phase 7: Post-deployment monitoring and logging validation."
        goldfish_prompt_1 = (
            goldfish_template.replace("{file_name}", "plan.md")
            .replace("{change_instruction}", inst_1)
            .replace("{file_content}", plan_content)
        )
        mock_goldfish_1 = get_mock_goldfish_response("plan.md", inst_1, plan_content)
        prompts_to_cache.append({
            "model": MODEL_GOLDFISH,
            "prompt": goldfish_prompt_1,
            "type": "goldfish",
            "description": "MagentaTV Plan Modification (Phase 7)",
            "mock_fallback": mock_goldfish_1
        })

    # 3. GOLDFISH PROMPT: Update CTR target in design.md
    design_path = os.path.join(MAGENTA_DIR, "design.md")
    design_content = load_file(design_path)

    if goldfish_template and design_content:
        inst_2 = "Update CTR lift target from 3.5% to 5.0%."
        goldfish_prompt_2 = (
            goldfish_template.replace("{file_name}", "design.md")
            .replace("{change_instruction}", inst_2)
            .replace("{file_content}", design_content)
        )
        mock_goldfish_2 = get_mock_goldfish_response("design.md", inst_2, design_content)
        prompts_to_cache.append({
            "model": MODEL_GOLDFISH,
            "prompt": goldfish_prompt_2,
            "type": "goldfish",
            "description": "MagentaTV Design Modification (CTR Target)",
            "mock_fallback": mock_goldfish_2
        })

    return prompts_to_cache

def main():
    prompts = generate_key_prompts()
    
    if not VERTEX_AVAILABLE:
        logger.warning("Vertex AI is offline (no credentials/project). Populating cache with mock responses for offline usage...")
        for p in prompts:
            key = get_cache_key(p["prompt"])
            write_cache_response(key, p["mock_fallback"])
            logger.info(f"Populated cache key {key} ({p['description']}) with mock data.")
        logger.info("Offline cache population completed.")
        return

    logger.info("Vertex AI is available. Querying real models to populate cache...")
    try:
        from vertexai.generative_models import GenerativeModel
        for p in prompts:
            key = get_cache_key(p["prompt"])
            logger.info(f"Querying {p['model']} for key {key} ({p['description']})...")
            try:
                model = GenerativeModel(p["model"])
                # Request response synchronously for caching
                response = model.generate_content(p["prompt"])
                if response.text:
                    write_cache_response(key, response.text)
                else:
                    logger.warning(f"Empty response returned for {key}. Using mock fallback.")
                    write_cache_response(key, p["mock_fallback"])
            except Exception as e:
                logger.error(f"Failed to query model for key {key}: {e}. Writing mock fallback.")
                write_cache_response(key, p["mock_fallback"])
        logger.info("Vertex AI cache population completed successfully.")
    except Exception as e:
        logger.error(f"Error initializing or running Vertex cache build: {e}")

if __name__ == "__main__":
    main()
