# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project overview

A Project Management MVP web app with a Kanban board. Users sign in with hardcoded credentials, view and manage a Kanban board with drag-and-drop, and can rename columns and edit cards. All data persists in SQLite.

**Stack:** Next.js 16 frontend (React 19, TypeScript, Tailwind v4, @dnd-kit) + Python FastAPI backend + SQLite, packaged in Docker.

**MVP constraints:** Hardcoded login (`user` / `password`), one board per user, local Docker deployment only.

## Commands

### Running the app (Docker)
```bash
# Mac
scripts/start-mac.sh    # Build image and start container
scripts/stop-mac.sh     # Stop and remove container

# Linux
scripts/start-linux.sh
scripts/stop-linux.sh

# Windows
scripts/start-windows.ps1
scripts/stop-windows.ps1
```
App available at http://localhost:8000. The `.env` file at the project root is loaded automatically if present.

### Frontend (from `frontend/` directory)
```bash
npm run dev           # Dev server on localhost:3000
npm run build         # Static export to frontend/out/
npm run test:unit     # Vitest unit tests
npm run test:e2e      # Playwright E2E tests (requires running app)
npm run test:all      # Unit + E2E
```

### Backend tests (inside container)
```bash
docker exec pm-app python -m pytest backend/tests/test_main.py backend/tests/test_board_api.py -v
docker exec -e PM_BASE_URL=http://localhost:8000 pm-app python -m pytest backend/tests/test_integration.py -v
```

## Architecture

### Frontend (`frontend/src/`)
- `app/page.tsx` — root page; owns auth state, board state, and chat state; handles login/logout
- `components/KanbanBoard.tsx` — board rendering and drag-and-drop; receives board state as props
- `components/ChatSidebar.tsx` — AI chat interface (sidebar panel)
- `components/KanbanColumn.tsx`, `KanbanCard.tsx`, `KanbanCardPreview.tsx`, `NewCardForm.tsx` — board UI primitives
- `lib/api.ts` — all fetch calls to the backend API
- `lib/kanban.ts` — data types (Card, Column, BoardData), ID prefix helpers, moveCard utility

### Backend (`backend/app/`)
- `main.py` — FastAPI app, lifespan (calls `init_db()`), route registration, static file mounting
- `config.py` — environment config, seed data, path resolution
- `database.py` — DB connection (with `PRAGMA foreign_keys = ON`), schema init, queries
- `models.py` — Pydantic request/response models
- `dependencies.py` — `get_db` (connection per request), `get_username` (X-User header)
- `routes/board.py` — board, column, and card CRUD endpoints
- `routes/static.py` — static file and SPA fallback serving
- `ai.py` — OpenRouter client, structured output parsing, action application

### Key API routes
| Route | Method | Purpose |
|---|---|---|
| `/health` | GET | Health check |
| `/api/board` | GET | Fetch user's full board |
| `/api/columns` | POST | Create column |
| `/api/columns/{id}` | PATCH / DELETE | Rename or delete column |
| `/api/cards` | POST | Create card |
| `/api/cards/{id}` | PATCH / DELETE | Update, move, or delete card |
| `/api/chat` | POST | AI chat with structured output |
| `/{path}` | GET | Static SPA fallback |

### ID convention
Frontend prefixes all backend integer IDs for drag-and-drop stability: `col-{id}` for columns, `card-{id}` for cards. The `fromColumnId` / `fromCardId` helpers in `lib/kanban.ts` strip the prefix before API calls.

### Auth
Credentials are validated client-side in `page.tsx`. The username is passed to every API request via the `X-User` HTTP header. The backend `get_username()` dependency reads this header, defaulting to `"user"`.

## Color scheme
- Accent Yellow: `#ecad0a`
- Blue Primary: `#209dd7`
- Purple Secondary: `#753991` (submit buttons)
- Dark Navy: `#032147` (headings)
- Gray Text: `#888888`

## Development guidelines

1. Keep it simple — no over-engineering, no speculative abstractions, no unnecessary defensive code.
2. Identify root cause before fixing — prove with evidence, then fix.
3. Use latest versions of libraries and idiomatic patterns.
4. No emojis in any file.
5. Parameterize all SQL queries — never format user data into query strings.
6. See `docs/ARCHITECTURE.md` for detailed technical decisions and conventions.
7. See `docs/PLAN.md` for the implementation plan and testing reference.
