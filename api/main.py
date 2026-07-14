import time
import logging
from collections import defaultdict
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, FileResponse, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from api.routes import interrogate, goldfish, cache, studio

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("main")

app = FastAPI(
    title="dintc Backend API",
    description="FastAPI backend serving agent-driven scrollytelling and specifications code generation.",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust as needed for specific deployment requirements
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Per-IP Rate Limiting (10 requests per minute)
RATE_LIMIT_MAX_REQUESTS = 50  # Increased for UI streaming and frequent interactive requests
RATE_LIMIT_WINDOW_SECONDS = 60
ip_request_history = defaultdict(list)

@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    client_ip = request.client.host if request.client else "unknown"
    now = time.time()
    
    # Filter out requests older than the rate limit window
    ip_request_history[client_ip] = [
        timestamp for timestamp in ip_request_history[client_ip]
        if now - timestamp < RATE_LIMIT_WINDOW_SECONDS
    ]
    
    if len(ip_request_history[client_ip]) >= RATE_LIMIT_MAX_REQUESTS:
        logger.warning(f"Rate limit exceeded for IP: {client_ip}")
        return JSONResponse(
            status_code=429,
            content={"detail": f"Rate limit exceeded. Maximum {RATE_LIMIT_MAX_REQUESTS} requests per minute."}
        )
        
    ip_request_history[client_ip].append(now)
    return await call_next(request)

# Mount Routes
app.include_router(interrogate.router, prefix='/api')
app.include_router(goldfish.router, prefix='/api')
app.include_router(cache.router, prefix='/api')
app.include_router(studio.router, prefix='/api')
app.include_router(studio.router)  # For root-level /demo/ruby/... endpoints

@app.get("/health")
def health_check():
    return {"status": "ok", "timestamp": time.time()}

@app.get("/")
async def serve_root():
    return FileResponse("static_web/index.html")

@app.get("/flutter_service_worker.js")
async def serve_dummy_sw():
    js_content = """self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', () => self.registration.unregister());
"""
    return Response(content=js_content, media_type="application/javascript")

@app.get("/favicon.ico")
async def serve_favicon():
    return Response(status_code=204)

# Mount static_web to serve presentation assets, css, js, and html
app.mount("/", StaticFiles(directory="static_web", html=True), name="static_web")

if __name__ == "__main__":
    import uvicorn
    # Run server locally on port 8000
    uvicorn.run("api.main:app", host="0.0.0.0", port=8000, reload=True)

