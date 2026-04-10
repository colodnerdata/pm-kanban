# Project plan (detailed)

This plan is the single source of truth for the MVP. Each part includes a checklist, tests, and success criteria. Target 80% unit test coverage when it is sensible and adds value; prioritize robust integration testing and meaningful unit tests over coverage metrics.

## Part 1: Plan

Checklist
- [x] Review root AGENTS.md and existing documentation.
- [x] Enrich this plan with detailed steps, tests, and success criteria.
- [x] Create frontend/AGENTS.md that documents the existing frontend code.
- [x] Get user approval before starting Part 2.

Tests
- None for this step.

Success criteria
- Plan is detailed, actionable, and approved by the user.
- frontend/AGENTS.md accurately reflects current frontend architecture.

---

## Part 2: Scaffolding (Docker + FastAPI + scripts)

Checklist
- [x] Define Dockerfile and any compose config needed for local containerized development.
- [x] Create backend FastAPI app in backend/ with a health endpoint and a simple API endpoint.
- [x] Serve a minimal static HTML response at / to validate serving.
- [x] Add scripts in scripts/ for start and stop on Mac, PC, Linux.
- [x] Ensure uv is used as the Python package manager inside the container.
- [x] Add minimal README notes for running locally.

Tests
- [x] Backend unit test for health endpoint.
- [x] Integration test that hits / and the example API endpoint in the running container.

Success criteria
- Container starts with a single command and serves both HTML at / and JSON at the API endpoint.
- Start/stop scripts work on Mac, PC, and Linux.
- Unit coverage for backend modules at or above 80%.

---

## Part 3: Add in Frontend (static build served by backend)

Checklist
- [x] Configure frontend build output for static export compatible with FastAPI serving.
- [x] Update backend to serve the built frontend at /.
- [x] Ensure the Kanban board renders correctly at / in the container.

Tests
- [x] Frontend unit tests continue to pass with coverage targets where sensible.
- [x] Integration test to verify / serves the Kanban UI and key elements exist.

Success criteria
- The app loads the existing Kanban demo at / via the backend.
- All unit and integration tests pass; coverage targets are applied where sensible.

---

## Part 4: Fake user sign-in experience

Checklist
- [x] Add a simple login screen on / when unauthenticated.
- [x] Hardcode credentials to user/password for MVP.
- [x] Add a logout control that returns to the login screen.
- [x] Preserve Kanban data in memory for the session.

Tests
- [x] Unit tests for login form behavior and validation.
- [x] Integration tests for login, viewing Kanban, and logout flows.

Success criteria
- Unauthenticated users see login screen; authenticated users see Kanban.
- Login and logout flows function reliably with tests covering the flow.

---

## Part 5: Database modeling

Checklist
- [x] Propose SQLite schema for users, boards, columns, cards, and ordering.
- [x] Save schema proposal as JSON in docs/.
- [x] Document rationale and migration approach in docs/.
- [x] Get user sign-off before implementation.

Tests
- [x] Validate schema JSON structure with a simple unit test.

Success criteria
- Schema proposal is clear, normalized, and approved by the user.

Revisions applied before sign-off
- Added `PRAGMA foreign_keys = ON` to `connect_db()` so FK constraints are enforced at runtime.
- Added missing compound indexes `idx_columns_board_position` and `idx_cards_column_position` to `init_db()` to align implementation with the JSON schema doc.

---

## Part 6: Backend API (persistent Kanban)

Checklist
- [x] Create SQLite DB if missing on startup.
- [x] Implement CRUD endpoints for board, columns, and cards.
- [x] Scope all operations to the signed-in user.
- [x] Add request/response validation and error handling.

Tests
- [x] Unit tests for each endpoint handler (coverage targets where sensible).
- [x] Integration tests for create/read/update/delete card and column flows.

Success criteria
- API persists data to SQLite and passes all tests.
- Coverage targets are applied where sensible for backend units.

---

## Part 7: Frontend + Backend integration

Checklist
- [x] Replace in-memory Kanban data with backend API calls.
- [x] Add optimistic UI where appropriate.
- [x] Handle error states gracefully.
- [x] Align drag-and-drop identifiers with backend numeric ids via client-side prefixing.
- [x] Route Playwright integration tests through the backend-served frontend.

Tests
- [x] Frontend unit tests updated for API-driven data (coverage targets where sensible).
- [x] Integration tests covering UI + API flows end-to-end.

Success criteria
- Kanban data persists across reloads using the backend.
- Full flow passes integration tests reliably.

Design decisions
- Frontend prefixes backend numeric ids for drag-and-drop stability and strips them before API calls.
- Drag-and-drop uses card/column metadata to resolve drop targets across columns.
- Playwright runs against the backend-served static build to reflect production behavior.

---

## Testing reference

### Running the full test suite

Start the container in detached mode first:
```bash
./scripts/start-mac.sh
```

Backend unit tests (inside container, requires Python 3.12):
```bash
docker exec pm-app python -m pytest backend/tests/test_main.py backend/tests/test_board_api.py -v
```

Live integration tests (against the running container):
```bash
docker exec -e PM_BASE_URL=http://localhost:8000 pm-app \
  python -m pytest backend/tests/test_integration.py -v
```

Frontend unit tests (local, Node required):
```bash
cd frontend && npm run test:unit
```

Stop when done:
```bash
./scripts/stop-mac.sh
```

### Notes
- Backend tests use `PM_DB_PATH` env var with `tmp_path` fixture for isolated per-test databases.
- Integration tests are skipped automatically when `PM_BASE_URL` is not set.
- The `.env` file at the project root is optional for Parts 1-7 (no AI key needed). Required for AI features.
