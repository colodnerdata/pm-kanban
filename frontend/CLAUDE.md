# Frontend: Kanban Studio

Next.js 16 static export served by the FastAPI backend. All board data is persisted via the backend API.

## Stack
- Next.js 16 (React 19), TypeScript, Tailwind CSS v4
- Drag and drop: @dnd-kit/core + @dnd-kit/sortable
- Unit tests: Vitest + @testing-library/react
- E2E tests: Playwright (targets port 8000 — requires running container)

## Directory structure

```
src/
  app/
    layout.tsx          # Root layout; loads Space Grotesk + Manrope fonts
    page.tsx            # Root page; auth state, board state, chat state, all API wiring
    globals.css         # CSS custom properties (design tokens)
    page.test.tsx       # Login form and auth state tests
  components/
    KanbanBoard.tsx         # Board rendering and drag-and-drop; state passed via props
    KanbanBoard.test.tsx    # Board unit tests
    KanbanColumn.tsx        # Droppable column
    KanbanCard.tsx          # Sortable card
    KanbanCardPreview.tsx   # Drag overlay preview
    KanbanCardPreview.test.tsx
    NewCardForm.tsx          # Inline add-card form
    ChatSidebar.tsx          # AI chat panel
    ChatSidebar.test.tsx
  lib/
    kanban.ts           # Types, ID prefix helpers, moveCard, findCardLocation
    kanban.test.ts
    api.ts              # All fetch functions to the backend API
  test/
    setup.ts            # Vitest test environment setup
    vitest.d.ts
tests/
  kanban.spec.ts        # Playwright E2E tests
```

## Data model

```typescript
type Card     = { id: string; title: string; details: string }
type Column   = { id: string; title: string; cardIds: string[] }
type BoardData = { columns: Column[]; cards: Record<string, Card> }
```

IDs in `BoardData` are prefixed strings (`col-{n}`, `card-{n}`). Raw backend integer IDs are extracted with `fromColumnId` / `fromCardId` before API calls.

## Auth flow
`page.tsx` validates credentials client-side against the hardcoded values `user` / `password`. On success it sets `isAuthenticated = true` and begins fetching board data. The username string is passed to every API call.

## API calls (`src/lib/api.ts`)
All functions accept a `username` argument passed as the `X-User` request header.

| Function | Method | Route |
|---|---|---|
| `fetchBoard` | GET | `/api/board` |
| `createCard` | POST | `/api/cards` |
| `updateCard` | PATCH | `/api/cards/{id}` |
| `deleteCard` | DELETE | `/api/cards/{id}` |
| `updateColumn` | PATCH | `/api/columns/{id}` |
| `sendChat` | POST | `/api/chat` |

`toBoardData(payload)` converts the backend response (string IDs, column arrays) into the `BoardData` shape with prefixed IDs used by the UI.

## Design system

| Variable | Value | Usage |
|---|---|---|
| `--primary-blue` | `#209dd7` | Links, key sections |
| `--secondary-purple` | `#753991` | Submit buttons, actions |
| `--accent-yellow` | `#ecad0a` | Highlights, accents |
| `--navy-dark` | `#032147` | Headings |
| `--gray-text` | `#888888` | Labels, supporting text |

## Running locally
```bash
cd frontend
npm install
npm run dev         # localhost:3000 (no backend — API calls will fail)
npm run test:unit
npm run build       # produces frontend/out/ for Docker
```

## Important constraints
- Must remain a pure static export — no Next.js server features.
- `next.config.ts` requires `output: "export"`, `trailingSlash: true`, `images: { unoptimized: true }`.
- Do not use `next/image` without `unoptimized: true`.
- Board state lives in `page.tsx`, not in `KanbanBoard`. Pass it via props.
