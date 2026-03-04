#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# BeatAI — Google Cloud Run Deploy Script
# ─────────────────────────────────────────────
# Prerequisites:
#   1. Install gcloud CLI: https://cloud.google.com/sdk/docs/install
#   2. Run: gcloud auth login
#   3. Set PROJECT_ID below (or pass as env var)
# ─────────────────────────────────────────────

PROJECT_ID="${GCP_PROJECT_ID:-}"
REGION="${GCP_REGION:-us-central1}"
REPO="beatai"
REGISTRY="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}"

SERVICES=("gateway" "auth" "billing" "analytics")
PORTS=(8000 8001 8002 8003)

if [[ -z "$PROJECT_ID" ]]; then
  echo "ERROR: Set GCP_PROJECT_ID environment variable or edit this script."
  echo "  export GCP_PROJECT_ID=your-project-id"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Project : $PROJECT_ID"
echo "  Region  : $REGION"
echo "  Registry: $REGISTRY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Set active project ─────────────────────
gcloud config set project "$PROJECT_ID"

# ── 2. Enable required APIs ───────────────────
echo "▶ Enabling APIs..."
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  --quiet

# ── 3. Create Artifact Registry repo ─────────
echo "▶ Creating Artifact Registry repository..."
gcloud artifacts repositories create "$REPO" \
  --repository-format=docker \
  --location="$REGION" \
  --quiet 2>/dev/null || echo "  (repo already exists, skipping)"

# ── 4. Auth Docker with Artifact Registry ────
echo "▶ Configuring Docker auth..."
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

# ── 5. Build & push backend services ─────────
echo ""
echo "▶ Building and pushing backend services..."

for i in "${!SERVICES[@]}"; do
  SVC="${SERVICES[$i]}"
  echo "  → $SVC"
  docker build -t "${REGISTRY}/${SVC}:latest" "services/${SVC}"
  docker push "${REGISTRY}/${SVC}:latest"
done

# ── 6. Deploy backend services to Cloud Run ──
echo ""
echo "▶ Deploying backend services to Cloud Run..."

for i in "${!SERVICES[@]}"; do
  SVC="${SERVICES[$i]}"
  PORT="${PORTS[$i]}"
  echo "  → $SVC (port $PORT)"
  gcloud run deploy "$SVC" \
    --image "${REGISTRY}/${SVC}:latest" \
    --platform managed \
    --region "$REGION" \
    --port "$PORT" \
    --allow-unauthenticated \
    --quiet
done

# ── 7. Get gateway URL ────────────────────────
GATEWAY_URL=$(gcloud run services describe gateway \
  --platform managed \
  --region "$REGION" \
  --format "value(status.url)")

echo ""
echo "  Gateway URL: $GATEWAY_URL"

# ── 8. Build & push frontend (with gateway URL baked in) ──
echo ""
echo "▶ Building frontend..."
docker build \
  --build-arg VITE_API_URL="$GATEWAY_URL" \
  -t "${REGISTRY}/frontend:latest" \
  frontend/

docker push "${REGISTRY}/frontend:latest"

# ── 9. Deploy frontend to Cloud Run ──────────
echo "▶ Deploying frontend..."
gcloud run deploy frontend \
  --image "${REGISTRY}/frontend:latest" \
  --platform managed \
  --region "$REGION" \
  --port 8080 \
  --allow-unauthenticated \
  --quiet

# ── 10. Print URLs ────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Deployment complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for SVC in frontend gateway auth billing analytics; do
  URL=$(gcloud run services describe "$SVC" \
    --platform managed \
    --region "$REGION" \
    --format "value(status.url)" 2>/dev/null || echo "not deployed")
  printf "  %-12s %s\n" "$SVC" "$URL"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
