# Frontend overview

## Stack
- Next.js 16 App Router with static export (`output: "export"`)
- React 19, TypeScript
- Tailwind CSS v4 (via @tailwindcss/postcss)
- Drag-and-drop via @dnd-kit/core and @dnd-kit/sortable
- Unit tests: Vitest + @testing-library/react
- E2E tests: Playwright (runs against the backend-served app at port 8000)

## Entry points
- App shell: `src/app/layout.tsx` — fonts, global styles
- Home route: `src/app/page.tsx` — owns auth state, board state, and chat state
- Global styles and CSS variables: `src/app/globals.css`

## Auth flow
Credentials are validated client-side in `page.tsx` against hardcoded values (`user` / `password`). No server session is used. The username is passed to every API call so the backend can scope data correctly.

## UI components
- `KanbanBoard` (`src/components/KanbanBoard.tsx`)
  - Receives `board` and `onBoardChange` props — state is owned by `page.tsx`
  - Handles drag-and-drop via DndContext + DragOverlay
  - Calls `onRenameColumn`, `onAddCard`, `onDeleteCard`, `onMoveCard` callbacks
  - Renders an optional `sidebar` slot (used for ChatSidebar)
- `KanbanColumn` (`src/components/KanbanColumn.tsx`) — droppable column surface
- `KanbanCard` (`src/components/KanbanCard.tsx`) — sortable card with remove button
- `KanbanCardPreview` (`src/components/KanbanCardPreview.tsx`) — drag overlay preview
- `NewCardForm` (`src/components/NewCardForm.tsx`) — inline add-card form
- `ChatSidebar` (`src/components/ChatSidebar.tsx`) — AI chat panel rendered inside KanbanBoard sidebar slot

## Data model and utilities (`src/lib/`)
- `kanban.ts` — types (`Card`, `Column`, `BoardData`), `moveCard`, `findCardLocation`, `toColumnId`, `toCardId`, `fromColumnId`, `fromCardId`
- `api.ts` — all fetch functions: `fetchBoard`, `createCard`, `updateCard`, `deleteCard`, `updateColumn`, `sendChat`, `toBoardData`

## ID prefixing convention
Backend uses integer primary keys. The frontend prefixes them before use in drag-and-drop:
- Columns: `col-{id}` via `toColumnId(id)`
- Cards: `card-{id}` via `toCardId(id)`

Prefix is stripped before every API call with `fromColumnId(id)` / `fromCardId(id)`. This prevents @dnd-kit from confusing IDs across entity types.

## Tests
- `src/app/page.test.tsx` — login form and auth state
- `src/components/KanbanBoard.test.tsx` — board rendering and interactions
- `src/components/ChatSidebar.test.tsx` — chat UI
- `src/components/KanbanCardPreview.test.tsx` — drag preview
- `src/lib/kanban.test.ts` — moveCard logic and utilities
- E2E: `tests/kanban.spec.ts` (Playwright, targets port 8000)

## Build and scripts
```bash
npm run dev           # Dev server (localhost:3000, no backend)
npm run build         # Static export → frontend/out/
npm run test:unit     # Vitest unit tests
npm run test:e2e      # Playwright (requires app running at port 8000)
npm run test:all      # Unit + E2E
```

## Notes
- The built `frontend/out/` directory is copied into the Docker image and served by FastAPI.
- `next.config.ts` sets `output: "export"`, `trailingSlash: true`, `images: { unoptimized: true }`.
- Do not add server-side Next.js features (API routes, server components with data fetching) — the build must remain a pure static export.
