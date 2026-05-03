# High level steps for project

This document is the execution plan. Each part includes a checklist, tests, and success criteria. The agent should complete one part at a time and verify before moving to the next.

## Part 1: Plan

Goals
- Confirm current repo state and frontend architecture
- Create `frontend/AGENTS.md` describing the existing code
- Define the implementation sequence, expected tests, and acceptance criteria
- Get explicit user approval before coding

Checklist
- [x] Review current frontend source and test coverage
- [x] Create `frontend/AGENTS.md` with component descriptions, data model, and build/test commands
- [x] Confirm no backend implementation or Docker setup exists yet (a `backend/` directory exists as a placeholder with only `AGENTS.md`)
- [x] Write this detailed plan with substeps and success criteria
- [ ] Present the plan for user approval

Tests
- `frontend/AGENTS.md` exists and accurately reflects the frontend
- `docs/PLAN.md` includes explicit checklists and pass/fail criteria

Success criteria
- The plan is complete, actionable, and approved by the user
- The frontend folder has an agent doc that can guide later contributors

## Part 2: Scaffolding

Goals
- Add backend folder and Docker support
- Create a minimal FastAPI app that serves static content and a simple API route
- Add start/stop scripts for local development

Checklist
- [ ] Add `backend/` with a minimal FastAPI application
- [ ] Add `Dockerfile` at repo root or appropriate location
- [ ] Ensure Docker build produces a working image
- [ ] Add `scripts/start.sh` and `scripts/stop.sh` for Linux/macOS
- [ ] Add a simple `/api/hello` endpoint or equivalent
- [ ] Serve a static HTML file or Next.js built frontend at `/`

Tests
- Docker image builds successfully
- Container runs and responds on `/api/hello`
- Root path returns static HTML or frontend content

Success criteria
- Local container can start and serve a test page plus one backend API endpoint
- Start/stop scripts work consistently on Linux/macOS

## Part 3: Add in Frontend

Goals
- Build the existing Next.js app for production
- Serve the built frontend from the backend static server
- Preserve current Kanban UI behavior

Checklist
- [ ] Confirm the frontend app builds with `npm run build`
- [ ] Add backend static file serving for the frontend build output
- [ ] Verify the root route renders the Kanban board in the container
- [ ] Keep current board behavior and styling intact

Tests
- `npm run build` succeeds in `frontend/`
- Built app assets can be served by the backend and render correctly
- The main Kanban UI appears at `/`

Success criteria
- The app is served from the backend and the demo board is visible in production mode
- No regression in frontend behavior compared to the existing demo

## Part 4: Add a fake user sign in experience

Goals
- Add a login gate before the Kanban board is shown
- Use hardcoded credentials: `user` / `password`
- Add logout behavior

Checklist
- [ ] Add a login screen at `/` when no session exists
- [ ] Authenticate only the hardcoded credentials
- [ ] Persist session state locally or via backend session cookie
- [ ] Show logout control and return to login screen on sign out
- [ ] Prevent board access without login

Tests
- Login with correct credentials displays the board
- Login with incorrect credentials stays on the login screen
- Logout returns to the login screen
- Board content is blocked until successful login

Success criteria
- The app requires login and allows logout with the dummy credentials
- The Kanban board appears only after successful authentication

## Part 5: Database modeling

Goals
- Define a simple SQLite schema for users and one board per user
- Store the board state as JSON
- Document the database design in `docs/`

Checklist
- [ ] Design a schema with `users` and `boards` tables
- [ ] Store board JSON in a `TEXT` or `JSON` column
- [ ] Ensure schema supports multiple users and one board per user
- [ ] Add a `docs/` note describing the schema and example data
- [ ] Confirm database file is created automatically if missing

Tests
- Schema validates with SQLite
- Database creation works on first run
- Example JSON board can be inserted and queried

Success criteria
- The schema is documented and ready for backend use
- The app can create the SQLite database automatically

## Part 6: Backend

Goals
- Add API routes to read and mutate the Kanban board for the authenticated user
- Persist board updates in SQLite
- Create the database if it does not exist

Checklist
- [ ] Add backend API endpoints such as:
  - `GET /api/board`
  - `POST /api/board`
  - optionally `POST /api/auth/login` and `POST /api/auth/logout`
- [ ] Implement board persistence in SQLite
- [ ] Use the user identity to load/save the correct board
- [ ] Ensure the database is initialized automatically at startup

Tests
- API returns board JSON for the user
- API accepts board updates and persists them
- Database file is created if missing
- Endpoints return proper HTTP status codes on success/failure

Success criteria
- Backend can read and write the user board from SQLite
- The API is stable and returns JSON successfully

## Part 7: Frontend + Backend

Goals
- Wire the frontend to the backend API
- Use backend persistence for all board actions
- Keep the UI responsive and consistent

Checklist
- [ ] Fetch the board from `GET /api/board` on page load after authentication
- [ ] Send updates for rename, add, delete, and drag/drop actions
- [ ] Update local UI state from backend responses
- [ ] Handle backend errors gracefully in the UI

Tests
- Board data loads from backend after login
- Rename, add, delete, and move actions persist across reloads
- Backend updates reflect in the UI automatically

Success criteria
- The Kanban board is persistent and synchronized with the backend
- Reloading the page shows the saved board state

## Part 8: AI connectivity

Goals
- Add backend integration with OpenRouter
- Confirm model connectivity with a simple test query
- Keep AI calls behind the backend

Checklist
- [ ] Add `OPENROUTER_API_KEY` support via `.env`
- [ ] Implement an AI route such as `POST /api/ai/chat`
- [ ] Call `openai/gpt-oss-120b` through OpenRouter
- [ ] Validate the integration with a simple query like `2+2`

Tests
- AI route can be called successfully
- Response contains a plausible answer for the test query
- Backend handles missing/invalid API key cleanly

Success criteria
- The backend can call OpenRouter and receive a valid model response
- The simple connectivity test passes reliably

## Part 9: AI Structured Outputs

Goals
- Send the current board JSON plus user prompt and history to the AI
- Accept structured output containing a message plus optional board update
- Apply board updates automatically when the AI returns them

Checklist
- [ ] Build request payload with board state, prompt, and conversation history
- [ ] Define a structured output schema for AI responses
- [ ] Parse the AI response safely
- [ ] Apply board updates to the backend if present
- [ ] Return the AI message and update result to the frontend

Tests
- Structured output is parsed correctly from a sample response
- AI response can include board updates and those updates are persisted
- Invalid or malformed AI output is handled without crashing

Success criteria
- AI responses can update the board when structured output requests it
- Board changes from AI are reflected in persisted state

## Part 10: AI sidebar UI

Goals
- Add a sidebar chat widget to the UI
- Show chat history, user prompts, and AI responses
- Let the AI modify the board and refresh the UI automatically

Checklist
- [ ] Add a sidebar component for AI chat
- [ ] Provide an input field for user prompts
- [ ] Display AI responses and conversation history
- [ ] Call the backend AI route from the frontend
- [ ] Refresh the board if the AI returns an update
- [ ] Keep the sidebar visible alongside the Kanban board

Tests
- Chat UI accepts prompts and shows AI replies
- AI-based board updates refresh the board automatically
- Sidebar is usable in desktop layout

Success criteria
- The UI supports a working AI chat sidebar
- AI interactions can update the board and the user sees changes immediately

## Approval

Once this plan is complete, the agent should ask the user to confirm the plan before starting implementation. Any changes to scope or approach should be documented and approved.