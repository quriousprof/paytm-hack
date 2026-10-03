from fastapi import FastAPI
from app.api.voice_cart import router as voice_cart_router


def create_app() -> FastAPI:
    app = FastAPI(title="Paytm Kirana Backend", version="0.1.0")
    app.include_router(voice_cart_router)
    return app
