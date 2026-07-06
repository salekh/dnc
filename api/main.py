import time
import logging
from collections import defaultdict
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

from api.routes import interrogate, goldfish, cache

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
RATE_LIMIT_MAX_REQUESTS = 10
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

@app.get("/health")
def health_check():
    return {"status": "ok", "timestamp": time.time()}

if __name__ == "__main__":
    import uvicorn
    # Run server locally on port 8000
    uvicorn.run("api.main:app", host="0.0.0.0", port=8000, reload=True)
