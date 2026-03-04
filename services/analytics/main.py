from fastapi import FastAPI

app = FastAPI(title="BeatAI Analytics Service", version="0.1.0")


@app.get("/health")
def health():
    return {"status": "ok", "service": "analytics"}


# Routes: /events, /metrics, /dashboards
