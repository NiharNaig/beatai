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
├── docker-compose.yml
└── deploy.sh              # Google Cloud Run deploy script
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

## Deploying to Google Cloud Run

### 1. Install gcloud CLI

```bash
# macOS
brew install google-cloud-sdk

# Or download: https://cloud.google.com/sdk/docs/install
```

### 2. Login and create a project

```bash
gcloud auth login
gcloud projects create beatai-prod --name="BeatAI"
```

> Copy the project ID — you'll need it next.

### 3. Deploy

```bash
export GCP_PROJECT_ID=beatai-prod   # your project ID
./deploy.sh
```

The script will:
1. Enable Cloud Run + Artifact Registry APIs
2. Build and push all Docker images
3. Deploy each service to Cloud Run
4. Print all public URLs when done

### 4. Set secrets in Cloud Run

After deploying, add your real secrets via the GCP Console or:

```bash
# Example: set Stripe key on billing service
gcloud run services update billing \
  --region us-central1 \
  --set-env-vars STRIPE_SECRET_KEY=sk_live_...
```
