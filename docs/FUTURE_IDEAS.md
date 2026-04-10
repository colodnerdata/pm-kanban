# Future ideas

Backlog of improvement ideas for the Kanban system. These are not prioritized — treat this as a reference when planning future work. Each item can be designed and implemented as a standalone part.

---

## Authentication and users

**Real authentication**
Replace the hardcoded client-side credential check with proper server-side auth. Store a hashed password in the `users` table (the `password_hash` column already exists). Issue a signed session cookie or JWT on login. The `X-User` header approach can stay for local development but should be replaced for any multi-user or network-accessible deployment.

**User registration**
Add a registration flow so new users can create accounts. The `users` table already supports multiple users. Backend just needs a `POST /api/register` endpoint and a frontend registration form.

**Password reset**
Email-based reset flow once real auth is in place.

---

## Board and card features

**Multiple boards per user**
The `boards` table has a `user_id` FK but enforces `UNIQUE (user_id)` for the MVP. Removing that constraint and adding a board-switching UI would unlock this. Add a board list view and a "create board" action.

**Card due dates**
Add a `due_date TEXT` column to `cards`. Display as a badge on the card. Add sorting/filtering by due date. A calendar view could be a natural follow-on.

**Card labels and tags**
Many-to-many relationship: `labels` table and a `card_labels` join table. Display as coloured chips on cards. Useful for filtering.

**Card priority**
An enum column (`priority`: low / medium / high / urgent) with a visual indicator. Cards could be sorted by priority within a column.

**Card assignments**
Assign a card to a user. Requires the users feature to be in place. Add an `assignee_id FK` on `cards` and display an avatar/name on the card.

**Card comments**
A `comments` table (`id`, `card_id`, `user_id`, `body`, `created_at`). Display a thread on the card detail view.

**File attachments**
Store files (or references to files) against cards. For a local Docker setup, files can be stored on disk with paths in the DB.

**Archive and restore cards**
The `archived` column already exists on `cards`. Build the UI to archive a card (soft delete) and view/restore archived cards from a dedicated panel.

**Reorder columns**
Currently columns can only be renamed, not reordered. The `position` field already supports it — just needs the drag-and-drop wiring on columns (not just cards) and a `PATCH /api/columns/{id}` call with `position`.

**Column WIP limits**
Allow each column to define a maximum number of active cards. Display a warning badge when the limit is exceeded. Stored as `wip_limit INTEGER` on `columns`.

**Swimlanes**
Horizontal groupings across all columns (e.g. by user, by sprint, by priority). Significant UI work but high value for team boards.

---

## Search and filtering

**Full-text card search**
SQLite supports FTS5 (full-text search). Index card titles and details for fast search. Add a search input to the board header.

**Filter by label, assignee, or due date**
Client-side filtering of the rendered cards without a new API call, using the already-loaded board data.

---

## Real-time and collaboration

**WebSocket live updates**
Use FastAPI WebSockets to push board changes to all connected clients. Enables multi-user real-time collaboration without polling.

**Presence indicators**
Show which users are currently viewing or editing the board. Requires WebSockets and a presence store (in-memory or Redis).

---

## Infrastructure and operations

**Proper session storage**
Replace in-memory session tokens with a `sessions` DB table or Redis. Survives container restarts.

**Database migrations with versioning**
Replace the current `IF NOT EXISTS` approach with a versioned migration system. `PRAGMA user_version` is already called out in `DB_MODEL.md`. A small migration runner that applies numbered SQL files in order is sufficient for SQLite.

**Migrate to PostgreSQL**
SQLite is sufficient for local single-user use. For a shared or production deployment, switch to PostgreSQL. FastAPI + SQLAlchemy or asyncpg would be the natural path. The schema design is already compatible.

**Structured logging and observability**
Add structured JSON logs to the backend. Instrument key operations (board load time, API latency, error rates). A Prometheus metrics endpoint and a Grafana dashboard would close the loop.

**API rate limiting**
Add per-user rate limiting to the API endpoints to prevent abuse. FastAPI middleware or a library like `slowapi` keeps this simple.

**CI/CD pipeline**
A GitHub Actions workflow that builds the Docker image, runs backend tests, runs frontend unit tests, and optionally runs integration tests against a test container. Triggers on push to main.

**HTTPS and reverse proxy**
For any non-localhost deployment, add nginx or Caddy in front of the container to terminate TLS.

---

## Developer experience

**OpenAPI documentation**
FastAPI generates an OpenAPI spec automatically at `/docs`. Ensure all routes have accurate response models and descriptions so the spec is useful.

**Backend test coverage report**
Add `pytest-cov` to the test run with a coverage threshold. Currently `pytest-cov` is already in `requirements.txt` — wire it up in CI.

**Playwright tests against Docker**
Run the full Playwright E2E suite in CI against a freshly built Docker image to catch integration regressions.

**Accessibility audit**
Audit the frontend with axe-core or Lighthouse. Add ARIA labels to the board, columns, and cards. Ensure keyboard navigation works throughout (add card, rename column, drag via keyboard).

**Dark mode**
The design system uses CSS custom properties — adding a dark theme is mostly a matter of defining a second set of variable values and toggling a class on the root element.

**Mobile layout**
The current layout is desktop-first. A responsive column layout (horizontal scroll on small screens, or a single-column stacked view) would make the board usable on mobile.

**Board export**
Export the current board as JSON or CSV. Useful for backups and reporting. A simple `GET /api/board/export` endpoint returning the full board JSON is a starting point.

**Board import**
The inverse of export — paste or upload a JSON file to restore or seed a board. Useful for onboarding or templates.

**Board templates**
Pre-defined starting layouts (e.g. Software Sprint, Content Calendar, Bug Triage). A `POST /api/board/reset?template=sprint` endpoint could apply a template.
