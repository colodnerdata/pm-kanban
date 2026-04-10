# Architecture

Technical reference for the Project Management MVP. Read this before making changes to understand the conventions and decisions in place.

## System overview

```
Browser
  └── http://localhost:8000
        └── FastAPI (Python 3.12, uvicorn)
              ├── GET /          → serves Next.js static export (frontend/out/)
              ├── GET /api/*     → board and card CRUD
              ├── POST /api/chat → AI chat via OpenRouter
              └── SQLite         → backend/data/pm.db
```

The frontend is a Next.js static export. FastAPI serves it as static files and handles all API routes on the same origin, so there are no CORS issues.

## Request flow

1. User opens `http://localhost:8000`.
2. FastAPI serves `frontend/out/index.html`.
3. Next.js SPA boots; `page.tsx` checks auth state.
4. If authenticated, `page.tsx` calls `GET /api/board` to load data.
5. All subsequent board mutations (add, move, rename, delete) call `/api/*` endpoints.
6. The catch-all route `/{full_path:path}` in `routes/static.py` returns `index.html` for any unknown path, enabling SPA navigation.

## Authentication

MVP authentication is intentionally minimal:
- Credentials (`user` / `password`) are validated **client-side** in `page.tsx`.
- On success, `isAuthenticated` is set to `true` in React state.
- The `username` string is passed to every API call as the `X-User` HTTP request header.
- The backend `get_username()` dependency reads `X-User`, defaulting to `"user"` if absent.
- There is no server session, no JWT, and no cookie.

This is sufficient for a single-user local MVP. See `docs/FUTURE_IDEAS.md` for a real auth upgrade path.

## ID convention

SQLite uses auto-increment integer primary keys. The frontend prefixes these for use in @dnd-kit, which requires unique IDs across all droppable/draggable elements:

- Columns: `col-{id}` — created with `toColumnId(id)`, stripped with `fromColumnId(prefixedId)`
- Cards: `card-{id}` — created with `toCardId(id)`, stripped with `fromCardId(prefixedId)`

All helpers live in `frontend/src/lib/kanban.ts`. The prefix is stripped before every API call. Never pass prefixed IDs to the backend.

## Board state ownership

`page.tsx` owns all board state (`board`, `setBoard`). `KanbanBoard` is a controlled component that receives `board` and `onBoardChange` as props and fires callbacks (`onRenameColumn`, `onAddCard`, `onDeleteCard`, `onMoveCard`) for mutations. `page.tsx` calls the API and then refreshes the board from the server.

## Database patterns

- Connection per request via `get_db()` dependency; closed in `finally`.
- `PRAGMA foreign_keys = ON` set on every connection — required for FK constraints to be enforced.
- All SQL queries use parameterized placeholders (`?`) — never format user data into query strings.
- Dynamic table names (in `resequence_positions`) are validated against `VALID_TABLES` before use.
- Position resequencing is done in-process: fetch all sibling IDs, reorder in Python, write back with sequential integers starting at 0.
- All mutations commit in a single `conn.commit()` at the end of the route handler.

## Static file serving

`routes/static.py` handles three cases:

1. `/` — serves `frontend/out/index.html` (or fallback HTML if no static dir).
2. `/{known file}` — serves the file directly from `frontend/out/`.
3. `/{unknown path}` — returns `index.html` for SPA client-side routing.

`_next/` and `static/` asset directories are mounted as `StaticFiles` in `main.py` for efficient serving.

## Docker setup

The Dockerfile is a two-stage build:
- **Stage 1 (node:20-slim):** installs Node deps, runs `next build` to produce `frontend/out/`.
- **Stage 2 (python:3.12-slim):** installs `uv`, installs Python deps from `requirements.txt`, copies backend code and the built frontend, runs `uvicorn`.

The container:
- Runs as non-root user `appuser`.
- Exposes port 8000.
- Has a `HEALTHCHECK` at `/health`.
- Loads `.env` via `--env-file` in the start scripts (optional).

## Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `OPENROUTER_API_KEY` | — | Required for AI chat features |
| `OPENROUTER_BASE_URL` | `https://openrouter.ai/api/v1` | OpenRouter API base URL |
| `OPENROUTER_MODEL` | `openai/gpt-oss-120b` | Model used for chat |
| `OPENROUTER_TEMPERATURE` | `0` | Sampling temperature |
| `PM_DB_PATH` | `backend/data/pm.db` | SQLite file location |
| `PM_STATIC_DIR` | auto-detected | Override for frontend static dir |
| `PM_BASE_URL` | — | Used in integration tests only |

## Testing strategy

### Backend unit tests
- Use `tmp_path` pytest fixture + `PM_DB_PATH` env var for an isolated per-test database.
- `TestClient(app)` from Starlette; lifespan not triggered — `init_db()` called explicitly in helpers.
- Require Python 3.12; run inside the Docker container.

### Backend integration tests (`tests/test_integration.py`)
- Hit the live running container via HTTP.
- Skipped automatically when `PM_BASE_URL` is not set.
- Run with: `docker exec -e PM_BASE_URL=http://localhost:8000 pm-app python -m pytest backend/tests/test_integration.py -v`

### Frontend unit tests
- Vitest + jsdom + @testing-library/react.
- Mock `fetch` for API calls.
- Run locally with Node 20+: `cd frontend && npm run test:unit`.

### Frontend E2E tests
- Playwright against the backend-served app at port 8000.
- Require the Docker container to be running.
- Run with: `cd frontend && npm run test:e2e`

## Coding standards

- No over-engineering — build only what the task requires.
- No speculative abstractions — three similar lines of code is better than a premature helper.
- No extra error handling for impossible cases — trust internal guarantees.
- No emojis in any file.
- SQL: parameterized queries only; validate dynamic identifiers against a whitelist.
- Python: type hints on all function signatures; Pydantic for all request/response models.
- TypeScript: strict mode enabled; no `any`.
- Commits: small, focused, and passing tests.
