"""Minimal FastAPI scaffolding for the MVP."""


from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse

app = FastAPI()


@app.get("/api/hello")
def hello():
    return {"message": "Hello from the backend!"}


@app.get("/")
def index():
    return HTMLResponse(
        "<!DOCTYPE html><html><head><title>Project Management</title></head>"
        "<body><h1>Project Management App</h1>"
        "<p>Backend is running. Frontend will be served in a later step.</p>"
        "</body></html>"
    )
