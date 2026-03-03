# BeatAI

A full-stack app with React (Vite + TypeScript) frontend and FastAPI (Python) backend.

## Project Structure

```
beatai/
├── frontend/   # React + TypeScript (Vite)
└── backend/    # Python FastAPI
```

## Getting Started

### Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
uvicorn main:app --reload
```

Backend runs at: http://localhost:8000

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend runs at: http://localhost:5173
