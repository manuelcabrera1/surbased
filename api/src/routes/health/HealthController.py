from fastapi import APIRouter


health_router = APIRouter()

@health_router.get("/health", tags=["health"], status_code=200)
async def health():
    return {"status": "ok"}