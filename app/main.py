from fastapi import FastAPI
from .api import router
from .db import init_db

app = FastAPI()

@app.on_event("startup")
def on_startup():
    init_db()

app.include_router(router, prefix="/api")