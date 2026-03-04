# BeatAI

A production-ready full-stack app with React frontend and Python FastAPI microservices.

## Project Structure

```
beatai/
├── frontend/              # React + TypeScript (Vite)  → :5173
├── services/
│   ├── gateway/           # API Gateway (routes to services)  → :8000
│   ├── auth/              # Auth service (JWT, OAuth)  → :8001
│   ├── billing/           # Billing & payments (Stripe)  → :8002
│   └── analytics/         # Analytics & metrics  → :8003
├── shared/                # Shared Pydantic models & utils
└── docker-compose.yml
```

## Quick Start (Docker)

```bash
# Copy env files
cp services/auth/.env.example services/auth/.env
cp services/billing/.env.example services/billing/.env
cp services/analytics/.env.example services/analytics/.env

# Run everything
docker-compose up
```

## Local Development (without Docker)

### Frontend

```bash
cd frontend
npm install
npm run dev   # → http://localhost:5173
```

### Services (run each in a separate terminal)

```bash
# Gateway
cd services/gateway
pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# Auth
cd services/auth
pip install -r requirements.txt
cp .env.example .env
uvicorn main:app --reload --port 8001

# Billing
cd services/billing
pip install -r requirements.txt
cp .env.example .env
uvicorn main:app --reload --port 8002

# Analytics
cd services/analytics
pip install -r requirements.txt
uvicorn main:app --reload --port 8003
```

## Service Ports

| Service   | Port |
|-----------|------|
| Frontend  | 5173 |
| Gateway   | 8000 |
| Auth      | 8001 |
| Billing   | 8002 |
| Analytics | 8003 |
